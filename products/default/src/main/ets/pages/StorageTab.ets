import { SURFACE, TEXT_PRIMARY, TEXT_MUTED, DIVIDER, PRIMARY } from '../constants/CommonConstants';
import { StorageInfo, StorageBreakdown } from '../model/StorageInfo';
import { fetchStorageInfo } from '../api/storageApi';
import {
  formatStorageMB, storageTypeLabel, progressPercent, percentOfTotal, validateStorage
} from '../storage/StoragePresenter';

@Component
export struct StorageTab {
  @State private storageInfo: StorageInfo | null = null;
  @State private loading: boolean = true;
  @State private errorMessage: string = '';
  private active: boolean = false;
  private requestVersion: number = 0;

  aboutToAppear(): void {
    this.active = true;
    this.loadData();
  }

  aboutToDisappear(): void {
    this.active = false;
    this.requestVersion++;
  }

  private async loadData(): Promise<void> {
    const version = ++this.requestVersion;
    this.loading = true;
    this.errorMessage = '';
    try {
      const response = await fetchStorageInfo();
      validateStorage(response.data);
      if (this.active && version === this.requestVersion) this.storageInfo = response.data;
    } catch (error) {
      if (this.active && version === this.requestVersion) {
        this.errorMessage = (error as Error).message || '存储读取失败，请重试';
      }
    } finally {
      if (this.active && version === this.requestVersion) this.loading = false;
    }
  }

  @Builder
  private breakdownRow(item: StorageBreakdown, totalMB: number) {
    Column({ space: 6 }) {
      Row() {
        Text(storageTypeLabel(item.type)).layoutWeight(1).fontColor(TEXT_PRIMARY);
        Text(formatStorageMB(item.used)).fontColor(TEXT_PRIMARY);
      }.width('100%');
      Text('占已用空间 ' + item.percentage + '%')
        .fontSize(12).fontColor(TEXT_MUTED);
      Text('占总容量约 ' + percentOfTotal(item.used, totalMB).toFixed(2) + '%（按MB估算）')
        .fontSize(12).fontColor(TEXT_MUTED);
      Progress({ value: progressPercent(percentOfTotal(item.used, totalMB)), total: 100, type: ProgressType.Linear })
        .width('100%').color(PRIMARY);
    }
    .width('100%').padding({ top: 12, bottom: 12 })
    .border({ width: { bottom: 1 }, color: DIVIDER });
  }

  @Builder
  private storageContent(info: StorageInfo) {
    Column({ space: 12 }) {
      Text('存储空间使用情况').fontSize(16).fontColor(TEXT_PRIMARY);
      Text(formatStorageMB(info.usedSpace) + ' / ' + formatStorageMB(info.totalSpace))
        .fontSize(18).fontColor(TEXT_PRIMARY);
      Progress({ value: progressPercent(info.usagePercentage), total: 100, type: ProgressType.Linear })
        .width('100%').color(PRIMARY);
      Text('已用 ' + info.usagePercentage + '%，可用 ' + formatStorageMB(info.availableSpace))
        .fontColor(TEXT_MUTED);
      if (info.usedSpace > info.totalSpace || info.availableSpace < 0) {
        Text('服务端存储数据提示已用超过总容量，请核对统计。').fontColor(TEXT_PRIMARY);
      }
      Text('文件数：' + info.filesCount).fontColor(TEXT_PRIMARY);
      Text('服务端更新时间：' + (info.lastUpdated ?? '未提供')).fontColor(TEXT_MUTED);
      if (info.storageBreakdown.length === 0) {
        Text('暂无分类统计').fontColor(TEXT_MUTED);
      } else {
        ForEach(info.storageBreakdown, (item: StorageBreakdown) => {
          this.breakdownRow(item, info.totalSpace);
        }, (item: StorageBreakdown) => item.type);
      }
      Text('容量按服务端MB数值显示；不足1 MB的部分已由后端舍去。文件夹及部分分类数量尚未接入统计。')
        .fontSize(12).fontColor(TEXT_MUTED);
    }
    .width('100%').padding(16).backgroundColor(SURFACE).borderRadius(8);
  }

  build() {
    Column({ space: 12 }) {
      if (this.loading) {
        Text('正在读取存储空间...').fontColor(TEXT_MUTED);
      }
      if (this.errorMessage) {
        Text(this.errorMessage).fontColor(TEXT_PRIMARY);
        if (this.storageInfo !== null) {
          Text('以下为上次成功读取的数据。').fontColor(TEXT_MUTED);
        }
      }
      if (this.storageInfo !== null) {
        this.storageContent(this.storageInfo);
      }
      Button(this.loading ? '读取中...' : '重新读取存储')
        .enabled(!this.loading).onClick(() => this.loadData());
    }
    .width('100%').padding({ left: 18, right: 18, top: 24 });
  }
}
