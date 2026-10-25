import { HttpClient, ApiResponse, PageData } from './httpClient';
import { UploadRecord } from '../model/CommonModels';
import { PageDto, UploadDto, adaptUpload, adaptPage } from './BackendAdapters';
interface PageQuery { page: number; pageSize: number; }
interface ClearBody { clearAll: boolean; }
export async function fetchUploadRecords(page: number, pageSize: number): Promise<ApiResponse<PageData<UploadRecord>>> {
  const params: PageQuery = { page: page, pageSize: pageSize };
  const res = await HttpClient.getInstance().get<PageDto<UploadDto>>('/user/upload-records', params);
  const pageData = adaptPage<UploadDto>(res.data);
  const data: PageData<UploadRecord> = { items: pageData.items.map((item: UploadDto): UploadRecord => adaptUpload(item)),
    total: pageData.total, page: pageData.page, page_size: pageData.page_size };
  return { code: res.code, message: res.message, data: data };
}
export function clearUploadRecords(): Promise<ApiResponse<null>> {
  const body: ClearBody = { clearAll: true };
  return HttpClient.getInstance().deleteJson<null>('/user/upload-records', body);
}
