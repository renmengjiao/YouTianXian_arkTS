import { promptAction } from '@kit.ArkUI';
import { SURFACE, TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, DIVIDER, PRIMARY, BORDER, DANGER } from '../constants/CommonConstants';
import { fetchUserProfile, changePassword, logout } from '../api/userApi';
import { UserInfo } from '../model/UserInfo';

@CustomDialog
struct PasswordDialog {
  controller: CustomDialogController;
  @State private oldPwd: string = '';
  @State private newPwd: string = '';
  @State private confirmPwd: string = '';
  @State private errorMsg: string = '';
  @State private submitting: boolean = false;
  onConfirm: (oldPwd: string, newPwd: string) => Promise<void> = async () => {};

  build() {
    Column({ space: 12 }) {
      Text('修改密码')
        .fontSize(16).fontColor(TEXT_PRIMARY).fontWeight(500);

      TextInput({ placeholder: '请输入旧密码', text: this.oldPwd })
        .type(InputType.Password)
        .height(40)
        .onChange((v) => { this.oldPwd = v; this.errorMsg = ''; });

      TextInput({ placeholder: '请输入新密码', text: this.newPwd })
        .type(InputType.Password)
        .height(40)
        .onChange((v) => { this.newPwd = v; this.errorMsg = ''; });

      TextInput({ placeholder: '请确认新密码', text: this.confirmPwd })
        .type(InputType.Password)
        .height(40)
        .onChange((v) => { this.confirmPwd = v; this.errorMsg = ''; });

      if (this.errorMsg) {
        Text(this.errorMsg).fontSize(12).fontColor(DANGER);
      }

      Row({ space: 12 }) {
        Button('取消')
          .fontSize(14).fontColor(TEXT_SECONDARY)
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: BORDER })
          .borderRadius(6)
          .height(36)
          .layoutWeight(1)
          .onClick(() => { this.controller.close(); });

        Button('确定')
          .fontSize(14).fontColor(Color.White)
          .backgroundColor(PRIMARY)
          .borderRadius(6)
          .height(36)
          .layoutWeight(1)
          .enabled(!this.submitting)
          .onClick(() => {
            if (!this.oldPwd || !this.newPwd || !this.confirmPwd) {
              this.errorMsg = '请填写所有字段';
              return;
            }
            if (this.newPwd !== this.confirmPwd) {
              this.errorMsg = '两次密码输入不一致';
              return;
            }
            if (this.newPwd.length < 6) {
              this.errorMsg = '新密码长度不能少于6位';
              return;
            }
            this.submitting = true;
            this.onConfirm(this.oldPwd, this.newPwd).then(() => {
              this.controller.close();
            }).catch(() => {
              this.errorMsg = '修改失败，请重试';
              this.submitting = false;
            });
          });
      }
      .width('100%');
    }
    .padding(24)
    .width('100%');
  }
}

@Component
export struct SecurityTab {
  onLogout: () => Promise<void> = async () => {};
  @State private userInfo: UserInfo | null = null;
  @State private maskedPhone: string = '暂无数据';

  private pwdDialogController: CustomDialogController | null = null;

  aboutToAppear() {
    this.loadUserData();
    this.pwdDialogController = new CustomDialogController({
      builder: PasswordDialog({
        onConfirm: async (oldPwd, newPwd) => {
          const res = await changePassword({ oldPassword: oldPwd, newPassword: newPwd });
          if (res.code !== 200) {
            throw new Error(res.message);
          }
          promptAction.showToast({ message: '密码修改成功', duration: 2000 });
        }
      }),
      alignment: DialogAlignment.Center,
      customStyle: true,
      cornerRadius: 12,
      width: '85%'
    });
  }

  async loadUserData() {
    try {
      const res = await fetchUserProfile();
      if (res.code === 200 && res.data) {
        this.userInfo = res.data;
        const p = res.data.phone || '';
        if (p.length === 11) {
          this.maskedPhone = p.substring(0, 3) + '****' + p.substring(7);
        } else if (p) {
          this.maskedPhone = p.substring(0, 3) + '****' + p.substring(p.length - 4);
        }
      }
    } catch (e) {
      console.error('[SecurityTab] 加载用户数据失败', e);
    }
  }

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
              Text('上次修改：暂无数据').fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Button('修改')
              .fontSize(12).fontColor(TEXT_SECONDARY)
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: BORDER })
              .borderRadius(4)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .onClick(() => {
                this.pwdDialogController?.open();
              });
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
              Text(this.userInfo?.phone ? '已绑定 ' + this.maskedPhone : '未绑定').fontSize(12).fontColor(TEXT_MUTED);
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
      .onClick(() => {
        AlertDialog.show({
          title: '退出登录',
          message: '确定要退出当前账号吗？',
          primaryButton: {
            value: '取消',
            action: () => {}
          },
          secondaryButton: {
            value: '确定',
            action: async () => {
              try {
                await this.onLogout();
              } catch (e) {
                console.error('[SecurityTab] 退出失败', e);
              }

            }
          }
        });
      });
    }
    .layoutWeight(1)
    .width('100%')
    .height('100%')
    .padding(24)
    .backgroundColor(SURFACE)
    .borderRadius(12);
  }
}
