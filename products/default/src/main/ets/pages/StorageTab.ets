import { SURFACE, TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, DIVIDER } from '../constants/CommonConstants';
import { StorageInfo, StorageDetail } from '../model/StorageInfo';
import { fetchStorageInfo } from '../api/storageApi';
import { promptAction } from '@kit.ArkUI';

@Component
export struct StorageTab {
  onLoaded: (info: StorageInfo) => void = () => {};
  @State private storageInfo: StorageInfo | null = null;
  @State private loading: boolean = false;

  aboutToAppear(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.loading = true;
    try {
      const resp = await fetchStorageInfo();
      if (resp.code === 200) {
        this.storageInfo = resp.data;
        this.onLoaded(resp.data);
      }
    } catch (e) {
      promptAction.showToast({ message: (e as Error).message });
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      if (this.loading && !this.storageInfo) {
        Text('加载中...')
          .fontSize(14).fontColor(TEXT_MUTED)
          .margin({ top: 40 });
      } else if (!this.storageInfo) {
        Text('暂无数据')
          .fontSize(14).fontColor(TEXT_MUTED)
          .margin({ top: 40 });
      } else {
        // ── 总览 ──
        Column({ space: 8 }) {
          Row() {
            Text('存储空间使用情况')
              .fontSize(14).fontWeight(FontWeight.Bold).fontColor(TEXT_PRIMARY);
            Blank();
            Text(this.storageInfo.usedSpace)
              .fontSize(14).fontWeight(FontWeight.Bold).fontColor(TEXT_PRIMARY);
            Text(' / ' + this.storageInfo.totalSpace)
              .fontSize(13).fontColor(TEXT_MUTED);
          }
          .width('100%');

          // 圆角进度条
          Row() {
            // 各分类色块
            if (this.storageInfo.details) {
              ForEach(this.storageInfo.details, (detail: StorageDetail) => {
                Row()
                  .width(detail.percent + '%')
                  .height(12)
                  .backgroundColor(detail.color)
                  .borderRadius(6);
              }, (detail: StorageDetail) => detail.category);
            }
            // 空闲段
            if (this.storageInfo.usedPercent < 100) {
              Row()
                .layoutWeight(1)
                .height(12)
                .backgroundColor('#E0E0E0')
                .borderRadius(6);
            }
          }
          .width('100%');

          Text('已用 ' + this.storageInfo.usedPercent + '%')
            .fontSize(12).fontColor(TEXT_MUTED);
        }
        .width('100%')
        .padding(16)
        .backgroundColor(SURFACE)
        .borderRadius(8);

        // ── 分类详情 ──
        if (this.storageInfo.details && this.storageInfo.details.length > 0) {
          Column({ space: 0 }) {
            ForEach(this.storageInfo.details, (detail: StorageDetail) => {
              Row() {
                Row()
                  .width(10).height(10)
                  .backgroundColor(detail.color)
                  .borderRadius(5)
                  .margin({ right: 10 });

                Text(detail.category)
                  .fontSize(14).fontColor(TEXT_PRIMARY)
                  .layoutWeight(1);

                Text(detail.size)
                  .fontSize(14).fontColor(TEXT_PRIMARY);

                Text(' ' + detail.usedPercent + '%')
                  .fontSize(12).fontColor(TEXT_MUTED);
              }
              .width('100%')
              .padding({ top: 14, bottom: 14 })
              .border({ width: { bottom: 1 }, color: DIVIDER });
            }, (detail: StorageDetail) => detail.category);
          }
          .width('100%')
          .padding(16)
          .backgroundColor(SURFACE)
          .borderRadius(8)
          .margin({ top: 12 });
        }
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18 });
  }
}
