import { fetchUserProfile, updateUserProfile } from '../api/userApi';
import { ApiError, ApiErrorKind } from '../api/httpClient';
import { ProfileUpdate, UserInfo } from '../model/UserInfo';
import { SessionManager } from '../session/SessionManager';

export interface ProfileDraft {
  nickname: string;
  email: string;
  phone: string;
  department: string;
}

export interface ProfileSnapshot {
  profile: UserInfo;
  generation: number;
}

export interface ProfileSaveResult {
  snapshot: ProfileSnapshot;
  changed: boolean;
}

/** snapshot 非空表示已读到服务端值，但与本次提交不一致。 */
export class ProfileVerificationError extends Error {
  snapshot: ProfileSnapshot | null;

  constructor(message: string, snapshot: ProfileSnapshot | null = null) {
    super(message);
    this.name = 'ProfileVerificationError';
    this.snapshot = snapshot;
  }
}

export class ProfileService {
  private static nullableString(value: string | null): boolean {
    return value === null || typeof value === 'string';
  }

  private static validate(profile: UserInfo): void {
    if (!profile || typeof profile.userId !== 'string'
      || !/^\d+$/.test(profile.userId)
      || typeof profile.username !== 'string'
      || typeof profile.nickname !== 'string'
      || !ProfileService.nullableString(profile.avatar)
      || !ProfileService.nullableString(profile.email)
      || !ProfileService.nullableString(profile.phone)
      || !ProfileService.nullableString(profile.department)
      || !ProfileService.nullableString(profile.role)
      || !ProfileService.nullableString(profile.createTime)
      || !ProfileService.nullableString(profile.lastLoginTime)) {
      throw new ApiError(ApiErrorKind.RESPONSE, '用户资料响应不完整，请重新读取');
    }
  }

  private static async read(generation: number,
    expectedUserId: string | null): Promise<ProfileSnapshot> {
    const manager = SessionManager.getInstance();
    if (expectedUserId !== null) {
      manager.assertCurrentUser(expectedUserId, generation);
    }
    const response = await fetchUserProfile();
    ProfileService.validate(response.data);
    if (expectedUserId !== null && response.data.userId !== expectedUserId) {
      throw new ApiError(ApiErrorKind.RESPONSE, '返回的用户资料与当前账号不一致');
    }
    manager.updateProfile(response.data, generation);
    return { profile: response.data, generation: generation };
  }

  static load(): Promise<ProfileSnapshot> {
    return ProfileService.read(SessionManager.getInstance().getSessionGeneration(), null);
  }

  private static buildUpdate(profile: UserInfo, draft: ProfileDraft): ProfileUpdate {
    const update: ProfileUpdate = {};
    if (draft.nickname !== profile.nickname) {
      update.nickname = draft.nickname;
    }
    if (draft.email !== (profile.email ?? '')) {
      update.email = draft.email;
    }
    if (draft.department !== (profile.department ?? '')) {
      update.department = draft.department;
    }
    if (draft.phone !== (profile.phone ?? '')) {
      if (!draft.phone) {
        throw new Error('当前接口不支持解绑手机号，请保留原手机号或填写新的11位手机号');
      }
      if (!/^1\d{10}$/.test(draft.phone)) {
        throw new Error('手机号格式不正确，请填写以1开头的11位手机号');
      }
      update.phone = draft.phone;
    }
    return update;
  }

  static async save(baseline: ProfileSnapshot,
    draft: ProfileDraft): Promise<ProfileSaveResult> {
    const manager = SessionManager.getInstance();
    const userId = baseline.profile.userId;
    manager.assertCurrentUser(userId, baseline.generation);
    const update = ProfileService.buildUpdate(baseline.profile, draft);
    if (update.nickname === undefined && update.email === undefined
      && update.phone === undefined && update.department === undefined) {
      return { snapshot: baseline, changed: false };
    }
    try {
      // 成功响应为 {code:200,message:...,data:null}，不是新的资料。
      await updateUserProfile(update);
    } catch (error) {
      manager.assertCurrentUser(userId, baseline.generation);
      const failure = error as ApiError;
      if (failure instanceof ApiError && (failure.kind === ApiErrorKind.NETWORK
        || failure.kind === ApiErrorKind.RESPONSE || failure.httpStatus >= 500)) {
        throw new ProfileVerificationError(
          '保存请求的结果未确认，请重新读取资料核对。' + failure.message);
      }
      throw error as Error;
    }

    let snapshot: ProfileSnapshot;
    try {
      snapshot = await ProfileService.read(baseline.generation, userId);
    } catch (error) {
      manager.assertCurrentUser(userId, baseline.generation);
      throw new ProfileVerificationError(
        '更新请求已成功，但重新读取失败，尚未核对最终资料。' + (error as Error).message);
    }
    const actual = snapshot.profile;
    const mismatches: string[] = [];
    if (update.nickname !== undefined && actual.nickname !== update.nickname) {
      mismatches.push('昵称');
    }
    if (update.email !== undefined && actual.email !== update.email) {
      mismatches.push('邮箱');
    }
    if (update.phone !== undefined && actual.phone !== update.phone) {
      mismatches.push('手机号');
    }
    if (update.department !== undefined && actual.department !== update.department) {
      mismatches.push('部门');
    }
    if (mismatches.length > 0) {
      throw new ProfileVerificationError(
        '保存后核对不一致：' + mismatches.join('、') + '。已显示服务端值，请核对。', snapshot);
    }
    return { snapshot: snapshot, changed: true };
  }
}
