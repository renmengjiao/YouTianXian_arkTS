import { promptAction } from '@kit.ArkUI';
import {
  PRIMARY, SURFACE, TEXT_PRIMARY, TEXT_SECONDARY, DIVIDER, TEXT_MUTED, BORDER
} from '../constants/CommonConstants';

@Component
export struct BasicInfoTab {
  @Link name: string;
  @Link phone: string;
  @Link email: string;
  @Link department: string;

  build() {
    Column({ space: 20 }) {
      // ================= 1. 顶部用户信息区 =================
      Row() {
        Text(this.name.slice(0, 1))
          .width(64).height(64)
          .textAlign(TextAlign.Center)
          .fontSize(26).fontWeight(FontWeight.Bold)
          .fontColor(Color.White).backgroundColor(PRIMARY).borderRadius(32);

        Column({ space: 6 }) {
          Text(this.name).fontSize(18).fontWeight(FontWeight.Bold).fontColor(TEXT_PRIMARY);
          Text('天线工程师 · 华为终端 BG').fontSize(12).fontColor(TEXT_MUTED);
          Text('更换头像').fontSize(13).fontColor(PRIMARY).onClick(() => {});
        }
        .alignItems(HorizontalAlign.Start).margin({ left: 16 });
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      // ================= 2. 表单区 =================

      // 姓名（昵称）
      Column({ space: 4 }) {
        Text('昵称').fontSize(12).fontColor(TEXT_MUTED).width('100%');
        TextInput({ text: this.name })
          .width('100%').height(36).fontSize(14).fontColor(TEXT_PRIMARY)
          .backgroundColor(Color.Transparent)
          .padding({ left: 0, right: 0 })
          .onChange((value: string) => this.name = value);
      }
      .width('100%').alignItems(HorizontalAlign.Start)
      .border({ width: { bottom: 1 }, color: BORDER });

      // 手机号
      Column({ space: 4 }) {
        Text('手机号').fontSize(12).fontColor(TEXT_MUTED).width('100%');
        TextInput({ text: this.phone })
          .width('100%').height(36).fontSize(14).fontColor(TEXT_PRIMARY)
          .backgroundColor(Color.Transparent)
          .padding({ left: 0, right: 0 })
          .onChange((value: string) => this.phone = value);
      }
      .width('100%').alignItems(HorizontalAlign.Start)
      .border({ width: { bottom: 1 }, color: BORDER });

      // 邮箱
      Column({ space: 4 }) {
        Text('邮箱').fontSize(12).fontColor(TEXT_MUTED).width('100%');
        TextInput({ text: this.email })
          .width('100%').height(36).fontSize(14).fontColor(TEXT_PRIMARY)
          .backgroundColor(Color.Transparent)
          .padding({ left: 0, right: 0 })
          .onChange((value: string) => this.email = value);
      }
      .width('100%').alignItems(HorizontalAlign.Start)
      .border({ width: { bottom: 1 }, color: BORDER });

      // 部门
      Column({ space: 4 }) {
        Text('部门').fontSize(12).fontColor(TEXT_MUTED).width('100%');
        TextInput({ text: this.department })
          .width('100%').height(36).fontSize(14).fontColor(TEXT_PRIMARY)
          .backgroundColor(Color.Transparent)
          .padding({ left: 0, right: 0 })
          .onChange((value: string) => this.department = value);
      }
      .width('100%').alignItems(HorizontalAlign.Start)
      .border({ width: { bottom: 1 }, color: BORDER });

      // ================= 3. 保存按钮 =================
      Button('保存修改')
        .width(120).height(40)
        .fontSize(14).fontColor(TEXT_SECONDARY)
        .backgroundColor(SURFACE)
        .border({ width: 1, color: BORDER })
        .borderRadius(4)
        .margin({ top: 12 })
        .alignSelf(ItemAlign.Start)
        .onClick(() => {
          promptAction.showToast({ message: '保存成功' });
        });
    }
    .layoutWeight(1)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ top: 24 });
  }
}
