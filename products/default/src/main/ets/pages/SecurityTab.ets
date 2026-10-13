import { promptAction } from '@kit.ArkUI';
import { SURFACE, TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, DIVIDER, PRIMARY, BORDER, DANGER } from '../constants/CommonConstants';
import { changePassword } from '../api/userApi';
import { ApiError, ApiErrorKind } from '../api/httpClient';
import { UserInfo } from '../model/UserInfo';
import { ProfileService } from '../profile/ProfileService';
import { SessionManager } from '../session/SessionManager';
import { LoginRecordsTab } from './LoginRecordsTab';

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
        .enabled(!this.submitting)
        .onChange((v) => { this.oldPwd = v; this.errorMsg = ''; });

      TextInput({ placeholder: '请输入新密码', text: this.newPwd })
        .type(InputType.Password)
        .height(40)
        .enabled(!this.submitting)
        .onChange((v) => { this.newPwd = v; this.errorMsg = ''; });

      TextInput({ placeholder: '请确认新密码', text: this.confirmPwd })
        .type(InputType.Password)
        .height(40)
        .enabled(!this.submitting)
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
          .enabled(!this.submitting)
          .onClick(() => { this.controller.close(); });

        Button('确定')
          .fontSize(14).fontColor(Color.White)
          .backgroundColor(PRIMARY)
          .borderRadius(6)
          .height(36)
          .layoutWeight(1)
          .enabled(!this.submitting)
          .onClick(() => {
            if (!this.oldPwd.trim() || !this.newPwd.trim() || !this.confirmPwd) {
              this.errorMsg = '请填写所有字段';
              return;
            }
            if (this.newPwd !== this.confirmPwd) {
              this.errorMsg = '两次密码输入不一致';
              return;
            }
            if (this.newPwd.length < 6 || this.newPwd.length > 64) {
              this.errorMsg = '新密码长度需在6~64位之间';
              return;
            }
            this.submitting = true;
            this.onConfirm(this.oldPwd, this.newPwd).then(() => {
              this.oldPwd = '';
              this.newPwd = '';
              this.confirmPwd = '';
              this.controller.close();
            }).catch((error: Error) => {
              this.errorMsg = error.message || '修改失败，请重试';
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
  @State private showingLoginRecords: boolean = false;
  onLogout: () => Promise<void> = async () => {};
  onEditProfile: () => void = () => {};
  @State private userInfo: UserInfo | null = null;
  @State private maskedPhone: string = '';
  @State private loading: boolean = true;
  @State private errorMessage: string = '';
  private active: boolean = false;
  private requestVersion: number = 0;

  private pwdDialogController: CustomDialogController | null = null;

  aboutToAppear() {
    this.active = true;
    this.loadUserData();
    this.pwdDialogController = new CustomDialogController({
      builder: PasswordDialog({
        onConfirm: async (oldPwd, newPwd) => {
          const user = this.userInfo;
          if (!user) throw new Error('请先成功读取账号资料');
          const manager = SessionManager.getInstance();
          const generation = manager.getSessionGeneration();
          manager.assertCurrentUser(user.userId, generation);
          try {
            await changePassword({ oldPassword: oldPwd, newPassword: newPwd });
          } catch (error) {
            manager.assertCurrentUser(user.userId, generation);
            const failure = error as ApiError;
            if (failure instanceof ApiError && (failure.kind === ApiErrorKind.NETWORK
              || failure.kind === ApiErrorKind.RESPONSE || failure.httpStatus >= 500)) {
              throw new Error('密码修改结果未确认，请退出后尝试用新密码登录核对。' + failure.message);
            }
            throw error as Error;
          }
          manager.assertCurrentUser(user.userId, generation);
          if (this.active) {
            promptAction.showToast({ message: '密码修改成功', duration: 2000 });
          }
        }
      }),
      alignment: DialogAlignment.Center,
      customStyle: true,
      autoCancel: false,
      cornerRadius: 12,
      width: '85%'
    });
  }

  aboutToDisappear(): void {
    this.active = false;
    this.requestVersion++;
    this.pwdDialogController?.close();
  }

  private async loadUserData(): Promise<void> {
    const version = ++this.requestVersion;
    this.loading = true;
    this.errorMessage = '';
    this.userInfo = null;
    this.maskedPhone = '';
    try {
      const snapshot = await ProfileService.load();
      if (this.active && version === this.requestVersion) {
        this.userInfo = snapshot.profile;
        const phone = snapshot.profile.phone ?? '';
        this.maskedPhone = phone.length === 11
          ? phone.substring(0, 3) + '****' + phone.substring(7)
          : (phone ? '号码格式待核对' : '');
      }
    } catch (error) {
      if (this.active && version === this.requestVersion) {
        this.errorMessage = (error as Error).message || '账号资料读取失败';
      }
    } finally {
      if (this.active && version === this.requestVersion) this.loading = false;
    }
  }

  build() {
    if (this.showingLoginRecords) {
      LoginRecordsTab({ onBack: () => this.showingLoginRecords = false });
    } else {
      this.securityContent();
    }
  }

  @Builder
  private securityContent() {
    Column() {
      if (this.loading) {
        Text('正在读取账号资料...').fontColor(TEXT_MUTED);
      }
      if (this.errorMessage) {
        Text(this.errorMessage).fontColor(DANGER);
        Button('重新读取').enabled(!this.loading).onClick(() => this.loadUserData());
      }
      List({ space: 8 }) {
        // 登录密码
        ListItem() {
          Row() {
            Image($r('app.media.lock'))
              .width(20).height(20)
              .margin({ right: 12 })

            Column({ space: 4 }) {
              Text('登录密码').fontSize(14).fontColor(TEXT_PRIMARY);
              Text('新密码需为6—64位').fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Button('修改')
              .fontSize(12).fontColor(TEXT_SECONDARY)
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: BORDER })
              .borderRadius(4)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .enabled(!this.loading && this.userInfo !== null)
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
              Text(this.loading ? '正在读取' : (this.errorMessage ? '资料未读取成功' : (this.maskedPhone ? '已绑定 ' + this.maskedPhone : '未绑定'))).fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Button('更换')
              .fontSize(12).fontColor(TEXT_SECONDARY)
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: BORDER })
              .borderRadius(4)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .enabled(!this.loading && this.userInfo !== null)
              .onClick(() => this.onEditProfile());
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
              Text('当前暂不支持').fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Button('暂不支持')
              .enabled(false)
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
              Text('当前暂不支持').fontSize(12).fontColor(TEXT_MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Button('暂不支持')
              .enabled(false)
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

      Button('查看登录记录').margin({ top: 12 })
        .onClick(() => this.showingLoginRecords = true);

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
              await this.onLogout();
            }
          }
        });
      });
    }
    .width('100%')
    .padding(24)
    .backgroundColor(SURFACE)
    .borderRadius(12);
  }
}
