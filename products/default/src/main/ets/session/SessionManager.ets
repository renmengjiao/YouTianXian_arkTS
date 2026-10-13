import { login, register, refresh, logout } from '../api/userApi';
import { HttpClient, ApiResponse, ApiError, ApiErrorKind } from '../api/httpClient';
import { LoginRequest, RegisterRequest, LoginResponse, UserInfo } from '../model/UserInfo';
import { SessionStore } from './SessionStore';

interface ActiveSession {
  refreshToken: string;
  remember: boolean;
  user: UserInfo;
}

export interface LogoutResult {
  remoteRevoked: boolean;
  storageCleared: boolean;
}

export class SessionManager {
  private static instance: SessionManager;
  private session: ActiveSession | null = null;
  private generation: number = 0;
  private refreshFlight: Promise<void> | null = null;
  private restoreFlight: Promise<UserInfo | null> | null = null;
  private storeTail: Promise<void> = Promise.resolve();
  private listener: ((user: UserInfo | null) => void) | null = null;

  private constructor() {
    HttpClient.getInstance().setSessionHandlers(
      () => this.refreshSession(), () => this.expire());
  }

  static getInstance(): SessionManager {
    if (!SessionManager.instance) {
      SessionManager.instance = new SessionManager();
    }
    return SessionManager.instance;
  }

  setListener(listener: ((user: UserInfo | null) => void) | null): void {
    this.listener = listener;
  }

  getSessionGeneration(): number {
    return this.generation;
  }

  assertCurrentUser(userId: string, generation: number): void {
    if (!this.session || generation !== this.generation
      || userId !== this.session.user.userId) {
      throw this.cancelled();
    }
  }

  updateProfile(profile: UserInfo, generation: number): void {
    this.assertCurrentUser(profile.userId, generation);
    const current = this.session;
    if (!current) {
      throw this.cancelled();
    }
    current.user = profile;
    this.notify(profile);
  }

  private notify(user: UserInfo | null): void {
    if (this.listener) {
      this.listener(user);
    }
  }

  private resetMemory(): number {
    this.generation++;
    this.session = null;
    this.refreshFlight = null;
    HttpClient.getInstance().setToken('');
    this.notify(null);
    return this.generation;
  }

  private cancelled(): ApiError {
    return new ApiError(ApiErrorKind.UNAUTHORIZED, '登录状态已变化，请重新操作', 0, 401);
  }

  private writeStored(refreshToken: string, remember: boolean,
    generation: number): Promise<void> {
    const work = this.storeTail.then(async () => {
      if (generation !== this.generation) {
        throw this.cancelled();
      }
      if (remember) {
        await SessionStore.save({
          backendUrl: HttpClient.getInstance().getBaseUrl(),
          refreshToken: refreshToken
        });
      } else {
        await SessionStore.clear();
      }
    });
    this.storeTail = work.catch(() => {});
    return work;
  }

  private validate(data: LoginResponse): void {
    if (!data || typeof data.accessToken !== 'string' || !data.accessToken
      || typeof data.refreshToken !== 'string' || !data.refreshToken
      || data.tokenType !== 'Bearer'
      || typeof data.expiresIn !== 'number' || !Number.isFinite(data.expiresIn)
      || data.expiresIn <= 0 || !data.user
      || typeof data.user.userId !== 'string' || !/^\d+$/.test(data.user.userId)
      || typeof data.user.username !== 'string'
      || typeof data.user.nickname !== 'string') {
      throw new ApiError(ApiErrorKind.RESPONSE, '认证响应不完整，请联系服务端');
    }
  }

  private async revokeUnused(refreshToken: string): Promise<void> {
    try {
      await logout(refreshToken);
    } catch {
      // 不覆盖原有错误，也不记录令牌。
    }
  }

