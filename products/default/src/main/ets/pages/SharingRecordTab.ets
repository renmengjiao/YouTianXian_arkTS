import { promptAction } from '@kit.ArkUI';
import { SURFACE, TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, DIVIDER, PRIMARY, BORDER } from '../constants/CommonConstants';
import { ShareRecord } from '../model/CommonModels';
import { fetchSharedRecords, deleteSharedRecord } from '../api/shareApi';

@Component
export struct SharingRecordTab {
  @State private records: ShareRecord[] = [];
  @State private loading: boolean = false;
  @State private page: number = 1;
  @State private total: number = 0;

  aboutToAppear(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.loading = true;
    try {
      const resp = await fetchSharedRecords(this.page, 10);
      if (resp.code === 200) {
        this.records = resp.data.items;
        this.total = resp.data.total;
      }
    } catch (e) {
      console.error('Failed to load shared records', JSON.stringify(e));
    } finally {
      this.loading = false;
    }
  }

  private async handleDelete(id: number): Promise<void> {
    try {
      const resp = await deleteSharedRecord(id);
      if (resp.code === 200) {
        promptAction.showToast({ message: '删除成功', duration: 1500 });
        this.loadData();
      }
    } catch (e) {
      promptAction.showToast({ message: '删除失败', duration: 1500 });
    }
  }

  build() {
    Column() {
      if (this.loading && this.records.length === 0) {
        Text('加载中...')
          .fontSize(14).fontColor(TEXT_MUTED)
          .margin({ top: 40 });
      } else if (this.records.length === 0) {
        Text('暂无共享记录')
          .fontSize(14).fontColor(TEXT_MUTED)
          .margin({ top: 40 });
      } else {
        List({ space: 8 }) {
          ForEach(this.records, (item: ShareRecord) => {
            ListItem() {
              Row() {
                Image($r('app.media.folder'))
                  .width(20).height(20)
                  .margin({ right: 16 });

                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(14).fontColor(TEXT_PRIMARY);
                  Text(item.sharedBy + ' 分享 · ' + item.sharedDate)
                    .fontSize(12).fontColor(TEXT_MUTED);
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);

                Row() {
                  Button('打开项目')
                    .fontSize(12).fontColor(TEXT_SECONDARY)
                    .backgroundColor(Color.Transparent)
                    .border({ width: 1, color: BORDER })
                    .borderRadius(12)
                    .height(28)
                    .onClick(() => {
                      promptAction.showToast({ message: '打开项目: ' + (item.projectId ?? String(item.id)), duration: 1500 });
                    });

                  Button('删除')
                    .fontSize(12).fontColor(Color.White)
                    .backgroundColor('#E53935')
                    .borderRadius(12)
                    .height(28)
                    .margin({ left: 8 })
                    .onClick(() => {
                      this.handleDelete(item.id);
                    });
                }
              }
              .width('100%')
              .padding(12)
              .backgroundColor(SURFACE)
              .borderRadius(8);
            }
          }, (item: ShareRecord) => String(item.id));
        }
        .width('100%');

        // 分页信息
        if (this.total > 10) {
          Row() {
            Text('共 ' + this.total + ' 条记录')
              .fontSize(12).fontColor(TEXT_MUTED);
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 12 });
        }
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18 });
  }
}
