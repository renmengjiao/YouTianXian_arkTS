/**
 * HTTP 请求客户端封装
 * 基于 @ohos.net.http 实现 GET / POST / PUT / DELETE
 */
import { http } from '@kit.NetworkKit';
import { API_BASE_URL, REQUEST_TIMEOUT_MS } from '../config/ApiConfig';

/** 统一后端响应格式 */
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

/** 分页数据包装 */
export interface PageData<T> {
  list: T[];
  total: number;
  page: number;
  pageSize: number;
}

/** 请求选项 */
export interface RequestOptions {
  method: http.RequestMethod;
  path: string;
  params?: object;
  body?: object;
  timeout?: number;
  multipart?: http.MultiFormData[];
  skipAuth?: boolean;
}

export enum ApiErrorKind {
  NETWORK = 'network',
  HTTP = 'http',
  BUSINESS = 'business',
  UNAUTHORIZED = 'unauthorized',
  RESPONSE = 'response'
}

export class ApiError extends Error {
  kind: ApiErrorKind;
  httpStatus: number;
  businessCode: number;

  constructor(kind: ApiErrorKind, message: string,
    httpStatus: number = 0, businessCode: number = 0) {
    super(message);
    this.kind = kind;
    this.httpStatus = httpStatus;
    this.businessCode = businessCode;
  }
}

export class HttpClient {
  private static instance: HttpClient;

  private baseUrl: string = API_BASE_URL;
  private token: string = '';
  private expiresAt: number = 0;
  private sessionGeneration: number = 0;
  private refreshHandler: (() => Promise<void>) | null = null;
  private expiredHandler: (() => Promise<void>) | null = null;

  static getInstance(): HttpClient {
    if (!HttpClient.instance) {
      HttpClient.instance = new HttpClient();
    }
    return HttpClient.instance;
  }

  setToken(token: string, expiresAt: number = 0): void {
    this.sessionGeneration++;
    this.token = token;
    this.expiresAt = expiresAt;
  }

  rotateToken(token: string, expiresAt: number): void {
    this.token = token;
    this.expiresAt = expiresAt;
  }

  getBaseUrl(): string {
    return this.baseUrl;
  }

  setSessionHandlers(refresh: () => Promise<void>,
    expired: () => Promise<void>): void {
    this.refreshHandler = refresh;
    this.expiredHandler = expired;
  }

  private checkGeneration(generation: number): void {
    if (generation !== this.sessionGeneration) {
      throw new ApiError(ApiErrorKind.UNAUTHORIZED, '登录状态已变化，请重新操作', 0, 401);
    }
  }

  private async expireIfCurrent(generation: number): Promise<void> {
    if (generation === this.sessionGeneration && this.expiredHandler) {
      await this.expiredHandler();
    }
  }

  getToken(): string {
    return this.token;
  }

  /** 设置 baseUrl（可在 app 启动时调用） */
  async setBaseUrl(url: string): Promise<void> {
    const normalized = url.trim().replace(/\/+$/, '');
    if (normalized === this.baseUrl) {
      return;
    }
    this.setToken('');
    if (this.expiredHandler) {
      await this.expiredHandler();
    }
    this.baseUrl = normalized;
  }

  private buildUrl(path: string, params?: object): string {
    let url = `${this.baseUrl}${path}`;
    if (params) {
      const entries: string[] = [];
      const keys: string[] = Object.keys(params);
      for (let i = 0; i < keys.length; i++) {
        const k: string = keys[i];
        const v: object = (params as Record<string, object>)[k];
        entries.push(`${encodeURIComponent(k)}=${encodeURIComponent(String(v))}`);
      }
      if (entries.length > 0) {
        url += '?' + entries.join('&');
      }
    }
    return url;
  }

