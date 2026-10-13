/** 后端存储 DTO，容量统一为数值 MB。 */
export interface StorageInfo {
  totalSpace: number;
  usedSpace: number;
  availableSpace: number;
  usagePercentage: number;
  filesCount: number;
  foldersCount: number;
  lastUpdated: string | null;
  storageBreakdown: StorageBreakdown[];
}

export interface StorageBreakdown {
  type: string;
  used: number;
  percentage: number; // 占已用空间百分比，服务端按字节计算并取整。
  count: number;
}
