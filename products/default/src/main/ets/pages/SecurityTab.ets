import { SURFACE, TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, DIVIDER, PRIMARY,BORDER } from '../constants/CommonConstants';

@Component
export struct SecurityTab {
  build() {
    Column() {
      List({ space: 8 }) {
        // 登录密码
        ListItem() {
          Row() {
            Image($r('app.media.lock'))
              .width(20).height(20)
              .margin({ right: 12 })

            Column({ space: 4 }) {
              Text('登录密码').fontSize(14).fontColor(TEXT_PRIMARY);
              Text('上次修改：2026年6月').fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Button('修改')
              .fontSize(12).fontColor(TEXT_SECONDARY)
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: BORDER })
              .borderRadius(4)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 });
          }
          .height(64).padding({ left: 16, right: 16 });
        }

        // 手机号绑定
        ListItem() {
          Row() {
            Image($r('app.media.phone'))
              .width(20).height(20)
              .margin({ right: 16 })

            Column({ space: 4 }) {
              Text('手机号绑定').fontSize(14).fontColor(TEXT_PRIMARY);
              Text('已绑定 138****8888').fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Button('更换')
              .fontSize(12).fontColor(TEXT_SECONDARY)
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: BORDER })
              .borderRadius(4)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 });
          }
          .height(64).padding({ left: 16, right: 16 });
        }

        // 生物识别
        ListItem() {
          Row() {
            Image($r('app.media.fingerprint'))
              .width(20).height(20)
              .margin({ right: 16 })

            Column({ space: 4 }) {
              Text('生物识别').fontSize(14).fontColor(TEXT_PRIMARY);
              Text('指纹 / 面容解锁').fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Button('开启')
              .fontSize(12).fontColor(TEXT_SECONDARY)
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: BORDER })
              .borderRadius(4)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 });
          }
          .height(64).padding({ left: 16, right: 16 });
        }

        // 两步验证
        ListItem() {
          Row() {
            Image($r('app.media.shield'))
              .width(20).height(20)
              .margin({ right: 16 })

            Column({ space: 4 }) {
              Text('两步验证').fontSize(14).fontColor(TEXT_PRIMARY);
              Text('增加额外安全保护').fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Button('管理')
              .fontSize(12).fontColor(TEXT_SECONDARY)
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: BORDER })
              .borderRadius(4)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 });
          }
          .height(64).padding({ left: 16, right: 16 });
        }
      }
      .divider({ strokeWidth: 1, color: DIVIDER, startMargin: 16, endMargin: 16 })
      .width('100%');

      Blank().layoutWeight(1);

      Row() {
        Image($r('app.media.logout')).width(20).height(20).margin({ right: 8 });
        Text('退出登录').fontSize(14).fontColor(TEXT_SECONDARY);
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .height(48)
      .onClick(() => {});
    }
    .layoutWeight(1)
    .width('100%')
    .height('100%')
    .padding(24)
    .backgroundColor(SURFACE)
    .borderRadius(12);
  }
}
