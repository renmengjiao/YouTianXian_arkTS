/**
 * 用户相关 API
 */
import { HttpClient, ApiResponse } from './httpClient';
import { UserInfo, LoginRequest, RegisterRequest, LoginResponse,
  PasswordUpdate, NotificationSettings } from '../model/UserInfo';
import { LoginRecord } from '../model/CommonModels';
import { PageData } from './httpClient';
import { AuthDto, ProfileDto, adaptAuth, adaptProfile, EditableProfile, profileBody } from './BackendAdapters';

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

interface RefreshBody { refreshToken: string; }

/** 登录 */
export async function login(data: LoginRequest): Promise<ApiResponse<LoginResponse>> {
  const res = await HttpClient.getInstance().postPublic<AuthDto>('/auth/login', data);
  return { code: res.code, message: res.message, data: adaptAuth(res.data) };
}

export async function refresh(refreshToken: string): Promise<ApiResponse<LoginResponse>> {
  const body: RefreshBody = { refreshToken: refreshToken };
  const res = await HttpClient.getInstance().postPublic<AuthDto>('/auth/refresh', body);
  return { code: res.code, message: res.message, data: adaptAuth(res.data) };
}

/** 注册 */
export function register(data: RegisterRequest): Promise<ApiResponse<LoginResponse>> {
  return HttpClient.getInstance().post<LoginResponse>('/auth/register', data);
}

/** 获取用户信息 */
export async function fetchUserProfile(): Promise<ApiResponse<UserInfo>> {
  const res = await HttpClient.getInstance().get<ProfileDto>('/user/profile');
  return { code: res.code, message: res.message, data: adaptProfile(res.data) };
}

/** 编辑用户信息 */
export function updateUserProfile(data: EditableProfile, previousPhone: string = ''): Promise<ApiResponse<null>> {
  return HttpClient.getInstance().put<null>('/user/profile', profileBody(data, previousPhone));
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
export function logout(refreshToken: string = ''): Promise<ApiResponse<null>> {
  const body: RefreshBody = { refreshToken: refreshToken };
  return HttpClient.getInstance().postPublic<null>('/auth/logout', body);
}
