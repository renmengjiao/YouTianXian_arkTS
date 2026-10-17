import { HttpClient, ApiResponse } from './httpClient';
import { StorageInfo } from '../model/StorageInfo';
import { StorageDto, adaptStorage } from './BackendAdapters';
export async function fetchStorageInfo(): Promise<ApiResponse<StorageInfo>> {
  const res = await HttpClient.getInstance().get<StorageDto>('/user/storage');
  return { code: res.code, message: res.message, data: adaptStorage(res.data) };
}
