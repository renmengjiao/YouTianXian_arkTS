import { HttpClient, ApiResponse, PageData } from './httpClient';
import { UploadRecord, UploadRecordFilter, ClearUploadRecordsRequest, ClearRecordsResult } from '../model/CommonModels';

interface PageParams extends UploadRecordFilter { page: number; pageSize: number; }

export function fetchUploadRecords(page: number, pageSize: number,
  filter: UploadRecordFilter = {}): Promise<ApiResponse<PageData<UploadRecord>>> {
  const params: PageParams = { page: page, pageSize: pageSize };
  if (filter.startTime?.trim()) params.startTime = filter.startTime.trim();
  if (filter.endTime?.trim()) params.endTime = filter.endTime.trim();
  if (filter.status && filter.status !== 'all') params.status = filter.status;
  return HttpClient.getInstance().get<PageData<UploadRecord>>('/user/upload-records', params);
}

/** 仅清理日志，不删除文件或释放存储。 */
export function clearUploadRecords(body: ClearUploadRecordsRequest): Promise<ApiResponse<ClearRecordsResult>> {
  return HttpClient.getInstance().deleteJson<ClearRecordsResult>('/user/upload-records', body);
}
