import { HttpClient } from './httpClient';

/** baseUrl 包含 /api；头像根路径必须与主机 origin 拼接。 */
export function resolveAvatarUrl(path: string | null): string {
  if (!path) {
    return '';
  }
  if (/^https?:\/\//.test(path)) {
    return path;
  }
  const origin = HttpClient.getInstance().getBaseUrl().match(/^https?:\/\/[^/]+/);
  if (!origin) {
    return '';
  }
  return origin[0] + (path.startsWith('/') ? path : '/' + path);
}
