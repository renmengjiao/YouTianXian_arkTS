/**
 * 存储 API
 */
import { HttpClient, ApiResponse } from './httpClient';
import { StorageInfo } from '../model/StorageInfo';

/** 获取存储概览 */
export function fetchStorageInfo(): Promise<ApiResponse<StorageInfo>> {
  return HttpClient.getInstance().get<StorageInfo>('/user/storage');
}
