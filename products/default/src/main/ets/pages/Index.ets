import { promptAction } from '@kit.ArkUI';
import { BreakpointSystem } from '@ohos/common';
import { BasicInfoTab } from './BasicInfoTab';
import { SharingRecordTab } from './SharingRecordTab';
import { StorageTab } from './StorageTab';
import { UploadsTab } from './UploadsTab';
import { SecurityTab } from './SecurityTab';
import { UserAvatar } from '../components/UserAvatar';

import { fetchUserProfile } from '../api/userApi';
import { UserInfo, RegisterRequest } from '../model/UserInfo';
import { SessionManager } from '../session/SessionManager';

import {
  commonConstants,
  PRIMARY, PRIMARY_LIGHT, PAGE_BACKGROUND, SURFACE,
  TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, DIVIDER, DANGER,
  SIDEBAR_BG, SIDEBAR_TEXT, SIDEBAR_ACTIVE_BG, SIDEBAR_ACTIVE_TEXT, SIDEBAR_GROUP_TITLE,
  Panel, MenuItem, NavItem,
  PROJECT_ITEMS, ACCOUNT_ITEMS, MENU_ITEMS
} from '../constants/CommonConstants';

@Entry
@Component
struct Index {
  @StorageLink('mainBreakpoint') private currentBreakpoint: string = commonConstants.breakpointsInitializeName;
  private readonly breakpointSystem: BreakpointSystem =
    new BreakpointSystem(commonConstants.breakpointSystemName);

  @State private loggedIn: boolean = false;
  @State private authLoading: boolean = false;
  @State private registerMode: boolean = false;
  @State private panel: Panel = 'profile';
  @State private userInfo: UserInfo | null = null;
  @State private isLoading: boolean = false;
  @State private name: string = '';
  @State private phone: string = '';
  @State private email: string = '';
  @State private department: string = '';
  @State private password: string = '';
  @State private account: string = '';
  @State private registerUsername: string = '';
  @State private registerNickname: string = '';
  @State private registerPhone: string = '';
  @State private sessionRestoring: boolean = true;
  @State private logoutLoading: boolean = false;
  @State private remember: boolean = true;
  @State private currentIndex: number = 0;
  @State private msgTabIndex: number = 0;
  @State private sidebarCollapsed: boolean = false;

  aboutToAppear(): void {
    this.breakpointSystem.register(this.getUIContext());
    SessionManager.getInstance().setListener((user) => this.applySession(user));
    this.restoreSession();
  }

  private applySession(user: UserInfo | null): void {
    const previousUserId = this.userInfo?.userId;
    this.userInfo = user;
    this.loggedIn = user !== null;
    this.name = user?.nickname ?? '';
    this.phone = user?.phone ?? '';
    this.email = user?.email ?? '';
    this.department = user?.department ?? '';
    if (!user || previousUserId !== user.userId) {
      this.password = '';
      this.currentIndex = 0;
      this.panel = 'profile';
    }
  }

  private async restoreSession(): Promise<void> {
    try {
      const user = await SessionManager.getInstance().restore();
      this.applySession(user);
      if (user) {
        this.remember = true;
      }
    } catch (error) {
      this.applySession(null);
      promptAction.showToast({
        message: (error as Error).message || '无法恢复登录，请重新登录'
      });
    } finally {
      this.sessionRestoring = false;
    }
  }

  private async handleLogout(): Promise<void> {
    if (this.logoutLoading) {
      return;
    }
    this.logoutLoading = true;
    try {
      const result = await SessionManager.getInstance().logout();
      let message = '已退出登录';
      if (!result.storageCleared) {
        message = '退出未完全完成：本机登录状态清理失败，请重试';
      } else if (!result.remoteRevoked) {
        message = '本机已退出，服务端会话撤销未确认';
      }
      this.registerUsername = '';
      this.registerNickname = '';
      this.registerPhone = '';
      promptAction.showToast({ message: message });
    } finally {
      this.logoutLoading = false;
    }
  }

