import { HttpClient, ApiResponse, PageData } from './httpClient';
import { ShareRecord, ShareRecordFilter } from '../model/CommonModels';

interface PageParams extends ShareRecordFilter { page: number; pageSize: number; }

export function fetchSharedRecords(page: number, pageSize: number,
  filter: ShareRecordFilter = {}): Promise<ApiResponse<PageData<ShareRecord>>> {
  const params: PageParams = { page: page, pageSize: pageSize };
  if (filter.startTime?.trim()) params.startTime = filter.startTime.trim();
  if (filter.endTime?.trim()) params.endTime = filter.endTime.trim();
  if (filter.fileType && filter.fileType !== 'all') params.fileType = filter.fileType;
  return HttpClient.getInstance().get<PageData<ShareRecord>>('/user/shared-records', params);
}

export function deleteSharedRecord(id: string): Promise<ApiResponse<null>> {
  return HttpClient.getInstance().delete<null>('/user/shared-records/' + encodeURIComponent(id));
}
