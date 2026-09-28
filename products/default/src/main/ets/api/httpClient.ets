/**
 * HTTP 请求客户端封装
 * 基于 @ohos.net.http 实现 GET / POST / PUT / DELETE
 */
import { http } from '@kit.NetworkKit';

/** 统一后端响应格式 */
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

/** 分页数据包装 */
export interface PageData<T> {
  items: T[];
  total: number;
  page: number;
  page_size: number;
}

/** 请求选项 */
export interface RequestOptions {
  method: http.RequestMethod;
  path: string;
  params?: object;
  body?: object;
  timeout?: number;
}

export class HttpClient {
  private static instance: HttpClient;

  /** ★ 修改为实际后端地址 */
  private baseUrl: string = 'https://api.example.com/api/v1';
  private token: string = '';

  static getInstance(): HttpClient {
    if (!HttpClient.instance) {
      HttpClient.instance = new HttpClient();
    }
    return HttpClient.instance;
  }

  setToken(token: string): void {
    this.token = token;
  }

  getToken(): string {
    return this.token;
  }

  /** 设置 baseUrl（可在 app 启动时调用） */
  setBaseUrl(url: string): void {
    this.baseUrl = url;
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

  async request<T>(options: RequestOptions): Promise<ApiResponse<T>> {
    const conn = http.createHttp();
    try {
      const url = this.buildUrl(options.path, options.params);
      const headers: Record<string, string> = { 'Content-Type': 'application/json' };
      if (this.token) {
        headers['Authorization'] = `Bearer ${this.token}`;
      }
      const resp = await conn.request(url, {
        method: options.method,
        header: headers,
        extraData: options.body ? JSON.stringify(options.body) : undefined,
        connectTimeout: options.timeout ?? 10000,
        readTimeout: options.timeout ?? 10000,
        expectDataType: http.HttpDataType.OBJECT,
      });

      const code = resp.responseCode;
      if (code !== 200) {
        throw new Error(`HTTP ${code}: ${resp.result as string}`);
      }
      return resp.result as ApiResponse<T>;
    } finally {
      conn.destroy();
    }
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
}
