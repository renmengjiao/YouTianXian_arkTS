/**
 * 模板数据模型
 * 覆盖模板从存储、复用、分享到迭代的完整流程
 */

/** 天线类型枚举 */
export enum AntennaType {
  MICROSTRIP_PATCH = 'microstrip_patch',     // 微带贴片天线
  MONOPOLE = 'monopole',                     // 单极子天线
  DIPOLE = 'dipole',                         // 偶极子天线
  HORN = 'horn',                             // 喇叭天线
  PATCH_ARRAY = 'patch_array',               // 贴片阵列天线
  BEAMFORMING = 'beamforming',               // 波束成形阵列
  HELIX = 'helix',                           // 螺旋天线
  FOLDED_DIPOLE = 'folded_dipole',           // 折叠偶极子天线
  LOOP = 'loop',                             // 环形天线
  YAGI = 'yagi',                             // 八木天线
  OTHER = 'other'                            // 其他
}

export const ANTENNA_TYPE_LABELS: Record<string, string> = {
  'microstrip_patch': '微带贴片天线',
  'monopole': '单极子天线',
  'dipole': '偶极子天线',
  'horn': '喇叭天线',
  'patch_array': '贴片阵列天线',
  'beamforming': '波束成形阵列',
  'helix': '螺旋天线',
  'folded_dipole': '折叠偶极子天线',
  'loop': '环形天线',
  'yagi': '八木天线',
  'other': '其他'
};

/** 工作频段标签 */
export enum FrequencyBand {
  BAND_700M = '700M',
  BAND_900M = '900M',
  BAND_1800M = '1800M',
  BAND_2100M = '2100M',
  BAND_2_6G = '2.6G',
  BAND_3_5G = '3.5G',
  BAND_WIFI_2_4G = '2.4G(WiFi/蓝牙)',
  BAND_WIFI_5G = '5G(WiFi)',
  BAND_WIFI_6G = '6G(WiFi)',
  BAND_5G_NR = '5G NR',
  BAND_NFC = '13.56M(NFC)',
  BAND_GPS = '1.5G(GPS)',
  BAND_BLUETOOTH = '2.4G(蓝牙)',
  BAND_MMWAVE = '毫米波',
  BAND_OTHER = '其他'
}

export const FREQUENCY_BAND_LABELS: Record<string, string> = {
  '700M': '700M',
  '900M': '900M',
  '1800M': '1800M',
  '2100M': '2100M',
  '2.6G': '2.6G',
  '3.5G': '3.5G',
  '2.4G(WiFi/蓝牙)': '2.4G(WiFi/蓝牙)',
  '5G(WiFi)': '5G(WiFi)',
  '6G(WiFi)': '6G(WiFi)',
  '5G NR': '5G NR',
  '13.56M(NFC)': '13.56M(NFC)',
  '1.5G(GPS)': '1.5G(GPS)',
  '2.4G(蓝牙)': '2.4G(蓝牙)',
  '毫米波': '毫米波',
  '其他': '其他'
};

/** 结构优化参数 */
export interface StructureParam {
  paramName: string;    // 参数名称
  defaultValue: number; // 默认值
  minValue: number;     // 最小值
  maxValue: number;     // 最大值
  unit?: string;        // 单位
}

/** 分享权限 */
export enum SharePermission {
  VIEW_ONLY = 'view_only',       // 仅查看模板
  CAN_EDIT = 'can_edit'          // 可编辑模板
}

export const SHARE_PERMISSION_LABELS: Record<string, string> = {
  'view_only': '仅查看模板',
  'can_edit': '可编辑模板'
};

/** 模板状态 */
export enum TemplateStatus {
  PRIVATE = 'private',       // 私人模板（仅自己可见）
  PUBLIC = 'public',         // 公共模板（平台广场可见）
  SHARED = 'shared',         // 已分享（通过链接分享）
  FAVORITED = 'favorited'    // 已收藏
}

/** 上传步骤 */
export enum AddTemplateStep {
  UPLOAD_AEDT = 1,   // 上传aedt文件
  BASIC_INFO = 2,    // 基本信息填写
  DEFINE_PARAMS = 3  // 定义优化结构参数
}

/**
 * 模板完整信息
 */
export interface TemplateInfo {
  id: string;
  name: string;                           // 模板名称
  antennaType: AntennaType;               // 天线类型
  frequencyBands: FrequencyBand[];        // 工作频段（多选标签）
  description: string;                    // 简述（必填）
  detailDescription?: string;             // 详情描述（可选）
  detailDocUrl?: string;                  // 详情文档链接（pdf/word）
  imageUrl: string;                       // 模板示例图片URL
  aedtFileUrl: string;                    // aedt文件URL
  structureParams: StructureParam[];      // 结构参数列表
  status: TemplateStatus;                 // 模板状态
  isFavorited?: boolean;                  // 是否已收藏
  ownerId: string;                        // 所属用户ID
  ownerName: string;                      // 所属用户名
  createdAt: string;                      // 创建时间
  updatedAt?: string;                     // 更新时间
  downloadCount: number;                  // 下载次数
  useCount: number;                       // 使用次数
  rating?: number;                        // 评分
  tags: string[];                         // 自定义标签
  /** 分享相关 */
  shareLink?: string;                     // 分享链接
  sharePermission?: SharePermission;      // 分享权限
  shareExpireAt?: string;                 // 分享过期时间
}

/**
 * 模板列表查询过滤条件
 */
export interface TemplateFilter {
  antennaType?: AntennaType;              // 按天线类型筛选
  frequencyBands?: FrequencyBand[];       // 按工作频段筛选
  keyword?: string;                       // 关键词搜索
  dateRange?: '7days' | '30days' | 'all'; // 创建时间范围
  downloadStatus?: 'downloaded' | 'not_downloaded'; // 下载状态
  sortBy?: 'name' | 'createdAt' | 'downloadCount' | 'rating'; // 排序字段
  sortOrder?: 'asc' | 'desc';            // 排序方向
  page: number;
  pageSize: number;
}

/**
 * 分享链接生成请求
 */
export interface ShareLinkRequest {
  templateId: string;
  permission: SharePermission;
  expireInHours: number;                  // 有效期（小时）
  note?: string;                          // 附加说明
}

/**
 * 上传到公共模板库请求
 */
export interface PublishToPublicRequest {
  templateId: string;
  noteToAdmin?: string;                   // 给管理员的说明
}

/**
 * 接收模板请求（通过链接）
 */
export interface ReceiveTemplateRequest {
  shareCode: string;                      // 分享码/链接中的code
}

/**
 * 收藏操作
 */
export interface FavoriteAction {
  templateId: string;
  favorited: boolean;
}
