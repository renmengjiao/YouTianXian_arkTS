import { UserAvatar } from '../components/UserAvatar';
import { AvatarService } from '../profile/AvatarService';
import { NotificationSettingsTab } from './NotificationSettingsTab';
import { promptAction } from '@kit.ArkUI';
import {
  SURFACE, TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, BORDER
} from '../constants/CommonConstants';
import {
  ProfileService, ProfileDraft, ProfileSnapshot, ProfileVerificationError
} from '../profile/ProfileService';

@Component
export struct BasicInfoTab {
  // 表单草稿不再通过 @Link 直接修改顶部已确认的资料。
  @State private name: string = '';
  @State private phone: string = '';
  @State private email: string = '';
  @State private department: string = '';
  @State private snapshot: ProfileSnapshot | null = null;
  @State private loading: boolean = true;
  @State private saving: boolean = false;
  @State private errorMessage: string = '';
  @State private verificationPending: boolean = false;
  @State private uploadingAvatar: boolean = false;
  @State private notificationsOpen: boolean = false;
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

  private applySnapshot(snapshot: ProfileSnapshot): void {
    this.snapshot = snapshot;
    this.name = snapshot.profile.nickname;
    this.phone = snapshot.profile.phone ?? '';
    this.email = snapshot.profile.email ?? '';
    this.department = snapshot.profile.department ?? '';
    this.verificationPending = false;
  }

  private async loadData(): Promise<void> {
    if (this.saving || this.uploadingAvatar) {
      return;
    }
    const version = ++this.requestVersion;
    this.loading = true;
    this.errorMessage = '';
    try {
      const snapshot = await ProfileService.load();
      if (this.active && version === this.requestVersion) {
        this.applySnapshot(snapshot);
      }
    } catch (error) {
      if (this.active && version === this.requestVersion) {
        // 读取失败时禁止继续用旧的基准资料保存。
        this.verificationPending = true;
        this.errorMessage = (error as Error).message || '资料读取失败，请重试';
      }
    } finally {
      if (this.active && version === this.requestVersion) {
        this.loading = false;
      }
    }
  }

  private async handleSave(): Promise<void> {
    const baseline = this.snapshot;
    if (this.loading || this.saving || this.uploadingAvatar || this.verificationPending || !baseline) {
      return;
    }
    const version = ++this.requestVersion;
    const draft: ProfileDraft = {
      nickname: this.name,
      phone: this.phone,
      email: this.email,
      department: this.department
    };
    this.saving = true;
    this.errorMessage = '';
    try {
      const result = await ProfileService.save(baseline, draft);
      if (this.active && version === this.requestVersion) {
        this.applySnapshot(result.snapshot);
        promptAction.showToast({
          message: result.changed ? '保存成功，已重新读取并核对' : '没有修改，无需保存',
          duration: 2000
        });
      }
    } catch (error) {
      if (this.active && version === this.requestVersion) {
        if (error instanceof ProfileVerificationError) {
          const failure = error as ProfileVerificationError;
          if (failure.snapshot) {
            this.applySnapshot(failure.snapshot);
          } else {
            this.verificationPending = true;
          }
        }
        this.errorMessage = (error as Error).message || '保存失败，请重试';
      }
    } finally {
      if (this.active && version === this.requestVersion) {
        this.saving = false;
      }
    }
  }

  private hasUnsavedChanges(): boolean {
    const profile = this.snapshot?.profile;
    return profile !== undefined && (this.name !== profile.nickname
      || this.phone !== (profile.phone ?? '') || this.email !== (profile.email ?? '')
      || this.department !== (profile.department ?? ''));
  }

