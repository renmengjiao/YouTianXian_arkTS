import { promptAction } from '@kit.ArkUI';
import { BreakpointSystem } from '@ohos/common';
import { BasicInfoTab } from './BasicInfoTab';
import { SharingRecordTab } from './SharingRecordTab';
import { StorageTab } from './StorageTab';
import { UploadsTab } from './UploadsTab';
import { SecurityTab } from './SecurityTab';

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

  @State private loggedIn: boolean = true;
  @State private registerMode: boolean = false;
  @State private panel: Panel = 'profile';
  @State private name: string = '用户gf';
  @State private phone: string = '13800138000';
  @State private email: string = 'usergf@huawei.com';
  @State private department: string = '技术部';
  @State private password: string = '';
  @State private code: string = '';
  @State private remember: boolean = true;
  @State private currentIndex: number = 0;
  @State private sidebarCollapsed: boolean = false;

  aboutToAppear(): void {
    this.breakpointSystem.register(this.getUIContext());
  }

  aboutToDisappear(): void {
    this.breakpointSystem.unregister();
  }

  private isWideScreen(): boolean {
    return this.currentBreakpoint === 'lg' || this.currentBreakpoint === 'xl';
  }

  build() {
    Column() {
      if (this.loggedIn) {
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
        TextInput({ placeholder: '邮箱', text: this.email })
          .onChange((value: string) => this.email = value)
          .height(50)
          .backgroundColor(PAGE_BACKGROUND)
          .borderRadius(8);
        TextInput({ placeholder: this.registerMode ? '设置密码' : '密码', text: this.password })
          .type(InputType.Password)
          .onChange((value: string) => this.password = value)
          .height(50)
          .backgroundColor(PAGE_BACKGROUND)
          .borderRadius(8);
        if (this.registerMode) {
          TextInput({ placeholder: '邮箱验证码', text: this.code })
            .onChange((value: string) => this.code = value)
            .height(50)
            .backgroundColor(PAGE_BACKGROUND)
            .borderRadius(8);
        } else {
          Row({ space: 8 }) {
            Toggle({ type: ToggleType.Checkbox, isOn: this.remember })
              .selectedColor(PRIMARY)
              .onChange((isOn: boolean) => this.remember = isOn);
            Text('记住登录状态').fontSize(13).fontColor(TEXT_MUTED);
          }
          .width('100%');
        }
        Button(this.registerMode ? '注册并登录' : '登录')
          .width('100%')
          .height(48)
          .backgroundColor(PRIMARY)
          .fontColor(Color.White)
          .borderRadius(8)
          .onClick(() => this.submitAuth());
        Text(this.registerMode ? '已有账号？返回登录' : '没有账号？立即注册')
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .fontColor(PRIMARY)
          .onClick(() => this.registerMode = !this.registerMode);
      }
      .width('100%')
      .margin({ top: 28 });
    }
    .width(this.isWideScreen() ? 440 : 'calc(100% - 32vp)')
    .padding(this.isWideScreen() ? 36 : 24)
    .backgroundColor(SIDEBAR_BG)
    .borderRadius(8);
  }

  private submitAuth(): void {
    if (this.email.trim().length === 0 || this.password.length === 0) {
      promptAction.showToast({ message: '请输入邮箱和密码' });
      return;
    }
    if (this.registerMode && this.code.trim().length === 0) {
      promptAction.showToast({ message: '请输入邮箱验证码' });
      return;
    }
    this.loggedIn = true;
    this.panel = 'home';
    promptAction.showToast({ message: this.registerMode ? '注册成功' : '登录成功' });
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
      // 用户头像：取昵称首字符生成圆形头像
      Text(this.name.slice(0, 1))
        .width(36)
        .height(36)
        .textAlign(TextAlign.Center)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor(PRIMARY)
        .borderRadius(18);
      // 用户昵称
      Text(this.name)
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
        .onClick(() => {
          this.loggedIn = false;
          this.panel = 'home';
          this.password = '';
        });
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
    .width(this.isWideScreen() ? 'calc(100% - 220vp)' : '100%')
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
      .padding({ top: 24, left: 32, right: 32, bottom: 0 });

      if (this.panel === 'info') {
        this.buildInfo();
      } else if (this.panel === 'storage') {
        this.buildStorage();
      } else if (this.panel === 'security') {
        this.buildSecurity();
      } else if (this.panel === 'messages') {
        this.buildMessages();
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
      } else {
        this.buildRecords();
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
      return '共享记录';
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
        this.buildCustomTab('共享记录', 1)
        this.buildCustomTab('上传记录', 2)
        this.buildCustomTab('存储空间', 3)
        this.buildCustomTab('账号安全', 4)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)   // ✅ 手动 Row 左对齐，绝对生效
      .padding({ left: 24, top: 8, bottom: 8 })
      .border({ width: { bottom: 1 }, color: DIVIDER })

      // ── 内容区（按 currentIndex 切换） ──
      Scroll() {
        Column() {
          if (this.currentIndex === 0) { BasicInfoTab({ name: this.name, phone: this.phone, email: this.email, department: this.department }) }
          else if (this.currentIndex === 1) { SharingRecordTab() }
          else if (this.currentIndex === 2) { UploadsTab() }
          else if (this.currentIndex === 3) { StorageTab() }
          else if (this.currentIndex === 4) { SecurityTab() }
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
  private buildInfo() {
    Column({ space: 4 }) {
      Column({ space: 8 }) {
        Text('姓名（昵称）').fontSize(13).fontColor(TEXT_MUTED);
        TextInput({ text: this.name })
          .onChange((value: string) => this.name = value)
          .height(48)
          .backgroundColor(PAGE_BACKGROUND)
          .borderRadius(6);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
      Column({ space: 8 }) {
        Text('手机号').fontSize(13).fontColor(TEXT_MUTED);
        TextInput({ text: this.phone })
          .onChange((value: string) => this.phone = value)
          .height(48)
          .backgroundColor(PAGE_BACKGROUND)
          .borderRadius(6);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
      Column({ space: 8 }) {
        Text('邮箱').fontSize(13).fontColor(TEXT_MUTED);
        TextInput({ text: this.email })
          .onChange((value: string) => this.email = value)
          .height(48)
          .backgroundColor(PAGE_BACKGROUND)
          .borderRadius(6);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
      Column({ space: 8 }) {
        Text('部门').fontSize(13).fontColor(TEXT_MUTED);
        TextInput({ text: this.department })
          .onChange((value: string) => this.department = value)
          .height(48)
          .backgroundColor(PAGE_BACKGROUND)
          .borderRadius(6);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
      Button('保存修改')
        .width('100%')
        .height(46)
        .backgroundColor(PRIMARY)
        .fontColor(Color.White)
        .borderRadius(4)
        .onClick(() => promptAction.showToast({ message: '个人资料已保存' }));
    }
    .width('100%')
    .padding(18)
    .backgroundColor(SURFACE)
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private buildStorage() {
    Column({ space: 18 }) {
      Row() {
        Column({ space: 16 }) {
          Text('24 GB').fontSize(28).fontWeight(FontWeight.Bold).fontColor(TEXT_PRIMARY);
          Text('已使用，共 100 GB').fontSize(13).fontColor(TEXT_MUTED);
        }
        .alignItems(HorizontalAlign.Start);
        Blank();
        Text('24%').fontSize(18).fontWeight(FontWeight.Medium).fontColor(PRIMARY);
      }
      .width('100%');
      Progress({ value: 24, total: 100, type: ProgressType.Linear })
        .width('100%')
        .height(10)
        .color(PRIMARY)
        .backgroundColor(PRIMARY_LIGHT);
      this.buildRecord('项目文件', '15.6 GB', '65%');
      this.buildRecord('测试数据', '6.8 GB', '28%');
      this.buildRecord('其他文件', '1.6 GB', '7%');
    }
    .width('100%')
    .padding(18)
    .backgroundColor(SURFACE)
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private buildSecurity() {
    Column() {
      this.buildRecord('登录密码', '已设置', '定期修改密码可提升账号安全');
      this.buildRecord('绑定邮箱', this.email, '用于登录和安全验证');
      this.buildRecord('登录设备', '2 台设备', '最近登录：今天 10:32');
      Button('修改密码')
        .width('100%')
        .height(46)
        .margin({ top: 16 })
        .backgroundColor(PRIMARY)
        .fontColor(Color.White)
        .borderRadius(8);
    }
    .width('100%')
    .padding(18)
    .backgroundColor(SURFACE)
    .borderRadius(8);
  }

  @Builder
  private buildRecords() {
    Column() {
      if (this.panel === 'sharing') {
        this.buildRecord('毫米波波束成形阵列模板', '共享给 8 位成员', '今天 10:20');
        this.buildRecord('5G 天线设计项目', '共享给项目组', '昨天 16:45');
      } else {
        this.buildRecord('S11 参数测试数据.csv', '上传成功 · 2.4 MB', '今天 09:24');
        this.buildRecord('贴片天线阵列模型.zip', '上传成功 · 18.6 MB', '昨天 14:12');
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18 })
    .backgroundColor(SURFACE)
    .borderRadius(8);
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
  private buildMessages() {
    Column() {
      this.buildRecord('李明回复了你的评论', '10 分钟前', '这个阵列间距设置非常合理');
      this.buildRecord('王浩赞了你的模板', '2 小时前', '毫米波波束成形阵列模板获得新赞');
      this.buildRecord('系统通知', '昨天', '你的项目文件已完成云端同步');
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
