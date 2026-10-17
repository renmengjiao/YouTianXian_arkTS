/** 用户信息 */
export interface UserInfo {
  id: string;
  userId: string;
  nickname: string;
  username: string;
  name: string;
  email: string;
  phone: string;
  department: string;
  title: string;           // 职位
  organization: string;    // 所属组织
  avatar?: string;         // 头像 URL
}

/** 登录请求 */
export interface LoginRequest {
  account: string;
  password: string;
}

/** 注册请求 */
export interface RegisterRequest {
  username: string;
  password: string;
  name: string;
  email: string;
}

/** 登录响应 */
export interface LoginResponse {
  token: string; // Legacy registration branch is deliberately outside this alignment.
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
  user: UserInfo;
}

/** 修改密码请求 */
export interface PasswordUpdate {
  oldPassword: string;
  newPassword: string;
}

/** 通知设置 */
export interface NotificationSettings {
  systemNotify: boolean;      // 系统通知
  taskNotify: boolean;        // 任务通知
  messageNotify: boolean;     // 消息通知
  emailNotify: boolean;       // 邮件通知
}