  private async handleAvatarUpload(): Promise<void> {
    const baseline = this.snapshot;
    if (!baseline || this.loading || this.saving || this.uploadingAvatar || this.verificationPending) return;
    if (this.hasUnsavedChanges()) {
      this.errorMessage = '请先保存或重新读取资料，再更换头像，避免丢失尚未保存的输入';
      return;
    }
    const version = ++this.requestVersion;
    this.uploadingAvatar = true;
    this.errorMessage = '';
    try {
      const snapshot = await AvatarService.chooseAndUpload(baseline);
      if (snapshot && this.active && version === this.requestVersion) {
        this.applySnapshot(snapshot);
        promptAction.showToast({ message: '头像已上传并重新读取核对' });
      }
    } catch (error) {
      if (this.active && version === this.requestVersion) {
        if (error instanceof ProfileVerificationError) {
          const failure = error as ProfileVerificationError;
          if (failure.snapshot) this.applySnapshot(failure.snapshot);
          else this.verificationPending = true;
        }
        this.errorMessage = (error as Error).message || '头像选择或上传失败，请重试';
      }
    } finally {
      if (this.active && version === this.requestVersion) this.uploadingAvatar = false;
    }
  }

  build() {
    if (this.notificationsOpen) {
      this.buildNotifications();
    } else {
      this.buildProfileContent();
    }
  }

  @Builder
  private buildNotifications() {
    NotificationSettingsTab({ onBack: () => this.notificationsOpen = false });
  }

  @Builder
  private buildProfileContent() {
    Column({ space: 12 }) {
      if (this.loading) {
        Text('正在读取个人资料...').fontSize(14).fontColor(TEXT_MUTED);
      }
      if (this.errorMessage) {
        Text(this.errorMessage).fontSize(13).fontColor(TEXT_PRIMARY).width('100%');
      }
      if (!this.loading && this.snapshot !== null) {
        this.buildForm();
        Text('未绑定手机号可以留空；当前接口不支持解绑已绑定的手机号。')
          .fontSize(12).fontColor(TEXT_MUTED).width('100%');
      }
      Button('通知设置')
        .enabled(!this.loading && !this.saving && !this.uploadingAvatar)
        .onClick(() => this.notificationsOpen = true);
      Button(this.snapshot === null ? '重新读取' : '重新读取资料')
        .enabled(!this.loading && !this.saving && !this.uploadingAvatar)
        .onClick(() => this.loadData());
      Text('重新读取会用服务端资料替换尚未保存的输入。')
        .fontSize(12).fontColor(TEXT_MUTED).width('100%');
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ top: 24 });
  }

  @Builder
  private buildForm() {
    Column({ space: 20 }) {
      // ================= 1. 顶部用户信息区 =================
      Row() {
        UserAvatar({
          avatar: this.snapshot?.profile.avatar ?? null,
          nickname: this.snapshot?.profile.nickname ?? '',
          avatarSize: 64
        });

        Column({ space: 6 }) {
          Text(this.snapshot?.profile.nickname ?? '').fontSize(18).fontWeight(FontWeight.Bold).fontColor(TEXT_PRIMARY);
          Text(this.snapshot?.profile.department || '未填写部门').fontSize(12).fontColor(TEXT_MUTED);
          Button(this.uploadingAvatar ? '头像上传中...' : '更换头像')
            .enabled(!this.loading && !this.saving && !this.uploadingAvatar && !this.verificationPending)
            .onClick(() => this.handleAvatarUpload());
          Text('JPG／PNG，不超过2 MB').fontSize(12).fontColor(TEXT_MUTED);
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
          .enabled(!this.saving && !this.loading && !this.uploadingAvatar)
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
          .enabled(!this.saving && !this.loading && !this.uploadingAvatar)
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
          .enabled(!this.saving && !this.loading && !this.uploadingAvatar)
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
          .enabled(!this.saving && !this.loading && !this.uploadingAvatar)
          .onChange((value: string) => this.department = value);
      }
      .width('100%').alignItems(HorizontalAlign.Start)
      .border({ width: { bottom: 1 }, color: BORDER });

      // ================= 3. 保存按钮 =================
      Button(this.saving ? '保存中...' : '保存修改')
        .width(120).height(40)
        .fontSize(14).fontColor(this.saving ? TEXT_MUTED : TEXT_SECONDARY)
        .backgroundColor(SURFACE)
        .border({ width: 1, color: BORDER })
        .borderRadius(4)
        .margin({ top: 12 })
        .alignSelf(ItemAlign.Start)
        .enabled(!this.saving && !this.loading && !this.uploadingAvatar && !this.verificationPending)
        .onClick(() => {
          this.handleSave();
        });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ top: 12 });
  }
}
