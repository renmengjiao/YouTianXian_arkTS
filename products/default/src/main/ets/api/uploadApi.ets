/**
 * 上传记录 API
 */
import { HttpClient, ApiResponse, PageData } from './httpClient';
import { UploadRecord } from '../model/CommonModels';

/** 分页参数 */
interface PageParams {
  page: number;
  page_size: number;
}

/** 获取上传记录（分页） */
export function fetchUploadRecords(page: number, pageSize: number): Promise<ApiResponse<PageData<UploadRecord>>> {
  const params: PageParams = { page: page, page_size: pageSize };
  return HttpClient.getInstance().get<PageData<UploadRecord>>('/user/upload-records', params);
}

/** 清空上传记录 */
export function clearUploadRecords(): Promise<ApiResponse<null>> {
  return HttpClient.getInstance().delete<null>('/user/upload-records');
}
