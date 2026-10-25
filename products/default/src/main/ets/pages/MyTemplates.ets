/**
 * 我的模板 - 管理个人已下载/创建的模板
 * 支持: 查看、删除、分享到公共库、刷新同步
 */
import { promptAction } from '@kit.ArkUI';
import {
  TemplateInfo, TemplateFilter, AntennaType,
  ANTENNA_TYPE_LABELS, FREQUENCY_BAND_LABELS, TemplateStatus
} from '../model/TemplateInfo';
import {
  fetchMyTemplates, deleteTemplate, toggleFavorite,
  publishToPublic, refreshTemplates
} from '../api/templateApi';
import {
  TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, DIVIDER,
  SURFACE, PAGE_BACKGROUND, PRIMARY, PRIMARY_LIGHT, BORDER, DANGER
} from '../constants/CommonConstants';

@Component
export struct MyTemplates {
  @State private templates: TemplateInfo[] = [];
  @State private isLoading: boolean = false;
  @State private isRefreshing: boolean = false;
  @State private searchKeyword: string = '';
  @State private activeTab: 'all' | 'downloaded' | 'created' | 'favorites' = 'all';
  @State private page: number = 1;
  @State private total: number = 0;
  private pageSize: number = 20;
  @State private showDeleteConfirm: boolean = false;
  @State private deleteTargetId: string = '';
  @State private showPublishDialog: boolean = false;
  @State private publishTargetId: string = '';

  aboutToAppear(): void {
    this.loadTemplates();
  }

