import { HttpClient, ApiResponse, PageData } from './httpClient';
import { ShareRecord } from '../model/CommonModels';
import { PageDto, ShareDto, adaptPage, adaptShare } from './BackendAdapters';
interface PageQuery { page: number; pageSize: number; }
export async function fetchSharedRecords(page: number, pageSize: number, sharer: string = ''): Promise<ApiResponse<PageData<ShareRecord>>> {
  const params: PageQuery = { page: page, pageSize: pageSize };
  const res = await HttpClient.getInstance().get<PageDto<ShareDto>>('/user/shared-records', params);
  const pageData = adaptPage<ShareDto>(res.data);
  const data: PageData<ShareRecord> = { items: pageData.items.map((item: ShareDto): ShareRecord => adaptShare(item, sharer)),
    total: pageData.total, page: pageData.page, page_size: pageData.page_size };
  return { code: res.code, message: res.message, data: data };
}
export function deleteSharedRecord(id: string): Promise<ApiResponse<null>> {
  return HttpClient.getInstance().delete<null>(`/user/shared-records/${encodeURIComponent(id)}`);
}
