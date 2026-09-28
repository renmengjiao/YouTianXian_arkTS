/**
 * 消息相关 API
 */
import { HttpClient, ApiResponse, PageData } from './httpClient';
import { Message } from '../model/CommonModels';

/** 未读计数响应 */
interface UnreadCountResponse {
  count: number;
}

/** 标记已读请求 */
interface MarkReadRequest {
  ids: number[];
}

/** 删除请求 */
interface DeleteIdsRequest {
  ids: string;
}

/** 分页参数 */
interface PageParams {
  page: number;
  page_size: number;
}

/** 获取消息列表（分页） */
export function fetchMessages(page: number, pageSize: number): Promise<ApiResponse<PageData<Message>>> {
  const params: PageParams = { page: page, page_size: pageSize };
  return HttpClient.getInstance().get<PageData<Message>>('/messages', params);
}

/** 获取消息详情 */
export function fetchMessageDetail(id: number): Promise<ApiResponse<Message>> {
  return HttpClient.getInstance().get<Message>(`/messages/${id}`);
}

/** 获取未读消息数 */
export function fetchUnreadCount(): Promise<ApiResponse<UnreadCountResponse>> {
  return HttpClient.getInstance().get<UnreadCountResponse>('/messages/unread-count');
}

/** 标记消息已读 */
export function markMessagesRead(ids: number[]): Promise<ApiResponse<null>> {
  const body: MarkReadRequest = { ids: ids };
  return HttpClient.getInstance().put<null>('/messages/read', body);
}

/** 删除消息 */
export function deleteMessages(ids: number[]): Promise<ApiResponse<null>> {
  const params: DeleteIdsRequest = { ids: ids.join(',') };
  return HttpClient.getInstance().delete<null>('/messages', params);
}
