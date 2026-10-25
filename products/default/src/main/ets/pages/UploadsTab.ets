import { promptAction } from '@kit.ArkUI';
import { SURFACE, TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, DIVIDER, PRIMARY, BORDER } from '../constants/CommonConstants';
import { UploadRecord } from '../model/CommonModels';
import { fetchUploadRecords, clearUploadRecords } from '../api/uploadApi';

@Component
export struct UploadsTab {
  @State private records: UploadRecord[] = [];
  @State private loading: boolean = false;
  @State private page: number = 1;
  @State private total: number = 0;

  aboutToAppear(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.loading = true;
    try {
      const resp = await fetchUploadRecords(this.page, 10);
      if (resp.code === 200) {
        this.records = resp.data.items;
        this.total = resp.data.total;
      }
    } catch (e) {
      promptAction.showToast({ message: (e as Error).message });
    } finally {
      this.loading = false;
    }
  }

  private async handleClear(): Promise<void> {
    try {
      const resp = await clearUploadRecords();
      if (resp.code === 200) {
        promptAction.showToast({ message: '已清空所有记录', duration: 1500 });
        await this.loadData();
      }
    } catch (e) {
      promptAction.showToast({ message: '清空失败', duration: 1500 });
    }
  }

  private statusText(status: string): string {
    if (status === 'completed') { return '已完成'; }
    if (status === 'uploading') { return '上传中'; }
    if (status === 'failed') { return '失败'; }
    if (status === 'pending') { return '待处理'; }
    if (status === 'rejected') { return '已拒绝'; }
    return status;
  }

  private statusColor(status: string): ResourceColor {
    if (status === 'completed') { return '#4CAF50'; }
    if (status === 'uploading') { return '#FF9800'; }
    if (status === 'failed') { return '#E53935'; }
    return TEXT_MUTED;
  }

  private statusBg(status: string): ResourceColor {
    if (status === 'completed') { return '#E8F5E9'; }
    if (status === 'uploading') { return '#FFF3E0'; }
    if (status === 'failed') { return '#FFEBEE'; }
    return '#F5F5F5';
  }

  build() {
    Column() {
      if (this.loading && this.records.length === 0) {
        Text('加载中...')
          .fontSize(14).fontColor(TEXT_MUTED)
          .margin({ top: 40 });
      } else if (this.records.length === 0) {
        Text('暂无上传记录')
          .fontSize(14).fontColor(TEXT_MUTED)
          .margin({ top: 40 });
      } else {
        List({ space: 8 }) {
          ForEach(this.records, (item: UploadRecord) => {
            ListItem() {
              Row() {
                Image($r('app.media.folder'))
                  .width(20).height(20)
                  .margin({ right: 16 });

                Column({ space: 4 }) {
                  Text(item.fileName)
                    .fontSize(14).fontColor(TEXT_PRIMARY);
                  Text(item.fileSize + ' · ' + item.uploadTime)
                    .fontSize(12).fontColor(TEXT_MUTED);
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);

                // 状态标签
                Text(this.statusText(item.status))
                  .fontSize(12)
                  .fontColor(this.statusColor(item.status))
                  .backgroundColor(this.statusBg(item.status))
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .borderRadius(10);
              }
              .width('100%')
              .padding(12)
              .backgroundColor(SURFACE)
              .borderRadius(8);
            }
          }, (item: UploadRecord) => String(item.id));
        }
        .width('100%');

        // 清空按钮
        Button('清空所有记录')
          .width('100%').height(44)
          .fontSize(14).fontColor(Color.White)
          .backgroundColor('#E53935')
          .borderRadius(8)
          .margin({ top: 16 })
          .onClick(() => {
            this.handleClear();
          });
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18 });
  }
}
