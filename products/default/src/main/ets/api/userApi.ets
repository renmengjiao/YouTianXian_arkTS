/**
 * 用户相关 API
 */
import { http } from '@kit.NetworkKit';
import { HttpClient, ApiResponse } from './httpClient';
import { UserInfo, LoginRequest, RegisterRequest, LoginResponse,
  PasswordUpdate, NotificationSettings, RefreshTokenRequest, ProfileUpdate, NotificationSettingsUpdate, NotificationUpdateResult } from '../model/UserInfo';
import { LoginRecord, LoginRecordFilter, ClearLoginRecordsRequest, ClearRecordsResult } from '../model/CommonModels';
import { PageData } from './httpClient';

/** 头像上传响应 */
export interface AvatarResponse {
  avatarUrl: string;
}

export interface AvatarUpload {
  data: ArrayBuffer;
  contentType: string;
  remoteFileName: string;
}

/** 未读计数响应 */
interface UnreadCountResponse {
  count: number;
}

/** 登录 */
export function login(data: LoginRequest): Promise<ApiResponse<LoginResponse>> {
  return HttpClient.getInstance().postPublic<LoginResponse>('/auth/login', data);
}

/** 注册 */
export function register(data: RegisterRequest): Promise<ApiResponse<LoginResponse>> {
  return HttpClient.getInstance().postPublic<LoginResponse>('/auth/register', data);
}

/** 获取用户信息 */
export function fetchUserProfile(): Promise<ApiResponse<UserInfo>> {
  return HttpClient.getInstance().get<UserInfo>('/user/profile');
}

/** 编辑用户信息 */
export function updateUserProfile(data: ProfileUpdate): Promise<ApiResponse<null>> {
  return HttpClient.getInstance().put<null>('/user/profile', data);
}

/** 上传头像 */
export function uploadAvatar(file: AvatarUpload): Promise<ApiResponse<AvatarResponse>> {
  const parts: http.MultiFormData[] = [{
    name: 'avatar',
    contentType: file.contentType,
    remoteFileName: file.remoteFileName,
    data: file.data
  }];
  return HttpClient.getInstance().postMultipart<AvatarResponse>('/user/avatar', parts);
}

/** 获取通知设置 */
export function fetchNotificationSettings(): Promise<ApiResponse<NotificationSettings>> {
  return HttpClient.getInstance().get<NotificationSettings>('/user/notification-settings');
}

/** 更新通知设置 */
export function updateNotificationSettings(
  data: NotificationSettingsUpdate): Promise<ApiResponse<NotificationUpdateResult>> {
  return HttpClient.getInstance().put<NotificationUpdateResult>('/user/notification-settings', data);
}

/** 分页参数 */
interface LoginPageParams extends LoginRecordFilter {
  page: number;
  pageSize: number;
}

/** 修改密码 */
export function changePassword(data: PasswordUpdate): Promise<ApiResponse<null>> {
  return HttpClient.getInstance().put<null>('/user/password', data);
}

/** 获取登录记录（分页） */
export function fetchLoginRecords(page: number, pageSize: number,
  filter: LoginRecordFilter = {}): Promise<ApiResponse<PageData<LoginRecord>>> {
  const params: LoginPageParams = { page: page, pageSize: pageSize };
  if (filter.startTime?.trim()) params.startTime = filter.startTime.trim();
  if (filter.endTime?.trim()) params.endTime = filter.endTime.trim();
  if (filter.deviceType && filter.deviceType !== 'all') params.deviceType = filter.deviceType;
  return HttpClient.getInstance().get<PageData<LoginRecord>>('/user/login-records', params);
}

/** 清空登录记录 */
export function clearLoginRecords(body: ClearLoginRecordsRequest): Promise<ApiResponse<ClearRecordsResult>> {
  return HttpClient.getInstance().deleteJson<ClearRecordsResult>('/user/login-records', body);
}

/** 退出登录 */
export function refresh(refreshToken: string): Promise<ApiResponse<LoginResponse>> {
  const body: RefreshTokenRequest = { refreshToken: refreshToken };
  return HttpClient.getInstance().postPublic<LoginResponse>('/auth/refresh', body);
}

export function logout(refreshToken: string): Promise<ApiResponse<null>> {
  const body: RefreshTokenRequest = { refreshToken: refreshToken };
  return HttpClient.getInstance().postPublic<null>('/auth/logout', body);
}
