/**
 * 用户相关 API
 */
import { HttpClient, ApiResponse } from './httpClient';
import { UserInfo, LoginRequest, RegisterRequest, LoginResponse,
  PasswordUpdate, NotificationSettings } from '../model/UserInfo';
import { LoginRecord } from '../model/CommonModels';
import { PageData } from './httpClient';

/** 头像上传响应 */
interface AvatarResponse {
  avatar: string;
}

/** 未读计数响应 */
interface UnreadCountResponse {
  count: number;
}

/** 文件上传 body */
interface AvatarBody {
  fileUri: string;
}

/** 登录 */
export function login(data: LoginRequest): Promise<ApiResponse<LoginResponse>> {
  return HttpClient.getInstance().post<LoginResponse>('/auth/login', data);
}

/** 注册 */
export function register(data: RegisterRequest): Promise<ApiResponse<LoginResponse>> {
  return HttpClient.getInstance().post<LoginResponse>('/auth/register', data);
}

/** 获取用户信息 */
export function fetchUserProfile(): Promise<ApiResponse<UserInfo>> {
  return HttpClient.getInstance().get<UserInfo>('/user/profile');
}

/** 编辑用户信息 */
export function updateUserProfile(data: object): Promise<ApiResponse<UserInfo>> {
  return HttpClient.getInstance().put<UserInfo>('/user/profile', data);
}

/** 上传头像 */
export function uploadAvatar(fileUri: string): Promise<ApiResponse<AvatarResponse>> {
  const body: AvatarBody = { fileUri: fileUri };
  return HttpClient.getInstance().post<AvatarResponse>('/user/avatar', body);
}

/** 获取通知设置 */
export function fetchNotificationSettings(): Promise<ApiResponse<NotificationSettings>> {
  return HttpClient.getInstance().get<NotificationSettings>('/user/notification-settings');
}

/** 更新通知设置 */
export function updateNotificationSettings(data: NotificationSettings): Promise<ApiResponse<NotificationSettings>> {
  return HttpClient.getInstance().put<NotificationSettings>('/user/notification-settings', data);
}

/** 分页参数 */
interface LoginPageParams {
  page: number;
  page_size: number;
}

/** 修改密码 */
export function changePassword(data: PasswordUpdate): Promise<ApiResponse<null>> {
  return HttpClient.getInstance().put<null>('/user/password', data);
}

/** 获取登录记录（分页） */
export function fetchLoginRecords(page: number, pageSize: number): Promise<ApiResponse<PageData<LoginRecord>>> {
  const params: LoginPageParams = { page: page, page_size: pageSize };
  return HttpClient.getInstance().get<PageData<LoginRecord>>('/user/login-records', params);
}

/** 清空登录记录 */
export function clearLoginRecords(): Promise<ApiResponse<null>> {
  return HttpClient.getInstance().delete<null>('/user/login-records');
}

/** 退出登录 */
export function logout(): Promise<ApiResponse<null>> {
  return HttpClient.getInstance().post<null>('/auth/logout');
}