  private async install(data: LoginResponse, remember: boolean,
    generation: number, rotated: boolean): Promise<UserInfo> {
    try {
      this.validate(data);
      if (generation !== this.generation) {
        throw this.cancelled();
      }
      await this.writeStored(data.refreshToken, remember, generation);
      if (generation !== this.generation) {
        throw this.cancelled();
      }
      this.session = {
        refreshToken: data.refreshToken, remember: remember, user: data.user
      };
      const expiresAt = Date.now() + data.expiresIn * 1000;
      if (rotated) {
        HttpClient.getInstance().rotateToken(data.accessToken, expiresAt);
      } else {
        HttpClient.getInstance().setToken(data.accessToken, expiresAt);
        this.notify(data.user);
      }
      return data.user;
    } catch (error) {
      if (data && typeof data.refreshToken === 'string' && data.refreshToken) {
        await this.revokeUnused(data.refreshToken);
      }
      throw error as Error;
    }
  }

  private async authenticate(
    action: () => Promise<ApiResponse<LoginResponse>>,
    remember: boolean): Promise<UserInfo> {
    const generation = this.resetMemory();
    try {
      await this.writeStored('', false, generation);
      const response = await action();
      return await this.install(response.data, remember, generation, false);
    } catch (error) {
      if (generation === this.generation) {
        try {
          await this.expire();
        } catch {
          // 原始错误交给界面显示；内存会话已经清除。
        }
      }
      throw error as Error;
    }
  }

  login(data: LoginRequest, remember: boolean): Promise<UserInfo> {
    return this.authenticate(() => login(data), remember);
  }

  register(data: RegisterRequest, remember: boolean): Promise<UserInfo> {
    return this.authenticate(() => register(data), remember);
  }

  private async performRestore(): Promise<UserInfo | null> {
    const generation = this.resetMemory();
    try {
      await this.storeTail;
      const stored = await SessionStore.read();
      if (generation !== this.generation) {
        throw this.cancelled();
      }
      if (!stored) {
        return null;
      }
      if (stored.backendUrl !== HttpClient.getInstance().getBaseUrl()) {
        await this.writeStored('', false, generation);
        return null;
      }
      const response = await refresh(stored.refreshToken);
      return await this.install(response.data, true, generation, false);
    } catch (error) {
      if (generation === this.generation) {
        try {
          await this.expire();
        } catch {
          // 内存会话已清除，原始错误交给界面显示。
        }
      }
      throw error as Error;
    }
  }

  async restore(): Promise<UserInfo | null> {
    if (this.session) {
      return this.session.user;
    }
    if (this.restoreFlight) {
      return this.restoreFlight;
    }
    const work = this.performRestore();
    this.restoreFlight = work;
    try {
      return await work;
    } finally {
      if (this.restoreFlight === work) {
        this.restoreFlight = null;
      }
    }
  }

  private async performRefresh(current: ActiveSession,
    generation: number): Promise<void> {
    try {
      const response = await refresh(current.refreshToken);
      await this.install(response.data, current.remember, generation, true);
    } catch (error) {
      if (generation === this.generation) {
        try {
          await this.expire();
        } catch {
          // 不覆盖刷新失败的原始错误。
        }
      }
      throw error as Error;
    }
  }

  async refreshSession(): Promise<void> {
    if (this.refreshFlight) {
      return this.refreshFlight;
    }
    if (!this.session) {
      throw new ApiError(ApiErrorKind.UNAUTHORIZED, '请重新登录', 0, 401);
    }
    const work = this.performRefresh(this.session, this.generation);
    this.refreshFlight = work;
    try {
      await work;
    } finally {
      if (this.refreshFlight === work) {
        this.refreshFlight = null;
      }
    }
  }

  async expire(): Promise<void> {
    const generation = this.resetMemory();
    await this.writeStored('', false, generation);
  }

  async logout(): Promise<LogoutResult> {
    const current = this.session;
    const generation = this.resetMemory();
    let storageCleared = true;
    let remoteRevoked = true;
    try {
      await this.writeStored('', false, generation);
    } catch {
      storageCleared = false;
    }
    if (current) {
      try {
        await logout(current.refreshToken);
      } catch {
        remoteRevoked = false;
      }
    }
    return { remoteRevoked: remoteRevoked, storageCleared: storageCleared };
  }
}