  private async loadUserProfile(): Promise<void> {
    this.isLoading = true;
    try {
      const resp = await fetchUserProfile();
      if (resp.code === 200) {
        this.userInfo = resp.data;
      }
    } catch (e) {
      console.error('Failed to load profile', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  aboutToDisappear(): void {
    this.breakpointSystem.unregister();
    SessionManager.getInstance().setListener(null);
  }

  private isWideScreen(): boolean {
    return this.currentBreakpoint === 'lg' || this.currentBreakpoint === 'xl';
  }

  build() {
    Column() {
      if (this.sessionRestoring) {
        Text('正在恢复登录状态...')
          .fontSize(14).fontColor(TEXT_MUTED)
          .margin({ top: 48 });
      } else if (this.loggedIn) {
        this.buildWorkspace();
      } else {
        this.buildAuth();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(PAGE_BACKGROUND);
  }

  @Builder
  private buildAuth() {
    if (this.isWideScreen()) {
      // 宽屏：左右分栏布局
      Row() {
        // ── 左侧品牌展示区（#007DFF 底色） ──
        Column() {
          Text('优天线')
            .fontSize(54)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White);
          Text('天线工程师的专业社区')
            .fontSize(18)
            .fontColor(Color.White)
            .opacity(0.85)
            .margin({ top: 16 });
          Text('分享项目 · 管理模板 · 协同设计')
            .fontSize(14)
            .fontColor(Color.White)
            .opacity(0.6)
            .margin({ top: 10 });
        }
        .width('55%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#007DFF');

        // ── 右侧登录/注册卡片 ──
        Column() {
          this.buildAuthCard();
        }
        .width('45%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(PAGE_BACKGROUND);
      }
      .width('100%')
      .height('100%');
    } else {
      // 窄屏：保留原卡片居中布局
      Column() {
        this.buildAuthCard();
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#007DFF');
    }
  }

  @Builder
  private buildAuthCard() {
    Column() {
      Column({ space: 8 }) {
        Text('优天线')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(PRIMARY);
        Text(this.registerMode ? '创建账号' : '欢迎回来')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(TEXT_PRIMARY)
          .margin({ top: 22 });
        Text(this.registerMode ? '加入天线工程师社区' : '登录后管理你的项目与资料')
          .fontSize(14)
          .fontColor(TEXT_MUTED);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);

      Column({ space: 14 }) {
        if (this.registerMode) {
          TextInput({ placeholder: '用户名（3～64个字符）', text: this.registerUsername })
            .onChange((value: string) => this.registerUsername = value)
            .height(50).backgroundColor(PAGE_BACKGROUND).borderRadius(8);
          TextInput({ placeholder: '昵称', text: this.registerNickname })
            .onChange((value: string) => this.registerNickname = value)
            .height(50).backgroundColor(PAGE_BACKGROUND).borderRadius(8);
          TextInput({ placeholder: '手机号（可选）', text: this.registerPhone })
            .type(InputType.PhoneNumber)
            .onChange((value: string) => this.registerPhone = value)
            .height(50).backgroundColor(PAGE_BACKGROUND).borderRadius(8);
        } else {
          TextInput({ placeholder: '用户名或手机号', text: this.account })
            .onChange((value: string) => this.account = value)
            .height(50).backgroundColor(PAGE_BACKGROUND).borderRadius(8);
        }
        TextInput({ placeholder: this.registerMode ? '设置密码（6～64个字符）' : '密码',
          text: this.password })
          .type(InputType.Password)
          .onChange((value: string) => this.password = value)
          .height(50).backgroundColor(PAGE_BACKGROUND).borderRadius(8);
        Row({ space: 8 }) {
          Toggle({ type: ToggleType.Checkbox, isOn: this.remember })
            .selectedColor(PRIMARY)
            .onChange((isOn: boolean) => this.remember = isOn);
          Text('记住登录状态').fontSize(13).fontColor(TEXT_MUTED);
        }
        .width('100%');
        Button(this.authLoading ? '请稍候...' : (this.registerMode ? '注册并登录' : '登录'))
          .width('100%')
          .height(48)
          .backgroundColor(this.authLoading ? '#B0B0B0' : PRIMARY)
          .fontColor(Color.White)
          .borderRadius(8)
          .enabled(!this.authLoading && !this.logoutLoading)
          .onClick(() => this.submitAuth());
        Text(this.registerMode ? '已有账号？返回登录' : '没有账号？立即注册')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .fontColor(PRIMARY)
          .enabled(!this.authLoading && !this.logoutLoading)
          .onClick(() => {
            this.registerMode = !this.registerMode;
            this.password = '';
          });
      }
      .width('100%')
      .margin({ top: 28 });
    }
    .width(this.isWideScreen() ? 400 : 'calc(100% - 32vp)')
    .padding(36)
    .backgroundColor(SIDEBAR_BG)
    .borderRadius(8);
  }

  private async submitAuth(): Promise<void> {
    if (this.authLoading || this.logoutLoading || this.sessionRestoring) {
      return;
    }
    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码' });
      return;
    }
    if (this.registerMode) {
      const username = this.registerUsername.trim();
      if (username.length < 3 || username.length > 64) {
        promptAction.showToast({ message: '用户名长度需在3～64个字符之间' });
        return;
      }
      if (!this.registerNickname.trim()) {
        promptAction.showToast({ message: '请输入昵称' });
        return;
      }
      if (this.password.length < 6 || this.password.length > 64) {
        promptAction.showToast({ message: '密码长度需在6～64个字符之间' });
        return;
      }
      if (this.registerPhone.trim() && !/^1\d{10}$/.test(this.registerPhone.trim())) {
        promptAction.showToast({ message: '请输入正确的11位手机号' });
        return;
      }
    } else if (!this.account.trim()) {
      promptAction.showToast({ message: '请输入用户名或手机号' });
      return;
    }

    const registering = this.registerMode;
    this.authLoading = true;
    try {
      if (registering) {
        const body: RegisterRequest = {
          username: this.registerUsername.trim(),
          nickname: this.registerNickname.trim(),
          password: this.password
        };
        if (this.registerPhone.trim()) {
          body.phone = this.registerPhone.trim();
        }
        await SessionManager.getInstance().register(body, this.remember);
      } else {
        await SessionManager.getInstance().login({
          account: this.account.trim(), password: this.password
        }, this.remember);
      }
      promptAction.showToast({ message: registering ? '注册成功' : '登录成功' });
    } catch (error) {
      promptAction.showToast({
        message: (error as Error).message || '认证失败，请重试'
      });
    } finally {
      this.authLoading = false;
    }
  }

  @Builder
  private buildWorkspace() {
    Column() {
      this.buildHeader();
      if (this.isWideScreen()) {
        Row() {
          this.buildSidebar();
          this.buildContent();
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top);
      } else {
        this.buildContent();
        this.buildBottomBar();
      }
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  private buildHeader() {
    Row() {
      Text('优天线')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(PRIMARY);
      Blank();
      UserAvatar({
        avatar: this.userInfo?.avatar ?? null,
        nickname: this.userInfo?.nickname ?? '',
        avatarSize: 36
      });
      // 用户昵称
      Text(this.userInfo?.nickname ?? '用户')
        .fontSize(14)
        .fontColor(TEXT_PRIMARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ left: 10 })
        .constraintSize({ maxWidth: this.isWideScreen() ? 160 : 96 });
      Text('消息')
        .fontSize(14)
        .fontColor(this.panel === 'messages' ? PRIMARY : TEXT_SECONDARY)
        .margin({ left: 16 })
        .onClick(() => this.panel = 'messages');
      Text('退出')
        .fontSize(14)
        .fontColor(DANGER)
        .margin({ left: 20 })
        .enabled(!this.logoutLoading)
        .onClick(() => this.handleLogout());
    }
    .width('100%')
    .height(58)
    .padding({ left: this.isWideScreen() ? 28 : 16, right: this.isWideScreen() ? 28 : 16 })
    .backgroundColor(SIDEBAR_BG)
    .border({ width: { bottom: 1 }, color: DIVIDER });
  }

  @Builder
  private buildSidebar() {
    Column() {
      // ---- Logo区域 ----
      Row({ space: this.sidebarCollapsed ? 0 : 10 }) {
        Text('Y')
          .width(32)
          .height(32)
          .textAlign(TextAlign.Center)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor(PRIMARY)
          .borderRadius(8);
        if (!this.sidebarCollapsed) {
          Text('优天线')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(SIDEBAR_TEXT);
        }
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height(60)
      .padding(this.sidebarCollapsed ? { left: 0, right: 0 } : { left: 16, right: 16 })
      .justifyContent(this.sidebarCollapsed ? FlexAlign.Center : FlexAlign.Start);

      // ---- 项目分组 ----
      if (!this.sidebarCollapsed) {
        Text('项目')
          .fontSize(12)
          .fontColor(SIDEBAR_GROUP_TITLE)
          .padding({ left: 16, right: 16, top: 12, bottom: 4 });
      }
      ForEach(PROJECT_ITEMS, (item: NavItem) => {
        this.buildNavigationItem(item);
      }, (item: NavItem) => item.panel);

      // ---- 账号分组 ----
      if (!this.sidebarCollapsed) {
        Text('账号')
          .fontSize(12)
          .fontColor(SIDEBAR_GROUP_TITLE)
          .padding({ left: 16, right: 16, top: 16, bottom: 4 });
      }
      ForEach(ACCOUNT_ITEMS, (item: NavItem) => {
        this.buildNavigationItem(item);
      }, (item: NavItem) => item.panel);

      // ---- 底部区域 ----
      Blank().layoutWeight(1);

      // ---- 存储区 ----
      if (!this.sidebarCollapsed) {
        Column() {
          Text('存储空间 25%')
            .fontSize(13)
            .fontColor(SIDEBAR_TEXT)
            .width('100%');
          Row() {
            Progress({ value: 25, total: 100, type: ProgressType.Linear })
              .width('100%')
              .height(6)
              .value(25)
              .color(PRIMARY)
              .backgroundColor('#E8E8E8');
          }
          .width('100%')
          .padding({ top: 8, bottom: 6 });
          Text('12.5 GB / 50 GB')
            .fontSize(12)
            .fontColor(SIDEBAR_GROUP_TITLE)
            .width('100%');
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 });
      }

      // 折叠侧边栏按钮
      Row({ space: this.sidebarCollapsed ? 0 : 8 }) {
        Image($r('app.media.' + (this.sidebarCollapsed ? 'expand' : 'collapse')))
          .width(16).height(16)
          .objectFit(ImageFit.Contain);
        if (!this.sidebarCollapsed) {
          Text('折叠侧边栏')
            .fontSize(13)
            .fontColor(SIDEBAR_GROUP_TITLE);
        }
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(this.sidebarCollapsed ? FlexAlign.Center : FlexAlign.Start)
      .width('100%')
      .height(36)
      .padding({ left: 16, right: 16 })
      .margin({ top: 4, bottom: 12 })
      .borderRadius(6)
      .onClick(() => {
        this.sidebarCollapsed = !this.sidebarCollapsed;
      });
    }
    .width(this.sidebarCollapsed ? 60 : 220)
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(SIDEBAR_BG)
    .border({ width: { right: 1 }, color: DIVIDER });
  }

  @Builder
  private buildNavigationItem(item: NavItem) {
    Row({ space: this.sidebarCollapsed ? 0 : 10 }) {
      Image($r('app.media.' + item.icon))
        .width(24).height(24)
        .objectFit(ImageFit.Contain)
      if (!this.sidebarCollapsed) {
        Text(item.label)
          .fontSize(14)
          .fontColor(this.panel === item.panel ? SIDEBAR_ACTIVE_TEXT : SIDEBAR_TEXT)
          .fontWeight(this.panel === item.panel ? FontWeight.Medium : FontWeight.Regular);
        Blank();
        // 消息中心角标
        if (item.badge !== undefined && item.badge > 0) {
          Text(item.badge.toString())
            .fontSize(11)
            .fontColor(Color.White)
            .width(20)
            .height(20)
            .textAlign(TextAlign.Center)
            .backgroundColor(PRIMARY)
            .borderRadius(10)
            .margin({ right: 2 });
        }
      }
    }
    .width('100%')
    .height(this.sidebarCollapsed ? 44 : 40)
    .justifyContent(this.sidebarCollapsed ? FlexAlign.Center : FlexAlign.Start)
    .padding(this.sidebarCollapsed ? 0 : { left: 16, right: 16 })
    .margin({ top: 4, bottom: 4 })
    .backgroundColor(this.panel === item.panel ? SIDEBAR_ACTIVE_BG : Color.Transparent)
    .borderRadius(8)
    .onClick(() => this.panel = item.panel);
  }

  @Builder
  private buildContent() {
    Scroll() {
      Column() {
        this.buildPanel();
      }
      .width('100%')
      .padding({
        top: 0,
        left: this.isWideScreen() ? 28 : 16,
        right: this.isWideScreen() ? 28 : 16,
        bottom: this.isWideScreen() ? 28 : 16
      })
      .backgroundColor(SURFACE)
      .alignItems(HorizontalAlign.Start) // 👈 核心关键：强制左对齐，解决居中问题
    }
    .layoutWeight(1)
    .width('100%')
    .scrollBar(BarState.Off);
  }
  @Builder
  private buildPanel() {
    Column({ space: (this.panel === 'info' || this.panel === 'storage') ? 24 : (this.panel === 'security' || this.panel === 'sharing' || this.panel === 'uploads') ? 16 : 18 }) {
      Row({ space: 10 }) {
        if (!this.isWideScreen()) {
          Text('<')
            .width(36)
            .height(36)
            .textAlign(TextAlign.Center)
            .fontSize(22)
            .fontColor(PRIMARY)
            .backgroundColor(SURFACE)
            .borderRadius(6)
            .onClick(() => this.panel = 'home');
        }
        Text(this.panelTitle())
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(TEXT_PRIMARY);
      }
      .width('100%')
      .padding({ top: 24, left: 0, right: 0, bottom: 0 });

      if (this.panel === 'info') {
        Scroll() {
          BasicInfoTab();
        }
        .width('100%').layoutWeight(1).scrollBar(BarState.Off);
      } else if (this.panel === 'storage') {
        Scroll() { StorageTab(); }
        .width('100%').scrollBar(BarState.Off);
      } else if (this.panel === 'security') {
        Scroll() {
          SecurityTab({ onLogout: () => this.handleLogout(), onEditProfile: () => this.panel = 'info' });
        }
        .width('100%').scrollBar(BarState.Off);
      } else if (this.panel === 'messages') {
        Text('消息中心暂未接入，当前不展示示例消息').fontColor(TEXT_MUTED);
      } else if (this.panel === 'repos') {
        this.buildRepos();
      } else if (this.panel === 'templates') {
        this.buildTemplates();
      } else if (this.panel === 'mytemplates') {
        this.buildMyTemplates();
      } else if (this.panel === 'assistant') {
        this.buildAssistant();
      } else if (this.panel === 'profile') {
        this.buildProfile();
      } else if (this.panel === 'sharing') {
        SharingRecordTab();
      } else if (this.panel === 'uploads') {
        UploadsTab();
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  private panelTitle(): string {
    if (this.panel === 'info') {
      return '基本信息';
    }
    if (this.panel === 'sharing') {
      return '我分享的';
    }
    if (this.panel === 'storage') {
      return '存储空间';
    }
    if (this.panel === 'uploads') {
      return '上传记录';
    }
    if (this.panel === 'security') {
      return '账号安全';
    }
    if (this.panel === 'repos') {
      return '项目仓库';
    }
    if (this.panel === 'templates') {
      return '模板广场';
    }
    if (this.panel === 'mytemplates') {
      return '我的模板';
    }
    if (this.panel === 'assistant') {
      return 'AI助手';
    }
    if (this.panel === 'profile') {
      return '个人中心';
    }
    return '消息中心';
  }

  @Builder
  private buildProfile() {
    Column() {
      // ── 手动 TabBar ──
      Row() {
        this.buildCustomTab('基本信息', 0)
        this.buildCustomTab('我分享的', 1)
        this.buildCustomTab('上传记录', 2)
        this.buildCustomTab('存储空间', 3)
        this.buildCustomTab('账号安全', 4)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)   // ✅ 手动 Row 左对齐，绝对生效
      .padding({ top: 8, bottom: 8 })
      .border({ width: { bottom: 1 }, color: DIVIDER })

      // ── 内容区（按 currentIndex 切换） ──
      Scroll() {
        Column() {
          if (this.currentIndex === 0) { BasicInfoTab() }
          else if (this.currentIndex === 1) { SharingRecordTab() }
          else if (this.currentIndex === 2) { UploadsTab() }
          else if (this.currentIndex === 3) { StorageTab() }
          else if (this.currentIndex === 4) { SecurityTab({ onLogout: () => this.handleLogout(), onEditProfile: () => this.currentIndex = 0 }) }
        }
        .padding({ top: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  private buildCustomTab(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontColor(this.currentIndex === index ? PRIMARY : TEXT_SECONDARY)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Regular)
        .padding({ bottom: 4 })
        .border({
          width: this.currentIndex === index ? { bottom: 2 } : 0,
          color: PRIMARY
        })
    }
    .height(48)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16 })
    .onClick(() => this.currentIndex = index)
  }

  @Builder
  private buildTabBar(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontColor(this.currentIndex === index ? PRIMARY : TEXT_SECONDARY)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Regular)
        .padding({ bottom: 4 })
        .border({
          width: this.currentIndex === index ? { bottom: 2 } : 0,
          color: PRIMARY
        })
    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  private buildRepos() {
    Column() {
      this.buildRecord('毫米波 8×8 相控阵天线设计', '昨日更新', '2 个仿真文件 · 1 个报告');
      this.buildRecord('5G 基站 Massive MIMO 阵列', '3 天前更新', '5 个仿真文件');
      this.buildRecord('车载毫米波雷达天线', '上周', '仿真数据已归档');
    }
    .width('100%')
    .padding({ left: 18, right: 18 })
    .backgroundColor(SURFACE)
    .borderRadius(8);
  }

  @Builder
  private buildTemplates() {
    Column() {
      this.buildRecord('毫米波波束成形阵列模板', '共享给 8 位成员', '今天 10:20');
      this.buildRecord('微带贴片天线阵列模板', '1.2k 人使用', '4.9 评分');
      this.buildRecord('单极子天线仿真模板', '856 人使用', '4.7 评分');
    }
    .width('100%')
    .padding({ left: 18, right: 18 })
    .backgroundColor(SURFACE)
    .borderRadius(8);
  }

  @Builder
  private buildMyTemplates() {
    Column() {
      this.buildRecord('毫米波波束成形阵列模板', '使用 128 次', '今天 10:20');
      this.buildRecord('5G 天线设计项目', '采用 3 人', '昨天 16:45');
    }
    .width('100%')
    .padding({ left: 18, right: 18 })
    .backgroundColor(SURFACE)
    .borderRadius(8);
  }

  @Builder
  private buildAssistant() {
    Column() {
      this.buildRecord('阵列参数优化建议', 'AI 生成', '基于 3 个仿真结果生成');
      this.buildRecord('波束成形方向图分析', 'AI 生成', '最近一次任务');
    }
    .width('100%')
    .padding({ left: 18, right: 18 })
    .backgroundColor(SURFACE)
    .borderRadius(8);
  }

  @Builder
  private buildRecord(title: string, value: string, detail: string) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        if (detail.length > 0) {
          Text(detail).fontSize(12).fontColor(TEXT_MUTED);
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
      Text(value).fontSize(13).fontColor(PRIMARY).margin({ left: 16 }).alignSelf(ItemAlign.Center);
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .border({ width: { bottom: 1 }, color: DIVIDER });
  }

  @Builder
  private buildBottomBar() {
    Row() {
      this.buildBottomItem('主页', 'H', 'home');
      this.buildBottomItem('资料', 'i', 'info');
      this.buildBottomItem('存储', 'D', 'storage');
      this.buildBottomItem('安全', 'A', 'security');
    }
    .width('100%')
    .height(62)
    .padding({ left: 8, right: 8 })
    .backgroundColor(SURFACE)
    .border({ width: { top: 1 }, color: DIVIDER });
  }

  @Builder
  private buildBottomItem(label: string, icon: string, target: Panel) {
    Column({ space: 3 }) {
      Text(icon)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.panel === target ? PRIMARY : TEXT_SECONDARY);
      Text(label)
        .fontSize(11)
        .fontColor(this.panel === target ? PRIMARY : TEXT_SECONDARY);
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => this.panel = target);
  }
}
