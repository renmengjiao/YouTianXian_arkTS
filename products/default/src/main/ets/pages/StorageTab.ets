import { SURFACE, TEXT_PRIMARY, TEXT_SECONDARY, TEXT_MUTED, DIVIDER } from '../constants/CommonConstants';

@Component
export struct StorageTab {
  // ── 存储数据 ──
  @State private usedPercent: number = 82;
  @State private usedSpace: string = '422.28 GB';
  @State private totalSpace: string = '512 GB';

  // 四个色块占总量（512 GB）的百分比（用于条形图宽度）
  @State private projectRatio: number = 7;
  @State private templateRatio: number = 5;
  @State private otherRatio: number = 70;
  // 空闲段用 layoutWeight(1) 自动填充剩余

  // 各段的具体数值（用于 Tooltip）
  @State private projectSize: string = '34.5 GB';
  @State private projectPct: number = 8;   // 占已用空间百分比
  @State private templateSize: string = '28.2 GB';
  @State private templatePct: number = 7;  // 占已用空间百分比
  @State private otherSize: string = '359.58 GB';
  @State private otherPct: number = 85;    // 占已用空间百分比
  @State private freeSize: string = '89.72 GB';
  @State private freePct: number = 18;     // 占总空间百分比

  // ── Tooltip 弹出状态 ──
  @State private showProjectTip: boolean = false;
  @State private showTemplateTip: boolean = false;
  @State private showOtherTip: boolean = false;
  @State private showFreeTip: boolean = false;

  build() {
    Column({ space: 24 }) {
      // ════════════════════════════════════════════
      //  存储空间总览
      // ════════════════════════════════════════════
      Column({ space: 20 }) {
        // ── 顶部：大号百分比 + 副标题 ──
        Column({ space: 4 }) {
          Text(`${this.usedPercent}%`)
            .fontSize(28).fontWeight(FontWeight.Bold)
            .fontColor(TEXT_PRIMARY)
            .width('100%')
            .textAlign(TextAlign.Start);
          Text(`已使用 ${this.usedSpace} / ${this.totalSpace}`)
            .fontSize(14).fontColor(TEXT_PRIMARY)
            .width('100%')
            .textAlign(TextAlign.Start);
        }

        // ── 分段水平条形图 ──
        Row() {
          // ① 项目 #007DFF
          Column()
            .height(20)
            .width(`${this.projectRatio}%`)
            .backgroundColor('#007DFF')
            .onHover((isHover: boolean) => { this.showProjectTip = isHover; })
            .bindPopup(this.showProjectTip, {
              message: `项目：${this.projectSize}，占比 ${this.projectPct}%`,
              placement: Placement.Top,
              popupColor: '#333333',
              messageOptions: { textColor: Color.White },
              enableArrow: true,
              radius: 6
            });

          // 1px 白色间隙
          Column().width(1).height(20).backgroundColor(Color.White);

          // ② 模板 #4DA3FF
          Column()
            .height(20)
            .width(`${this.templateRatio}%`)
            .backgroundColor('#4DA3FF')
            .onHover((isHover: boolean) => { this.showTemplateTip = isHover; })
            .bindPopup(this.showTemplateTip, {
              message: `模板：${this.templateSize}，占比 ${this.templatePct}%`,
              placement: Placement.Top,
              popupColor: '#333333',
              messageOptions: { textColor: Color.White },
              enableArrow: true,
              radius: 6
            });

          // 1px 白色间隙
          Column().width(1).height(20).backgroundColor(Color.White);

          // ③ 其他文件 #99CAFF
          Column()
            .height(20)
            .width(`${this.otherRatio}%`)
            .backgroundColor('#99CAFF')
            .onHover((isHover: boolean) => { this.showOtherTip = isHover; })
            .bindPopup(this.showOtherTip, {
              message: `其他文件：${this.otherSize}，占比 ${this.otherPct}%`,
              placement: Placement.Top,
              popupColor: '#333333',
              messageOptions: { textColor: Color.White },
              enableArrow: true,
              radius: 6
            });

          // 1px 白色间隙
          Column().width(1).height(20).backgroundColor(Color.White);

          // ④ 空闲空间 #F7F7F7（占剩余宽度）
          Column()
            .height(20)
            .layoutWeight(1)
            .backgroundColor('#F7F7F7')
            .onHover((isHover: boolean) => { this.showFreeTip = isHover; })
            .bindPopup(this.showFreeTip, {
              message: `空闲空间：${this.freeSize}，占比 ${this.freePct}%`,
              placement: Placement.Top,
              popupColor: '#333333',
              messageOptions: { textColor: Color.White },
              enableArrow: true,
              radius: 6
            });
        }
        .width('100%')
        .height(20)
        .borderRadius(10)
        .clip(true);

        // ── 图例（响应式换行） ──
        Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center }) {
          // 项目
          Row({ space: 6 }) {
            Row()
              .width(10).height(10).borderRadius(5)
              .backgroundColor('#007DFF');
            Text('项目').fontSize(12).fontColor(TEXT_MUTED);
          }
          .margin({ right: 24, bottom: 4 });

          // 模板
          Row({ space: 6 }) {
            Row()
              .width(10).height(10).borderRadius(5)
              .backgroundColor('#4DA3FF');
            Text('模板').fontSize(12).fontColor(TEXT_MUTED);
          }
          .margin({ right: 24, bottom: 4 });

          // 其他文件
          Row({ space: 6 }) {
            Row()
              .width(10).height(10).borderRadius(5)
              .backgroundColor('#99CAFF');
            Text('其他文件').fontSize(12).fontColor(TEXT_MUTED);
          }
          .margin({ bottom: 4 });
        }
        .width('100%');
      }
      .width('100%')
      .padding(24)
      .backgroundColor(SURFACE)
      .borderRadius(12);
    }
    .layoutWeight(1)
    .width('100%')
    .height('100%')
    .padding({ top: 24 });
  }
}
