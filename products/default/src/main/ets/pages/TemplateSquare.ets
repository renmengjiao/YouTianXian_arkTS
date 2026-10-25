/**
 * 模板广场 - 浏览、搜索、筛选平台公开模板
 * 支持: 下载、收藏、查看详情、关键词搜索、分类筛选
 */
import { promptAction } from '@kit.ArkUI';
import {
  TemplateInfo, TemplateFilter, AntennaType,
  FrequencyBand, ANTENNA_TYPE_LABELS, FREQUENCY_BAND_LABELS
} from '../model/TemplateInfo';
import { fetchPublicTemplates, downloadTemplate, toggleFavorite } from '../api/templateApi';
import { TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, DIVIDER, SURFACE, PAGE_BACKGROUND, PRIMARY, PRIMARY_LIGHT, BORDER } from '../constants/CommonConstants';

interface FilterTag {
  label: string;
  key: string;
  value: string;
}

@Component
export struct TemplateSquare {
  @State private templates: TemplateInfo[] = [];
  @State private isLoading: boolean = false;
  @State private searchKeyword: string = '';
  @State private selectedAntennaType: string | null = null;
  @State private selectedFreqBand: string | null = null;
  @State private sortBy: string = 'downloadCount';
  @State private page: number = 1;
  @State private total: number = 0;
  private pageSize: number = 20;
  @State private activeTags: FilterTag[] = [];

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
    if (this.selectedAntennaType) {
      filter.antennaType = this.selectedAntennaType as AntennaType;
    }
    if (this.sortBy) {
      filter.sortBy = this.sortBy as 'name' | 'createdAt' | 'downloadCount' | 'rating';
    }
    try {
      const res = await fetchPublicTemplates(filter);
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
  }

  private onSearch(): void {
    this.page = 1;
    this.loadTemplates();
  }

  private onFilterChange(): void {
    this.page = 1;
    this.buildActiveTags();
    this.loadTemplates();
  }

  private buildActiveTags(): void {
    const tags: FilterTag[] = [];
    if (this.selectedAntennaType) {
      tags.push({
        label: ANTENNA_TYPE_LABELS[this.selectedAntennaType] || this.selectedAntennaType,
        key: 'antennaType',
        value: this.selectedAntennaType
      });
    }
    if (this.selectedFreqBand) {
      tags.push({
        label: FREQUENCY_BAND_LABELS[this.selectedFreqBand] || this.selectedFreqBand,
        key: 'freqBand',
        value: this.selectedFreqBand
      });
    }
    this.activeTags = tags;
  }

  private removeTag(tag: FilterTag): void {
    if (tag.key === 'antennaType') {
      this.selectedAntennaType = null;
    } else if (tag.key === 'freqBand') {
      this.selectedFreqBand = null;
    }
    this.onFilterChange();
  }

