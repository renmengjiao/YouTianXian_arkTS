import {
  NotificationSettings, NotificationChannel, NotificationChannelUpdate,
  NotificationSettingsUpdate
} from '../model/UserInfo';
import { fetchNotificationSettings, updateNotificationSettings } from '../api/userApi';
import { ApiError, ApiErrorKind } from '../api/httpClient';
import { SessionManager } from '../session/SessionManager';

export interface NotificationSnapshot {
  settings: NotificationSettings;
  userId: string;
  generation: number;
}

export interface NotificationSaveResult {
  snapshot: NotificationSnapshot;
  changed: boolean;
}

export class NotificationVerificationError extends Error {
  snapshot: NotificationSnapshot | null;
  constructor(message: string, snapshot: NotificationSnapshot | null = null) {
    super(message);
    this.name = 'NotificationVerificationError';
    this.snapshot = snapshot;
  }
}

export class NotificationService {
  static copyChannel(channel: NotificationChannel): NotificationChannel {
    return {
      enabled: channel.enabled, threshold: channel.threshold,
      email: channel.email, push: channel.push, inApp: channel.inApp
    };
  }

  static copy(settings: NotificationSettings): NotificationSettings {
    return {
      simulationComplete: NotificationService.copyChannel(settings.simulationComplete),
      resourceWarning: NotificationService.copyChannel(settings.resourceWarning),
      systemUpdate: NotificationService.copyChannel(settings.systemUpdate),
      TeamCollaborationMessage: NotificationService.copyChannel(settings.TeamCollaborationMessage),
      lastUpdated: settings.lastUpdated
    };
  }

  private static validateChannel(channel: NotificationChannel): void {
    if (!channel || typeof channel.enabled !== 'boolean'
      || typeof channel.email !== 'boolean' || typeof channel.push !== 'boolean'
      || typeof channel.inApp !== 'boolean'
      || (channel.threshold !== undefined && channel.threshold !== null
        && (!Number.isInteger(channel.threshold)
          || channel.threshold < -2147483648 || channel.threshold > 2147483647))) {
      throw new ApiError(ApiErrorKind.RESPONSE, '通知渠道响应不完整，请重新读取');
    }
  }

  private static validate(settings: NotificationSettings): void {
    if (!settings || (settings.lastUpdated !== null
      && typeof settings.lastUpdated !== 'string')) {
      throw new ApiError(ApiErrorKind.RESPONSE, '通知设置响应不完整，请重新读取');
    }
    NotificationService.validateChannel(settings.simulationComplete);
    NotificationService.validateChannel(settings.resourceWarning);
    NotificationService.validateChannel(settings.systemUpdate);
    NotificationService.validateChannel(settings.TeamCollaborationMessage);
  }

  private static async read(userId: string, generation: number): Promise<NotificationSnapshot> {
    const manager = SessionManager.getInstance();
    manager.assertCurrentUser(userId, generation);
    const response = await fetchNotificationSettings();
    NotificationService.validate(response.data);
    manager.assertCurrentUser(userId, generation);
    return { settings: response.data, userId: userId, generation: generation };
  }

  static async load(): Promise<NotificationSnapshot> {
    const manager = SessionManager.getInstance();
    const user = await manager.restore();
    if (!user) {
      throw new ApiError(ApiErrorKind.UNAUTHORIZED, '请重新登录', 0, 401);
    }
    return NotificationService.read(user.userId, manager.getSessionGeneration());
  }

  private static channelPatch(base: NotificationChannel,
    draft: NotificationChannel): NotificationChannelUpdate | undefined {
    const patch: NotificationChannelUpdate = {};
    if (base.enabled !== draft.enabled) patch.enabled = draft.enabled;
    if (base.email !== draft.email) patch.email = draft.email;
    if (base.push !== draft.push) patch.push = draft.push;
    if (base.inApp !== draft.inApp) patch.inApp = draft.inApp;
    if ((base.threshold ?? null) !== (draft.threshold ?? null)) {
      if (draft.threshold === undefined || draft.threshold === null) {
        throw new Error('当前接口不支持清空已有阈值，请保留原值或输入整数');
      }
      patch.threshold = draft.threshold;
    }
    return patch.enabled === undefined && patch.email === undefined
      && patch.push === undefined && patch.inApp === undefined
      && patch.threshold === undefined ? undefined : patch;
  }

  private static matches(actual: NotificationChannel,
    patch: NotificationChannelUpdate | undefined): boolean {
    if (!patch) return true;
    return (patch.enabled === undefined || actual.enabled === patch.enabled)
      && (patch.email === undefined || actual.email === patch.email)
      && (patch.push === undefined || actual.push === patch.push)
      && (patch.inApp === undefined || actual.inApp === patch.inApp)
      && (patch.threshold === undefined || actual.threshold === patch.threshold);
  }

  static async save(base: NotificationSnapshot,
    draft: NotificationSettings): Promise<NotificationSaveResult> {
    const manager = SessionManager.getInstance();
    manager.assertCurrentUser(base.userId, base.generation);
    NotificationService.validate(draft);
    const patch: NotificationSettingsUpdate = {
      simulationComplete: NotificationService.channelPatch(base.settings.simulationComplete, draft.simulationComplete),
      resourceWarning: NotificationService.channelPatch(base.settings.resourceWarning, draft.resourceWarning),
      systemUpdate: NotificationService.channelPatch(base.settings.systemUpdate, draft.systemUpdate),
      TeamCollaborationMessage: NotificationService.channelPatch(
        base.settings.TeamCollaborationMessage, draft.TeamCollaborationMessage)
    };
    if (!patch.simulationComplete && !patch.resourceWarning
      && !patch.systemUpdate && !patch.TeamCollaborationMessage) {
      return { snapshot: base, changed: false };
    }
    try {
      const response = await updateNotificationSettings(patch);
      if (!response.data || response.data.updated !== true
        || (response.data.lastUpdated !== null && typeof response.data.lastUpdated !== 'string')) {
        throw new ApiError(ApiErrorKind.RESPONSE, '更新响应缺少有效的updated/lastUpdated');
      }
    } catch (error) {
      manager.assertCurrentUser(base.userId, base.generation);
      const failure = error as ApiError;
      if (failure instanceof ApiError && (failure.kind === ApiErrorKind.NETWORK
        || failure.kind === ApiErrorKind.RESPONSE || failure.httpStatus >= 500)) {
        throw new NotificationVerificationError('通知设置更新结果未确认，请重新读取核对。' + failure.message);
      }
      throw error as Error;
    }
    let snapshot: NotificationSnapshot;
    try {
      snapshot = await NotificationService.read(base.userId, base.generation);
    } catch (error) {
      manager.assertCurrentUser(base.userId, base.generation);
      throw new NotificationVerificationError('更新请求已成功，但通知设置重新读取失败。' + (error as Error).message);
    }
    const actual = snapshot.settings;
    if (!NotificationService.matches(actual.simulationComplete, patch.simulationComplete)
      || !NotificationService.matches(actual.resourceWarning, patch.resourceWarning)
      || !NotificationService.matches(actual.systemUpdate, patch.systemUpdate)
      || !NotificationService.matches(actual.TeamCollaborationMessage, patch.TeamCollaborationMessage)) {
      throw new NotificationVerificationError('通知设置核对不一致，已显示服务端值。', snapshot);
    }
    return { snapshot: snapshot, changed: true };
  }
}
