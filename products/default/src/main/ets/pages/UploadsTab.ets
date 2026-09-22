import { SURFACE, TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, DIVIDER, PRIMARY,BORDER } from '../constants/CommonConstants';

@Component
export struct UploadsTab {
  build() {
    Column() {
      List({ space: 8 }) {
        // ---- 条目 1 ----
        ListItem() {
          Row() {
            // 左侧图标
            Image($r('app.media.template'))
              .width(20).height(20)
              .margin({ right: 16 })

            // 中间区域：上下两层
            Column({ space: 4 }) {
              // 第一行：文件名 + 状态标签
              Row() {
                Text('5G NR天线参数计算模板')
                  .fontSize(14).fontColor(TEXT_PRIMARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Text('审核中')
                  .fontSize(12).fontColor('#34C759')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(4)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .margin({ left: 16 });
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center);

              // 第二行：文件详情（辅助文字）
              Text('天线阵列 · 8.4 MB · 2026-08-30 14:32')
                .fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            // 右侧操作按钮
            Row({ space: 8 }) {
              Button('审核进度')
                .fontSize(12).fontColor(TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: BORDER })
                .borderRadius(4)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 });
              Button('查看详情')
                .fontSize(12).fontColor(TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: BORDER })
                .borderRadius(4)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 });
            }
          }
          .height(64)
          .padding({ left: 16, right: 16 });
        }

        // ---- 条目 2 ----
        ListItem() {
          Row() {
            Image($r('app.media.template'))
              .width(20).height(20)
              .margin({ right: 16 })

            // 中间区域：上下两层
            Column({ space: 4 }) {
              // 第一行：文件名 + 状态标签
              Row() {
                Text('毫米波束成型阵列模板')
                  .fontSize(14).fontColor(TEXT_PRIMARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Text('已发布')
                  .fontSize(12).fontColor('#007DFF')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(4)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .margin({ left: 16 });
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center);

              // 第二行：文件详情（辅助文字）
              Text('天线阵列 · 8.4 MB · 2026-08-30 14:32')
                .fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Row({ space: 8 }) {
              Button('审核进度')
                .fontSize(12).fontColor(TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: BORDER })
                .borderRadius(4)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 });
              Button('查看详情')
                .fontSize(12).fontColor(TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: BORDER })
                .borderRadius(4)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 });
            }
          }
          .height(64)
          .padding({ left: 16, right: 16 });
        }

        // ---- 条目 3 ----
        ListItem() {
          Row() {
            Image($r('app.media.template'))
              .width(20).height(20)
              .margin({ right: 16 })

            Column({ space: 4 }) {
              // 第一行：文件名 + 状态标签
              Row() {
                Text('微带馈线网络设计模板')
                  .fontSize(14).fontColor(TEXT_PRIMARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Text('已下架')
                  .fontSize(12).fontColor('#6B7280')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(4)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .margin({ left: 16 });
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center);

              // 第二行：文件详情（辅助文字）
              Text('天线阵列 · 8.4 MB · 2026-08-30 14:32')
                .fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Row({ space: 8 }) {
              Button('审核进度')
                .fontSize(12).fontColor(TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: BORDER })
                .borderRadius(4)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 });
              Button('查看详情')
                .fontSize(12).fontColor(TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: BORDER })
                .borderRadius(4)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 });
            }
          }
          .height(64)
          .padding({ left: 16, right: 16 });
        }

        // ---- 条目 4 ----
        ListItem() {
          Row() {
            Image($r('app.media.template'))
              .width(20).height(20)
              .margin({ right: 16 })

            Column({ space: 4 }) {
              // 第一行：文件名 + 状态标签
              Row() {
                Text('同轴天线仿真入门模板')
                  .fontSize(14).fontColor(TEXT_PRIMARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Text('已发布')
                  .fontSize(12).fontColor('#007DFF')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(4)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .margin({ left: 16 });
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center);

              // 第二行：文件详情（辅助文字）
              Text('天线阵列 · 8.4 MB · 2026-08-30 14:32')
                .fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Row({ space: 8 }) {
              Button('审核进度')
                .fontSize(12).fontColor(TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: BORDER })
                .borderRadius(4)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 });
              Button('查看详情')
                .fontSize(12).fontColor(TEXT_SECONDARY)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: BORDER })
                .borderRadius(4)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 });
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