  private async handleDownload(template: TemplateInfo): Promise<void> {
    try {
      const res = await downloadTemplate(template.id);
      if (res.code === 200) {
        promptAction.showToast({ message: '已下载到我的模板', duration: 2000 });
      } else {
        promptAction.showToast({ message: res.message || '下载失败', duration: 2000 });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络异常', duration: 2000 });
    }
  }

  private async handleFavorite(template: TemplateInfo): Promise<void> {
    const newState = !template.isFavorited;
    try {
      const res = await toggleFavorite({ templateId: template.id, favorited: newState });
      if (res.code === 200) {
        template.isFavorited = newState;
        promptAction.showToast({
          message: newState ? '已收藏' : '已取消收藏',
          duration: 1500
        });
      }
    } catch (e) {
      promptAction.showToast({ message: '操作失败', duration: 2000 });
    }
  }

  build() {
    Column() {
      // ── 搜索与筛选栏 ──
      this.buildSearchBar();
      this.buildFilterRow();

      // ── 活跃筛选标签 ──
      if (this.activeTags.length > 0) {
        this.buildActiveFilterTags();
      }

      // ── 排序切换 ──
      this.buildSortBar();

      // ── 模板列表 ──
      if (this.isLoading) {
        LoadingProgress().width(32).height(32).margin({ top: 40 });
      } else if (this.templates.length === 0) {
        Column() {
          Text('暂无模板数据')
            .fontSize(16)
            .fontColor(TEXT_MUTED);
          Text('调整筛选条件或上传新模板')
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(PAGE_BACKGROUND);
  }

  @Builder
  private buildSearchBar() {
    Row() {
      TextInput({ placeholder: '搜索模板名称或关键词...', text: this.searchKeyword })
        .layoutWeight(1)
        .height(40)
        .backgroundColor('#F5F5F5')
        .borderRadius(20)
        .padding({ left: 16 })
        .onChange((value: string) => this.searchKeyword = value)
        .onSubmit(() => this.onSearch());
      Button({ type: ButtonType.Normal }) {
        Text('搜索').fontSize(14).fontColor(PRIMARY);
      }
      .backgroundColor(PRIMARY_LIGHT)
      .borderRadius(20)
      .height(40)
      .margin({ left: 8 })
      .onClick(() => this.onSearch());
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 8 });
  }

  @Builder
  private buildFilterRow() {
    Row() {
      // 天线类型筛选
      Select([
        { value: 'all', icon: '' },
        ...Object.entries(ANTENNA_TYPE_LABELS).map(([k, v]) => ({ value: k, icon: '' }))
      ])
      .selected(this.selectedAntennaType ? Object.keys(ANTENNA_TYPE_LABELS).indexOf(this.selectedAntennaType) + 1 : 0)
      .value(this.selectedAntennaType ? ANTENNA_TYPE_LABELS[this.selectedAntennaType] : '天线类型')
      .onSelect((index: number) => {
        if (index === 0) {
          this.selectedAntennaType = null;
        } else {
          this.selectedAntennaType = Object.keys(ANTENNA_TYPE_LABELS)[index - 1];
        }
        this.onFilterChange();
      })
      .height(36);

      Blank().layoutWeight(1);

      // 频段筛选
      Select([
        { value: 'all', icon: '' },
        ...Object.entries(FREQUENCY_BAND_LABELS).map(([k, v]) => ({ value: k, icon: '' }))
      ])
      .selected(this.selectedFreqBand ? Object.keys(FREQUENCY_BAND_LABELS).indexOf(this.selectedFreqBand) + 1 : 0)
      .value(this.selectedFreqBand ? FREQUENCY_BAND_LABELS[this.selectedFreqBand] : '工作频段')
      .onSelect((index: number) => {
        if (index === 0) {
          this.selectedFreqBand = null;
        } else {
          this.selectedFreqBand = Object.keys(FREQUENCY_BAND_LABELS)[index - 1];
        }
        this.onFilterChange();
      })
      .height(36);
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 4, bottom: 4 });
  }

  @Builder
  private buildActiveFilterTags() {
    Scroll() {
      Row() {
        ForEach(this.activeTags, (tag: FilterTag) => {
          Row() {
            Text(tag.label)
              .fontSize(12)
              .fontColor(PRIMARY);
            Text('✕')
              .fontSize(11)
              .fontColor(PRIMARY)
              .margin({ left: 4 });
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(PRIMARY_LIGHT)
          .borderRadius(12)
          .onClick(() => this.removeTag(tag));
        }, (tag: FilterTag) => tag.key + tag.value);
      }
      .padding({ left: 16, right: 16, top: 4, bottom: 4 });
    }
    .width('100%')
    .scrollable(ScrollDirection.Horizontal);
  }

  @Builder
  private buildSortBar() {
    Row() {
      Text('排序方式: ')
        .fontSize(13)
        .fontColor(TEXT_SECONDARY);

      Row() {
        Text('下载最多')
          .fontSize(13)
          .fontColor(this.sortBy === 'downloadCount' ? PRIMARY : TEXT_SECONDARY);
      }
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .backgroundColor(this.sortBy === 'downloadCount' ? PRIMARY_LIGHT : 'transparent')
      .borderRadius(12)
      .onClick(() => {
        this.sortBy = 'downloadCount';
        this.onFilterChange();
      });

      Row() {
        Text('评分最高')
          .fontSize(13)
          .fontColor(this.sortBy === 'rating' ? PRIMARY : TEXT_SECONDARY);
      }
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .backgroundColor(this.sortBy === 'rating' ? PRIMARY_LIGHT : 'transparent')
      .borderRadius(12)
      .margin({ left: 8 })
      .onClick(() => {
        this.sortBy = 'rating';
        this.onFilterChange();
      });

      Row() {
        Text('最新发布')
          .fontSize(13)
          .fontColor(this.sortBy === 'createdAt' ? PRIMARY : TEXT_SECONDARY);
      }
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .backgroundColor(this.sortBy === 'createdAt' ? PRIMARY_LIGHT : 'transparent')
      .borderRadius(12)
      .margin({ left: 8 })
      .onClick(() => {
        this.sortBy = 'createdAt';
        this.onFilterChange();
      });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 6, bottom: 6 });
  }

  @Builder
  private buildTemplateCard(template: TemplateInfo) {
    Row() {
      // 缩略图
      Column() {
        Text(template.name.charAt(0))
          .fontSize(22)
          .fontColor(PRIMARY);
      }
      .width(60)
      .height(60)
      .backgroundColor(PRIMARY_LIGHT)
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);

      // 信息区
      Column({ space: 4 }) {
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
          if (template.frequencyBands.length > 0) {
            Text(FREQUENCY_BAND_LABELS[template.frequencyBands[0]] || template.frequencyBands[0])
              .fontSize(11)
              .fontColor(TEXT_MUTED)
              .margin({ left: 8 });
          }
        }

        Row() {
          Text(`${template.downloadCount} 次下载`)
            .fontSize(11)
            .fontColor(TEXT_MUTED);
          if (template.rating) {
            Text(`★ ${template.rating}`)
              .fontSize(11)
              .fontColor('#FFA500')
              .margin({ left: 8 });
          }
          Blank().layoutWeight(1);
          Text(template.ownerName)
            .fontSize(11)
            .fontColor(TEXT_MUTED);
        }
      }
      .layoutWeight(1)
      .margin({ left: 12 });

      // 操作区
      Column({ space: 6 }) {
        Button({ type: ButtonType.Normal }) {
          Text('下载').fontSize(11).fontColor(SURFACE);
        }
        .backgroundColor(PRIMARY)
        .borderRadius(14)
        .height(28)
        .width(56)
        .onClick(() => this.handleDownload(template));

        Row() {
          Text(template.isFavorited ? '★' : '☆')
            .fontSize(16)
            .fontColor(template.isFavorited ? '#FFA500' : TEXT_MUTED);
        }
        .onClick(() => this.handleFavorite(template));
      }
      .height(60)
      .justifyContent(FlexAlign.Center);
    }
    .width('100%')
    .padding(12)
    .backgroundColor(SURFACE)
    .borderRadius(8)
    .margin({ left: 16, right: 16, bottom: 8 })
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 });
  }
}