  private async loadTemplates(): Promise<void> {
    this.isLoading = true;
    const filter: TemplateFilter = {
      page: this.page,
      pageSize: this.pageSize,
      keyword: this.searchKeyword || undefined
    };
    try {
      const res = await fetchMyTemplates(filter);
      if (res.code === 200 && res.data) {
        this.templates = res.data.items;
        this.total = res.data.total;
      } else {
        promptAction.showToast({ message: res.message || '加载失败', duration: 2000 });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络异常，请稍后重试', duration: 2000 });
    }
    this.isLoading = false;
    this.isRefreshing = false;
  }

  private onSearch(): void {
    this.page = 1;
    this.loadTemplates();
  }

  private switchTab(tab: 'all' | 'downloaded' | 'created' | 'favorites'): void {
    this.activeTab = tab;
    this.page = 1;
    this.loadTemplates();
  }

  private async handleRefresh(): Promise<void> {
    this.isRefreshing = true;
    try {
      await refreshTemplates();
      promptAction.showToast({ message: '同步完成', duration: 1500 });
      this.loadTemplates();
    } catch (e) {
      promptAction.showToast({ message: '同步失败', duration: 2000 });
      this.isRefreshing = false;
    }
  }

  private confirmDelete(templateId: string): void {
    this.deleteTargetId = templateId;
    this.showDeleteConfirm = true;
  }

  private async doDelete(): Promise<void> {
    try {
      const res = await deleteTemplate(this.deleteTargetId);
      if (res.code === 200) {
        promptAction.showToast({ message: '已删除', duration: 1500 });
        this.templates = this.templates.filter(t => t.id !== this.deleteTargetId);
      } else {
        promptAction.showToast({ message: res.message || '删除失败', duration: 2000 });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络异常', duration: 2000 });
    }
    this.showDeleteConfirm = false;
  }

  private confirmPublish(templateId: string): void {
    this.publishTargetId = templateId;
    this.showPublishDialog = true;
  }

  private async doPublish(note: string): Promise<void> {
    try {
      const res = await publishToPublic({
        templateId: this.publishTargetId,
        noteToAdmin: note
      });
      if (res.code === 200) {
        promptAction.showToast({ message: '已提交发布申请', duration: 2000 });
      } else {
        promptAction.showToast({ message: res.message || '发布失败', duration: 2000 });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络异常', duration: 2000 });
    }
    this.showPublishDialog = false;
  }

  build() {
    Column() {
      // ── 顶部操作栏 ──
      this.buildTopBar();

      // ── Tab切换 ──
      this.buildTabBar();

      // ── 搜索栏 ──
      this.buildSearchBar();

      // ── 模板列表 ──
      if (this.isLoading) {
        LoadingProgress().width(32).height(32).margin({ top: 40 });
      } else if (this.templates.length === 0) {
        Column() {
          Text('暂无模板')
            .fontSize(16)
            .fontColor(TEXT_MUTED);
          Text('从模板广场下载或新建模板')
            .fontSize(13)
            .fontColor(TEXT_MUTED)
            .margin({ top: 8 });
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center);
      } else {
        List() {
          ForEach(this.templates, (template: TemplateInfo) => {
            ListItem() {
              this.buildTemplateCard(template);
            }
          }, (template: TemplateInfo) => template.id);
        }
        .width('100%')
        .layoutWeight(1);
      }

      // ── 删除确认弹窗 ──
      if (this.showDeleteConfirm) {
        this.buildDeleteConfirmDialog();
      }

      // ── 发布确认弹窗 ──
      if (this.showPublishDialog) {
        this.buildPublishDialog();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(PAGE_BACKGROUND);
  }

  @Builder
  private buildTopBar() {
    Row() {
      Text(`我的模板 (${this.total})`)
        .fontSize(16)
        .fontColor(TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium);

      Blank().layoutWeight(1);

      Button({ type: ButtonType.Normal }) {
        Row() {
          Text('↻')
            .fontSize(14)
            .fontColor(PRIMARY);
          Text('刷新')
            .fontSize(13)
            .fontColor(PRIMARY);
        }
      }
      .backgroundColor(PRIMARY_LIGHT)
      .borderRadius(16)
      .height(32)
      .padding({ left: 10, right: 10 })
      .onClick(() => this.handleRefresh());
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 8 });
  }

  @Builder
  private buildTabBar() {
    Row() {
      this.buildTabItem('全部', 'all');
      this.buildTabItem('已下载', 'downloaded');
      this.buildTabItem('已创建', 'created');
      this.buildTabItem('已收藏', 'favorites');
    }
    .width('100%')
    .padding({ left: 16, right: 16 });
  }

  @Builder
  private buildTabItem(label: string, tab: 'all' | 'downloaded' | 'created' | 'favorites') {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor(this.activeTab === tab ? PRIMARY : TEXT_SECONDARY)
        .fontWeight(this.activeTab === tab ? FontWeight.Medium : FontWeight.Regular);
      if (this.activeTab === tab) {
        Divider()
          .height(2)
          .width('100%')
          .color(PRIMARY)
          .margin({ top: 6 });
      }
    }
    .height(36)
    .layoutWeight(1)
    .onClick(() => this.switchTab(tab));
  }

  @Builder
  private buildSearchBar() {
    Row() {
      TextInput({ placeholder: '搜索我的模板...', text: this.searchKeyword })
        .layoutWeight(1)
        .height(36)
        .backgroundColor('#F5F5F5')
        .borderRadius(18)
        .padding({ left: 14 })
        .onChange((value: string) => this.searchKeyword = value)
        .onSubmit(() => this.onSearch());
      Text('🔍')
        .fontSize(16)
        .margin({ left: 8 })
        .onClick(() => this.onSearch());
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 });
  }

  @Builder
  private buildTemplateCard(template: TemplateInfo) {
    Column() {
      Row() {
        // 缩略图
        Column() {
          Text(template.name.charAt(0))
            .fontSize(20)
            .fontColor(PRIMARY);
        }
        .width(50)
        .height(50)
        .backgroundColor(PRIMARY_LIGHT)
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);

        // 信息
        Column({ space: 3 }) {
          Text(template.name)
            .fontSize(15)
            .fontColor(TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Row() {
            Text(ANTENNA_TYPE_LABELS[template.antennaType] || template.antennaType)
              .fontSize(11)
              .fontColor(TEXT_MUTED);
            Text(`使用 ${template.useCount} 次`)
              .fontSize(11)
              .fontColor(TEXT_MUTED)
              .margin({ left: 12 });
          }
        }
        .layoutWeight(1)
        .margin({ left: 12 });

        // 更多操作
        Text('⋮')
          .fontSize(20)
          .fontColor(TEXT_MUTED)
          .onClick(() => {
            // 弹出操作菜单
            this.showTemplateActions(template);
          });
      }
      .width('100%');

      // 底部状态栏
      Row() {
        if (template.status === 'public') {
          Text('已发布到广场')
            .fontSize(11)
            .fontColor('#52C41A');
        } else if (template.status === 'shared') {
          Text('已分享')
            .fontSize(11)
            .fontColor(PRIMARY);
        } else {
          Text('私人')
            .fontSize(11)
            .fontColor(TEXT_MUTED);
        }

        Blank().layoutWeight(1);

        Text(`创建于 ${template.createdAt}`)
          .fontSize(11)
          .fontColor(TEXT_MUTED);
      }
      .width('100%')
      .margin({ top: 6 });
    }
    .width('100%')
    .padding(12)
    .backgroundColor(SURFACE)
    .borderRadius(8)
    .margin({ left: 16, right: 16, bottom: 8 })
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 });
  }

