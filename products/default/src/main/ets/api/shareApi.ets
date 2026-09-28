/**
 * 共享记录 API
 */
import { HttpClient, ApiResponse, PageData } from './httpClient';
import { ShareRecord } from '../model/CommonModels';

/** 分页参数 */
interface PageParams {
  page: number;
  page_size: number;
}

/** 获取共享记录（分页） */
export function fetchSharedRecords(page: number, pageSize: number): Promise<ApiResponse<PageData<ShareRecord>>> {
  const params: PageParams = { page: page, page_size: pageSize };
  return HttpClient.getInstance().get<PageData<ShareRecord>>('/user/shared-records', params);
}

/** 删除共享记录 */
export function deleteSharedRecord(id: number): Promise<ApiResponse<null>> {
  return HttpClient.getInstance().delete<null>(`/user/shared-records/${id}`);
}
