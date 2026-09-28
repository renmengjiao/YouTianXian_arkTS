/** 存储概览 */
export interface StorageInfo {
  totalSpace: string;        // 总容量，如 "512 GB"
  usedSpace: string;         // 已用容量，如 "422.28 GB"
  usedPercent: number;       // 使用百分比，如 82
  details: StorageDetail[];  // 各分类详情
}

/** 存储分类详情 */
export interface StorageDetail {
  category: string;          // 类别名
  size: string;              // 占用大小，如 "34.5 GB"
  percent: number;           // 占总空间百分比
  usedPercent: number;       // 占已用空间百分比
  color: string;             // 颜色标识
}
