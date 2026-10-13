import { NotificationSettings, NotificationChannel } from '../model/UserInfo';
import {
  NotificationService, NotificationSnapshot, NotificationVerificationError
} from '../notification/NotificationService';
import { promptAction } from '@kit.ArkUI';
import { TEXT_PRIMARY, TEXT_MUTED, BORDER } from '../constants/CommonConstants';

@Component
export struct NotificationSettingsTab {
  onBack: () => void = () => {};
  @State private baseline: NotificationSnapshot | null = null;
  @State private draft: NotificationSettings | null = null;
  @State private thresholdText: string = '';
  @State private loading: boolean = true;
  @State private saving: boolean = false;
  @State private verificationPending: boolean = false;
  @State private errorMessage: string = '';
  private active: boolean = false;
  private requestVersion: number = 0;

  aboutToAppear(): void {
    this.active = true;
    this.load();
  }

  aboutToDisappear(): void {
    this.active = false;
    this.requestVersion++;
  }

  private apply(snapshot: NotificationSnapshot): void {
    this.baseline = snapshot;
    this.draft = NotificationService.copy(snapshot.settings);
    const threshold = snapshot.settings.resourceWarning.threshold;
    this.thresholdText = threshold === null || threshold === undefined ? '' : String(threshold);
    this.verificationPending = false;
  }

  private async load(): Promise<void> {
    if (this.saving) return;
    const version = ++this.requestVersion;
    this.loading = true;
    this.errorMessage = '';
    try {
      const snapshot = await NotificationService.load();
      if (this.active && version === this.requestVersion) this.apply(snapshot);
    } catch (error) {
      if (this.active && version === this.requestVersion) {
        this.errorMessage = (error as Error).message || '通知设置读取失败';
        this.verificationPending = true;
      }
    } finally {
      if (this.active && version === this.requestVersion) this.loading = false;
    }
  }

  private setChannel(kind: number, field: string, value: boolean): void {
    if (!this.draft || this.saving || this.loading) return;
    const next = NotificationService.copy(this.draft);
    let channel = next.simulationComplete;
    if (kind === 1) channel = next.resourceWarning;
    if (kind === 2) channel = next.systemUpdate;
    if (kind === 3) channel = next.TeamCollaborationMessage;
    if (field === 'enabled') channel.enabled = value;
    if (field === 'email') channel.email = value;
    if (field === 'push') channel.push = value;
    if (field === 'inApp') channel.inApp = value;
    this.draft = next;
  }

  private async save(): Promise<void> {
    const base = this.baseline;
    const current = this.draft;
    if (!base || !current || this.loading || this.saving || this.verificationPending) return;
    const version = ++this.requestVersion;
    this.saving = true;
    this.errorMessage = '';
    try {
      const next = NotificationService.copy(current);
      if (this.thresholdText === '') {
        if (base.settings.resourceWarning.threshold !== null
          && base.settings.resourceWarning.threshold !== undefined) {
          throw new Error('当前接口不支持清空已有阈值，请保留原值或输入整数');
        }
      } else {
        if (!/^-?\d+$/.test(this.thresholdText)) {
          throw new Error('资源预警阈值必须为整数');
        }
        const value = Number(this.thresholdText);
        if (!Number.isInteger(value) || value < -2147483648 || value > 2147483647) {
          throw new Error('资源预警阈值超出后端整数类型范围');
        }
        next.resourceWarning.threshold = value;
      }
      const result = await NotificationService.save(base, next);
      if (this.active && version === this.requestVersion) {
        this.apply(result.snapshot);
        promptAction.showToast({
          message: result.changed ? '通知设置已保存并重新读取核对' : '没有修改，无需保存'
        });
      }
    } catch (error) {
      if (this.active && version === this.requestVersion) {
        if (error instanceof NotificationVerificationError) {
          const failure = error as NotificationVerificationError;
          if (failure.snapshot) this.apply(failure.snapshot);
          else this.verificationPending = true;
        }
        this.errorMessage = (error as Error).message || '通知设置保存失败';
      }
    } finally {
      if (this.active && version === this.requestVersion) this.saving = false;
    }
  }

  @Builder
  private channelForm(title: string, channel: NotificationChannel, kind: number) {
    Column({ space: 8 }) {
      Text(title).fontSize(16).fontColor(TEXT_PRIMARY);
      Row() {
        Text('启用').layoutWeight(1);
        Toggle({ type: ToggleType.Switch, isOn: channel.enabled })
          .enabled(!this.loading && !this.saving)
          .onChange((value: boolean) => this.setChannel(kind, 'enabled', value));
      }.width('100%');
      Row() {
        Text('邮件通知').layoutWeight(1);
        Toggle({ type: ToggleType.Switch, isOn: channel.email })
          .enabled(!this.loading && !this.saving)
          .onChange((value: boolean) => this.setChannel(kind, 'email', value));
      }.width('100%');
      Row() {
        Text('推送通知').layoutWeight(1);
        Toggle({ type: ToggleType.Switch, isOn: channel.push })
          .enabled(!this.loading && !this.saving)
          .onChange((value: boolean) => this.setChannel(kind, 'push', value));
      }.width('100%');
      Row() {
        Text('站内通知').layoutWeight(1);
        Toggle({ type: ToggleType.Switch, isOn: channel.inApp })
          .enabled(!this.loading && !this.saving)
          .onChange((value: boolean) => this.setChannel(kind, 'inApp', value));
      }.width('100%');
    }
    .width('100%').padding(12).border({ width: 1, color: BORDER });
  }

  build() {
    Column({ space: 12 }) {
      Button('返回基本信息').enabled(!this.saving).onClick(() => this.onBack());
      Text('通知设置').fontSize(18).fontColor(TEXT_PRIMARY);
      if (this.loading) {
        Text('正在读取通知设置...').fontColor(TEXT_MUTED);
      }
      if (this.errorMessage) {
        Text(this.errorMessage).fontColor(TEXT_PRIMARY);
      }
      if (!this.loading && this.draft !== null) {
        this.channelForm('仿真完成', this.draft.simulationComplete, 0);
        this.channelForm('资源预警', this.draft.resourceWarning, 1);
        TextInput({ text: this.thresholdText, placeholder: '资源预警阈值（整数）' })
          .enabled(!this.loading && !this.saving)
          .onChange((value: string) => this.thresholdText = value);
        this.channelForm('系统更新', this.draft.systemUpdate, 2);
        this.channelForm('团队协作消息', this.draft.TeamCollaborationMessage, 3);
        Text('服务端更新时间：' + (this.draft.lastUpdated ?? '未提供')).fontColor(TEXT_MUTED);
        Button(this.saving ? '保存中...' : '保存设置')
          .enabled(!this.loading && !this.saving && !this.verificationPending)
          .onClick(() => this.save());
      }
      Button('重新读取').enabled(!this.loading && !this.saving).onClick(() => this.load());
      Text('重新读取会替换未保存的设置。').fontColor(TEXT_MUTED);
    }
    .width('100%').alignItems(HorizontalAlign.Start).padding({ top: 24 });
  }
}
