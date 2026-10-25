/**
 * 模板管理 API
 * 覆盖模板从存储、复用、分享到分享的完整流程
 */
import { HttpClient, ApiResponse, PageData } from './httpClient';
import {
  TemplateInfo, TemplateFilter, ShareLinkRequest,
  PublishToPublicRequest, ReceiveTemplateRequest,
  FavoriteAction, SharePermission, StructureParam,
  AntennaType, FrequencyBand, TemplateStatus
} from '../model/TemplateInfo';
import {
  TemplateDto, TemplatePageDto, adaptTemplate,
  adaptTemplatePage, ShareLinkDto,
  TemplateListDto
} from './BackendAdapters';

// ==================== 基础 CRUD ====================

/** 获取模板列表（模板广场） */
export async function fetchPublicTemplates(
  filter: TemplateFilter
): Promise<ApiResponse<PageData<TemplateInfo>>> {
  const params: Record<string, Object> = {
    page: filter.page,
    pageSize: filter.pageSize
  };
  if (filter.antennaType) params.antennaType = filter.antennaType;
  if (filter.frequencyBands && filter.frequencyBands.length > 0) {
    params.frequencyBands = filter.frequencyBands.join(',');
  }
  if (filter.keyword) params.keyword = filter.keyword;
  if (filter.dateRange && filter.dateRange !== 'all') params.dateRange = filter.dateRange;
  if (filter.downloadStatus) params.downloadStatus = filter.downloadStatus;
  if (filter.sortBy) params.sortBy = filter.sortBy;
  if (filter.sortOrder) params.sortOrder = filter.sortOrder;

  const res = await HttpClient.getInstance().get<TemplatePageDto>('/templates/public', params);
  const pageData = adaptTemplatePage(res.data);
  return {
    code: res.code,
    message: res.message,
    data: pageData
  };
}

/** 获取我的模板列表 */
export async function fetchMyTemplates(
  filter: TemplateFilter
): Promise<ApiResponse<PageData<TemplateInfo>>> {
  const params: Record<string, Object> = {
    page: filter.page,
    pageSize: filter.pageSize
  };
  if (filter.antennaType) params.antennaType = filter.antennaType;
  if (filter.frequencyBands && filter.frequencyBands.length > 0) {
    params.frequencyBands = filter.frequencyBands.join(',');
  }
  if (filter.keyword) params.keyword = filter.keyword;
  if (filter.dateRange && filter.dateRange !== 'all') params.dateRange = filter.dateRange;
  if (filter.sortBy) params.sortBy = filter.sortBy;
  if (filter.sortOrder) params.sortOrder = filter.sortOrder;

  const res = await HttpClient.getInstance().get<TemplatePageDto>('/templates/my', params);
  const pageData = adaptTemplatePage(res.data);
  return {
    code: res.code,
    message: res.message,
    data: pageData
  };
}

/** 获取模板详情 */
export async function fetchTemplateDetail(
  templateId: string
): Promise<ApiResponse<TemplateInfo>> {
  const res = await HttpClient.getInstance().get<TemplateDto>(`/templates/${templateId}`);
  return {
    code: res.code,
    message: res.message,
    data: adaptTemplate(res.data)
  };
}

/** 新增模板（三步完成） */
export async function createTemplate(
  formData: FormData
): Promise<ApiResponse<TemplateInfo>> {
  const res = await HttpClient.getInstance().postForm<TemplateDto>(
    '/templates/create',
    formData
  );
  return {
    code: res.code,
    message: res.message,
    data: adaptTemplate(res.data)
  };
}

/** 删除模板 */
export async function deleteTemplate(
  templateId: string
): Promise<ApiResponse<null>> {
  return await HttpClient.getInstance().delete<null>(`/templates/${templateId}`);
}

/** 上传aedt文件（第一步） */
export async function uploadAedtFile(
  fileUri: string
): Promise<ApiResponse<{ fileUrl: string; fileName: string }>> {
  const formData = new FormData();
  formData.append('file', fileUri);
  return await HttpClient.getInstance().postForm<{ fileUrl: string; fileName: string }>(
    '/templates/upload/aedt',
    formData
  );
}

/** 上传图片（第二步中） */
export async function uploadTemplateImage(
  fileUri: string
): Promise<ApiResponse<{ imageUrl: string }>> {
  const formData = new FormData();
  formData.append('file', fileUri);
  return await HttpClient.getInstance().postForm<{ imageUrl: string }>(
    '/templates/upload/image',
    formData
  );
}

/** 上传详情文档（pdf/word） */
export async function uploadDetailDoc(
  fileUri: string
): Promise<ApiResponse<{ docUrl: string }>> {
  const formData = new FormData();
  formData.append('file', fileUri);
  return await HttpClient.getInstance().postForm<{ docUrl: string }>(
    '/templates/upload/doc',
    formData
  );
}

// ==================== 下载 ====================

/** 下载模板（添加到我的模板库） */
export async function downloadTemplate(
  templateId: string
): Promise<ApiResponse<TemplateInfo>> {
  const res = await HttpClient.getInstance().post<TemplateDto>(
    `/templates/${templateId}/download`,
    {}
  );
  return {
    code: res.code,
    message: res.message,
    data: adaptTemplate(res.data)
  };
}

// ==================== 分享 ====================

/** 生成分享链接 */
export async function generateShareLink(
  request: ShareLinkRequest
): Promise<ApiResponse<{ shareLink: string; shareCode: string; expireAt: string }>> {
  return await HttpClient.getInstance().post<{ shareLink: string; shareCode: string; expireAt: string }>(
    `/templates/${request.templateId}/share`,
    {
      permission: request.permission,
      expireInHours: request.expireInHours,
      note: request.note
    }
  );
}

/** 接收模板（通过分享码） */
export async function receiveSharedTemplate(
  request: ReceiveTemplateRequest
): Promise<ApiResponse<TemplateInfo>> {
  const res = await HttpClient.getInstance().post<TemplateDto>(
    '/templates/receive',
    { shareCode: request.shareCode }
  );
  return {
    code: res.code,
    message: res.message,
    data: adaptTemplate(res.data)
  };
}

// ==================== 收藏 ====================

/** 收藏/取消收藏模板 */
export async function toggleFavorite(
  action: FavoriteAction
): Promise<ApiResponse<null>> {
  if (action.favorited) {
    return await HttpClient.getInstance().post<null>(
      `/templates/${action.templateId}/favorite`,
      {}
    );
  } else {
    return await HttpClient.getInstance().delete<null>(
      `/templates/${action.templateId}/favorite`
    );
  }
}

/** 获取已收藏的模板列表 */
export async function fetchFavoriteTemplates(
  page: number,
  pageSize: number
): Promise<ApiResponse<PageData<TemplateInfo>>> {
  const params = { page, pageSize };
  const res = await HttpClient.getInstance().get<TemplatePageDto>('/templates/favorites', params);
  const pageData = adaptTemplatePage(res.data);
  return {
    code: res.code,
    message: res.message,
    data: pageData
  };
}

// ==================== 发布到公共库 ====================

/** 上传模板至平台公共模板库 */
export async function publishToPublic(
  request: PublishToPublicRequest
): Promise<ApiResponse<null>> {
  return await HttpClient.getInstance().post<null>(
    `/templates/${request.templateId}/publish`,
    { noteToAdmin: request.noteToAdmin }
  );
}

// ==================== 刷新 ====================

/** 刷新（同步云盘模板数据） */
export async function refreshTemplates(): Promise<ApiResponse<null>> {
  return await HttpClient.getInstance().post<null>('/templates/sync', {});
}