  private parseResponse<T>(response: http.HttpResponse): ApiResponse<T> {
    const status = response.responseCode;
    if (status === 401) {
      throw new ApiError(ApiErrorKind.UNAUTHORIZED,
        '未登录或令牌已过期', status, 401);
    }

    let body: ApiResponse<T>;
    try {
      body = typeof response.result === 'string'
        ? JSON.parse(response.result) as ApiResponse<T>
        : response.result as ApiResponse<T>;
    } catch {
      throw new ApiError(status === 200 ? ApiErrorKind.RESPONSE : ApiErrorKind.HTTP,
        status === 200 ? '后端响应格式异常' : `HTTP ${status}`, status);
    }

    if (status !== 200) {
      const message = body && typeof body.message === 'string'
        ? body.message : `HTTP ${status}`;
      throw new ApiError(ApiErrorKind.HTTP, message, status);
    }
    if (!body || typeof body.code !== 'number'
      || typeof body.message !== 'string' || body.data === undefined) {
      throw new ApiError(ApiErrorKind.RESPONSE, '后端响应格式异常', status);
    }
    if (body.code === 401) {
      throw new ApiError(ApiErrorKind.UNAUTHORIZED, body.message, status, body.code);
    }
    if (body.code !== 200) {
      throw new ApiError(ApiErrorKind.BUSINESS, body.message, status, body.code);
    }
    return body;
  }

  private async send<T>(options: RequestOptions): Promise<ApiResponse<T>> {
    const conn = http.createHttp();
    try {
      const url = this.buildUrl(options.path, options.params);
      const headers: Record<string, string> = {
        'Content-Type': options.multipart ? 'multipart/form-data' : 'application/json',
        'User-Agent': 'YouTianXian (HarmonyOS)'
      };
      if (!options.skipAuth && this.token) {
        headers['Authorization'] = `Bearer ${this.token}`;
      }

      let response: http.HttpResponse;
      try {
        response = await conn.request(url, {
          method: options.method,
          header: headers,
          extraData: options.multipart ? undefined
            : options.body ? JSON.stringify(options.body) : undefined,
          multiFormDataList: options.multipart,
          connectTimeout: options.timeout ?? REQUEST_TIMEOUT_MS,
          readTimeout: options.timeout ?? REQUEST_TIMEOUT_MS,
          expectDataType: http.HttpDataType.OBJECT
        });
      } catch {
        throw new ApiError(ApiErrorKind.NETWORK,
          '请求失败或超时，请检查后端地址与网络连接');
      }
      return this.parseResponse<T>(response);
    } finally {
      conn.destroy();
    }
  }

  async request<T>(options: RequestOptions): Promise<ApiResponse<T>> {
    if (options.skipAuth) {
      return this.send<T>(options);
    }
    const generation = this.sessionGeneration;
    if (this.token && this.expiresAt > 0 && Date.now() >= this.expiresAt
      && this.refreshHandler) {
      await this.refreshHandler();
    }
    this.checkGeneration(generation);
    const sentToken = this.token;
    try {
      const response = await this.send<T>(options);
      this.checkGeneration(generation);
      return response;
    } catch (error) {
      const failure = error as ApiError;
      if (!(failure instanceof ApiError)
        || failure.kind !== ApiErrorKind.UNAUTHORIZED
        || generation !== this.sessionGeneration) {
        throw error as Error;
      }
      if (!this.token || !this.refreshHandler) {
        await this.expireIfCurrent(generation);
        throw error as Error;
      }
      if (this.token === sentToken) {
        await this.refreshHandler();
      }
      this.checkGeneration(generation);
      try {
        const response = await this.send<T>(options);
        this.checkGeneration(generation);
        return response;
      } catch (retryError) {
        const retryFailure = retryError as ApiError;
        if (retryFailure instanceof ApiError
          && retryFailure.kind === ApiErrorKind.UNAUTHORIZED) {
          await this.expireIfCurrent(generation);
        }
        throw retryError as Error;
      }
    }
  }

  postPublic<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    return this.request<T>({
      method: http.RequestMethod.POST, path: path, body: body, skipAuth: true
    });
  }

  get<T>(path: string, params?: object): Promise<ApiResponse<T>> {
    return this.request<T>({ method: http.RequestMethod.GET, path: path, params: params });
  }

  post<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    return this.request<T>({ method: http.RequestMethod.POST, path: path, body: body });
  }

  put<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    return this.request<T>({ method: http.RequestMethod.PUT, path: path, body: body });
  }

  delete<T>(path: string, params?: object): Promise<ApiResponse<T>> {
    return this.request<T>({ method: http.RequestMethod.DELETE, path: path, params: params });
  }

  deleteJson<T>(path: string, body: object): Promise<ApiResponse<T>> {
    return this.request<T>({ method: http.RequestMethod.DELETE, path: path, body: body });
  }

  postMultipart<T>(path: string, parts: http.MultiFormData[]): Promise<ApiResponse<T>> {
    return this.request<T>({ method: http.RequestMethod.POST, path: path, multipart: parts });
  }
}
