import { SURFACE, TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, DIVIDER, PRIMARY,BORDER } from '../constants/CommonConstants';

@Component
export struct SharingRecordTab {
  build() {
    Column() {
      List({ space: 8 }) {
        // ---- 条目 1 ----
        ListItem() {
          Row() {
            Image($r('app.media.folder'))
              .width(20).height(20)
              .margin({ right: 16 })

            Column({ space: 4 }) {
              Text('5G毫米波无线阵列设计')
                .fontSize(14).fontColor(TEXT_PRIMARY);
              Text('team_lead 分享 · 2026-07-15')
                .fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Row() {
              Button('打开项目')
                .fontSize(12).fontColor(TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: BORDER })
                .borderRadius(4)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .margin({ left: 16 });
            }
          }
          .height(64)
          .padding({ left: 16, right: 16 });
        }

        // ---- 条目 2（模板） ----
        ListItem() {
          Row() {
            Image($r('app.media.template'))
              .width(20).height(20)
              .margin({ right: 16 })

            Column({ space: 4 }) {
              Text('毫米波天线设计模板')
                .fontSize(14).fontColor(TEXT_PRIMARY);
              Text('zhang_wei 分享 · 2026-07-14')
                .fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Row() {
              Button('使用模板')
                .fontSize(12).fontColor(TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: BORDER })
                .borderRadius(4)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .margin({ left: 16 });
            }
          }
          .height(64)
          .padding({ left: 16, right: 16 });
        }

        // ---- 条目 3 ----
        ListItem() {
          Row() {
            Image($r('app.media.image'))
              .width(20).height(20)
              .margin({ right: 16 })

            Column({ space: 4 }) {
              Text('S11参数对比图表')
                .fontSize(14).fontColor(TEXT_PRIMARY);
              Text('li_ming 分享 · 2026-07-14')
                .fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Row() {
              Button('查看图片')
                .fontSize(12).fontColor(TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: BORDER })
                .borderRadius(4)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .margin({ left: 16 });
            }
          }
          .height(64)
          .padding({ left: 16, right: 16 });
        }

        // ---- 条目 4 ----
        ListItem() {
          Row() {
            Image($r('app.media.folder'))
              .width(20).height(20)
              .margin({ right: 16 })

            Column({ space: 4 }) {
              Text('天线方向图分析数据')
                .fontSize(14).fontColor(TEXT_PRIMARY);
              Text('wang-fang 分享 · 2026-07-14')
                .fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Row() {
              Button('查看图片')
                .fontSize(12).fontColor(TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: BORDER })
                .borderRadius(4)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .margin({ left: 16 });
            }
          }
          .height(64)
          .padding({ left: 16, right: 16 });
        }
      }
      .divider({ strokeWidth: 1, color: DIVIDER, startMargin: 16, endMargin: 16 })
      .width('100%')
      .height('100%');
    }
    .padding({ top: 24 });
  }
}
