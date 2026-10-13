import { ApiError, ApiErrorKind } from '../api/httpClient';
import { StorageInfo } from '../model/StorageInfo';

export function formatStorageMB(value: number): string {
  if (value >= 1024 * 1024) {
    return (value / (1024 * 1024)).toFixed(2) + ' TB';
  }
  return value >= 1024 ? (value / 1024).toFixed(2) + ' GB' : value + ' MB';
}

export function storageTypeLabel(type: string): string {
  if (type === 'project') return '项目';
  if (type === 'template') return '模板';
  if (type === 'other') return '其他（含结果和报告）';
  return type;
}

/** 仅用于进度条宽度；不改变显示的服务端数值。 */
export function progressPercent(value: number): number {
  return Math.max(0, Math.min(100, value));
}

export function percentOfTotal(usedMB: number, totalMB: number): number {
  return totalMB > 0 ? usedMB * 100 / totalMB : 0;
}

export function validateStorage(data: StorageInfo): void {
  if (!data || !Number.isSafeInteger(data.totalSpace) || data.totalSpace < 0
    || !Number.isSafeInteger(data.usedSpace) || data.usedSpace < 0
    || !Number.isSafeInteger(data.availableSpace)
    || !Number.isFinite(data.usagePercentage)
    || !Number.isSafeInteger(data.filesCount) || data.filesCount < 0
    || !Number.isSafeInteger(data.foldersCount) || data.foldersCount < 0
    || (data.lastUpdated !== null && typeof data.lastUpdated !== 'string')
    || !Array.isArray(data.storageBreakdown)) {
    throw new ApiError(ApiErrorKind.RESPONSE, '存储响应不完整，请重新读取');
  }
  for (const item of data.storageBreakdown) {
    if (!item || typeof item.type !== 'string'
      || !Number.isSafeInteger(item.used) || item.used < 0
      || !Number.isFinite(item.percentage)
      || !Number.isSafeInteger(item.count) || item.count < 0) {
      throw new ApiError(ApiErrorKind.RESPONSE, '存储分类响应不完整，请重新读取');
    }
  }
}