  /** 展示模板操作菜单 */
  private showTemplateActions(template: TemplateInfo): void {
    AlertDialog.show({
      title: template.name,
      message: '选择操作',
      buttons: [
        {
          text: '取消',
          color: TEXT_MUTED
        },
        {
          text: '删除',
          color: DANGER,
          action: () => this.confirmDelete(template.id)
        },
        {
          text: '发布到公共库',
          color: PRIMARY,
          action: () => this.confirmPublish(template.id)
        }
      ]
    });
  }

  @Builder
  private buildDeleteConfirmDialog() {
    Column() {
      Text('确认删除')
        .fontSize(16)
        .fontColor(TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium);
      Text('删除后无法恢复，确定要删除此模板吗？')
        .fontSize(14)
        .fontColor(TEXT_SECONDARY)
        .margin({ top: 12 });

      Row({ space: 16 }) {
        Button('取消')
          .backgroundColor('#F5F5F5')
          .fontColor(TEXT_SECONDARY)
          .borderRadius(20)
          .layoutWeight(1)
          .onClick(() => this.showDeleteConfirm = false);

        Button('确认删除')
          .backgroundColor(DANGER)
          .fontColor(SURFACE)
          .borderRadius(20)
          .layoutWeight(1)
          .onClick(() => this.doDelete());
      }
      .width('100%')
      .margin({ top: 20 });
    }
    .padding(20)
    .backgroundColor(SURFACE)
    .borderRadius(12)
    .width('85%')
    .position({ x: '7.5%', y: '35%' });
  }

  @Builder
  private buildPublishDialog() {
    Column() {
      Text('发布到模板广场')
        .fontSize(16)
        .fontColor(TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium);

      TextInput({ placeholder: '给管理员的说明（可选）' })
        .height(80)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .margin({ top: 12 });

      Row({ space: 16 }) {
        Button('取消')
          .backgroundColor('#F5F5F5')
          .fontColor(TEXT_SECONDARY)
          .borderRadius(20)
          .layoutWeight(1)
          .onClick(() => this.showPublishDialog = false);

        Button('提交申请')
          .backgroundColor(PRIMARY)
          .fontColor(SURFACE)
          .borderRadius(20)
          .layoutWeight(1)
          .onClick(() => this.doPublish(''));
      }
      .width('100%')
      .margin({ top: 20 });
    }
    .padding(20)
    .backgroundColor(SURFACE)
    .borderRadius(12)
    .width('85%')
    .position({ x: '7.5%', y: '35%' });
  }
}
