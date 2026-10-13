/** 后端用户资料 DTO；ID 保留数字字符串。 */
export interface UserInfo {
  userId: string;
  username: string;
  nickname: string;
  avatar: string | null;
  email: string | null;
  phone: string | null;
  department: string | null;
  role: string | null;
  createTime: string | null;
  lastLoginTime: string | null;
}

/** 仅提交发生变化的可编辑字段；手机号不能用空字符串解绑。 */
export interface ProfileUpdate {
  nickname?: string;
  email?: string;
  phone?: string;
  department?: string;
}

export interface LoginRequest {
  account: string;
  password: string;
}

export interface RegisterRequest {
  username: string;
  nickname: string;
  password: string;
  phone?: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
  user: UserInfo;
}

export interface RefreshTokenRequest {
  refreshToken: string;
}

export interface PasswordUpdate {
  oldPassword: string;
  newPassword: string;
}

export interface NotificationChannel {
  enabled: boolean;
  threshold?: number | null;
  email: boolean;
  push: boolean;
  inApp: boolean;
}

export interface NotificationSettings {
  simulationComplete: NotificationChannel;
  resourceWarning: NotificationChannel;
  systemUpdate: NotificationChannel;
  TeamCollaborationMessage: NotificationChannel;
  lastUpdated: string | null;
}

/** 部分更新；不发送服务端管理的 lastUpdated。 */
export interface NotificationChannelUpdate {
  enabled?: boolean;
  threshold?: number;
  email?: boolean;
  push?: boolean;
  inApp?: boolean;
}

export interface NotificationSettingsUpdate {
  simulationComplete?: NotificationChannelUpdate;
  resourceWarning?: NotificationChannelUpdate;
  systemUpdate?: NotificationChannelUpdate;
  TeamCollaborationMessage?: NotificationChannelUpdate;
}

export interface NotificationUpdateResult {
  updated: boolean;
  lastUpdated: string | null;
}
