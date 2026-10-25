import { UserInfo, LoginResponse } from '../model/UserInfo';
import { ShareRecord, UploadRecord } from '../model/CommonModels';
import { StorageInfo, StorageDetail } from '../model/StorageInfo';
import { TemplateInfo, AntennaType, FrequencyBand, TemplateStatus, SharePermission, StructureParam } from '../model/TemplateInfo';
import { PRIMARY, PRIMARY_LIGHT, TEXT_MUTED } from '../constants/CommonConstants';
import { ApiResponse, PageData } from './httpClient';

export interface ProfileDto {
  userId: string; username: string; nickname: string; avatar: string | null;
  email: string | null; phone: string | null; department: string | null;
}
export interface AuthDto {
  accessToken: string; refreshToken: string; tokenType: string; expiresIn: number; user: ProfileDto;
}
export interface PageDto<T> { list: T[]; total: number; page: number; pageSize: number; }
export interface ShareDto { id: string; fileName: string; shareTime: string; }
export interface UploadDto {
  id: string; fileName: string; fileSize: string | null; uploadTime: string;
  uploadStatus: string; uploadProgress: number | null;
}
export interface BreakdownDto { type: string; used: number; percentage: number; count: number; }
export interface StorageDto {
  totalSpace: number; usedSpace: number; usagePercentage: number; storageBreakdown: BreakdownDto[];
}
export interface ProfileBody { nickname: string; email: string; phone?: string; department: string; }
export interface EditableProfile { name: string; email: string; phone: string; department: string; }

export function adaptProfile(dto: ProfileDto): UserInfo {
  if (!dto || typeof dto.userId !== 'string' || !/^\d+$/.test(dto.userId)
    || typeof dto.username !== 'string' || typeof dto.nickname !== 'string') {
    throw new Error('用户资料响应不完整');
  }
  return { id: dto.userId, userId: dto.userId, nickname: dto.nickname, username: dto.username,
    name: dto.nickname, email: dto.email ?? '', phone: dto.phone ?? '', department: dto.department ?? '',
    avatar: dto.avatar ?? '', title: '', organization: '' };
}
export function adaptAuth(dto: AuthDto): LoginResponse {
  return { accessToken: dto.accessToken, refreshToken: dto.refreshToken, tokenType: dto.tokenType,
    expiresIn: dto.expiresIn, token: dto.accessToken, user: adaptProfile(dto.user) };
}
export function adaptPage<T>(dto: PageDto<T>): PageData<T> {
  if (!dto || !Array.isArray(dto.list) || !Number.isFinite(dto.total)) throw new Error('分页响应不完整');
  return { items: dto.list, total: dto.total, page: dto.page, page_size: dto.pageSize };
}
export function adaptShare(dto: ShareDto, sharer: string): ShareRecord {
  return { id: dto.id, title: dto.fileName, sharedBy: sharer, sharedDate: dto.shareTime };
}
export function adaptUpload(dto: UploadDto): UploadRecord {
  return { id: dto.id, fileName: dto.fileName, fileSize: dto.fileSize ?? '暂无数据',
    uploadTime: dto.uploadTime, status: dto.uploadStatus, progress: dto.uploadProgress ?? 0 };
}
export function formatMB(value: number): string {
  if (value >= 1048576) return (value / 1048576).toFixed(2) + ' TB';
  return value >= 1024 ? (value / 1024).toFixed(2) + ' GB' : value + ' MB';
}
export function percent(used: number, total: number): number { return total > 0 ? used * 100 / total : 0; }
export function adaptStorage(dto: StorageDto): StorageInfo {
  if (!dto || !Number.isFinite(dto.totalSpace) || dto.totalSpace < 0
    || !Number.isFinite(dto.usedSpace) || dto.usedSpace < 0 || !Array.isArray(dto.storageBreakdown)) {
    throw new Error('存储响应不完整');
  }
  const details: StorageDetail[] = dto.storageBreakdown.map((item: BreakdownDto): StorageDetail => ({
    category: item.type === 'project' ? '项目' : item.type === 'template' ? '模板' : '其他',
    size: formatMB(item.used), percent: Math.max(0, Math.min(100, percent(item.used, dto.totalSpace))),
    usedPercent: Math.round(percent(item.used, dto.usedSpace) * 100) / 100,
    color: item.type === 'project' ? PRIMARY : item.type === 'template' ? PRIMARY_LIGHT : TEXT_MUTED
  }));
  return { totalSpace: formatMB(dto.totalSpace), usedSpace: formatMB(dto.usedSpace),
    usedPercent: dto.usagePercentage, details: details };
}
export function profileBody(draft: EditableProfile, previousPhone: string): ProfileBody {
  if (previousPhone && !draft.phone.trim()) throw new Error('当前接口不支持解绑手机号');
  const body: ProfileBody = { nickname: draft.name, email: draft.email, department: draft.department };
  if (draft.phone.trim()) body.phone = draft.phone.trim();
  return body;
}

// ==================== 模板 DTO ====================

export interface StructureParamDto {
  paramName: string;
  defaultValue: number;
  minValue: number;
  maxValue: number;
  unit?: string;
}

export interface TemplateDto {
  id: string;
  name: string;
  antennaType: string;
  frequencyBands: string[];
  description: string;
  detailDescription?: string;
  detailDocUrl?: string;
  imageUrl: string;
  aedtFileUrl: string;
  structureParams: StructureParamDto[];
  status: string;
  isFavorited?: boolean;
  ownerId: string;
  ownerName: string;
  createdAt: string;
  updatedAt?: string;
  downloadCount: number;
  useCount: number;
  rating?: number;
  tags: string[];
  shareLink?: string;
  sharePermission?: string;
  shareExpireAt?: string;
}

export type TemplatePageDto = PageDto<TemplateDto>;

/** 适配模板DTO */
export function adaptTemplate(dto: TemplateDto): TemplateInfo {
  return {
    id: dto.id,
    name: dto.name,
    antennaType: dto.antennaType as AntennaType,
    frequencyBands: dto.frequencyBands.map((b: string): FrequencyBand => b as FrequencyBand),
    description: dto.description,
    detailDescription: dto.detailDescription,
    detailDocUrl: dto.detailDocUrl,
    imageUrl: dto.imageUrl,
    aedtFileUrl: dto.aedtFileUrl,
    structureParams: dto.structureParams.map((p: StructureParamDto): StructureParam => ({
      paramName: p.paramName,
      defaultValue: p.defaultValue,
      minValue: p.minValue,
      maxValue: p.maxValue,
      unit: p.unit
    })),
    status: dto.status as TemplateStatus,
    isFavorited: dto.isFavorited,
    ownerId: dto.ownerId,
    ownerName: dto.ownerName,
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
    downloadCount: dto.downloadCount,
    useCount: dto.useCount,
    rating: dto.rating,
    tags: dto.tags,
    shareLink: dto.shareLink,
    sharePermission: dto.sharePermission as SharePermission,
    shareExpireAt: dto.shareExpireAt
  };
}

/** 适配模板分页 */
export function adaptTemplatePage(dto: TemplatePageDto): PageData<TemplateInfo> {
  const pageData = adaptPage<TemplateDto>(dto);
  return {
    items: pageData.items.map((item: TemplateDto): TemplateInfo => adaptTemplate(item)),
    total: pageData.total,
    page: pageData.page,
    page_size: pageData.page_size
  };
}
