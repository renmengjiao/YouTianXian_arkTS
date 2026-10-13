import { RecordKind, RecordRow, RecordListState } from '../records/RecordListState';
import { PRIMARY, TEXT_PRIMARY, TEXT_MUTED, DANGER, SURFACE, BORDER } from '../constants/CommonConstants';

@Component
export struct RecordListPanel {
  kind: RecordKind = 'uploads';
  @State private state: RecordListState = new RecordListState('uploads');
  @State private startTime: string = '';
  @State private endTime: string = '';
  @State private beforeTime: string = '';
  @State private selectedFilter: number = 0;

  aboutToAppear(): void {
    this.state = new RecordListState(this.kind);
    this.state.activate();
    this.state.load(1);
  }
  aboutToDisappear(): void { this.state.deactivate(); }
  private values(): string[] {
    return this.kind === 'login' ? ['all', 'web', 'mobile']
      : this.kind === 'uploads' ? ['all', 'completed', 'failed'] : ['all', 'template', 'image'];
  }
  private options(): SelectOption[] {
    if (this.kind === 'login') return [{ value: '全部设备' }, { value: 'web' }, { value: 'mobile' }];
    if (this.kind === 'uploads') return [{ value: '全部状态' }, { value: '完成' }, { value: '失败（含拒绝）' }];
    return [{ value: '全部类型' }, { value: '模板项目' }, { value: '图片' }];
  }
  private title(): string {
    return this.kind === 'login' ? '登录记录' : this.kind === 'uploads' ? '模板上传记录' : '我分享的';
  }
  private confirmRemove(id: string = '', before: string = ''): void {
    if (this.state.busy || this.state.errorMessage) return;
    const state = this.state;
    const revision = state.getRevision();
    const message = this.kind === 'shares' ? '确认删除这条共享记录？'
      : id ? '确认清理这条模板上传日志？不会删除文件或释放存储。'
      : before ? '确认清理 ' + before + ' 及之前的登录记录？'
      : '确认清理当前账号的全部' + (this.kind === 'uploads' ? '模板上传日志？不会删除文件或释放存储。' : '登录记录？')
        + '此操作包含当前筛选以外的记录。';
    AlertDialog.show({ title: '确认操作', message: message,
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: { value: '确认', action: () => { state.remove(revision, id, before); } }
    });
  }

  build() {
    Column({ space: 12 }) {
      Text(this.title()).fontSize(18).fontColor(TEXT_PRIMARY);
      TextInput({ text: this.startTime, placeholder: '开始时间（可选）：yyyy-MM-dd HH:mm:ss' })
        .enabled(!this.state.busy).onChange((value: string) => this.startTime = value);
      TextInput({ text: this.endTime, placeholder: '结束时间（可选）：yyyy-MM-dd HH:mm:ss' })
        .enabled(!this.state.busy).onChange((value: string) => this.endTime = value);
      Row({ space: 12 }) {
        Select(this.options()).selected(this.selectedFilter).value(this.options()[this.selectedFilter].value)
          .enabled(!this.state.busy).onSelect((index: number) => this.selectedFilter = index);
        Button('查询').enabled(!this.state.busy)
          .onClick(() => this.state.search(this.startTime, this.endTime, this.values()[this.selectedFilter]));
        Button('重新读取').enabled(!this.state.busy).onClick(() => this.state.load());
      }
      if (this.kind === 'uploads') {
        Text('仅展示模板上传日志；清理日志不会删除文件或释放存储。').fontColor(TEXT_MUTED).fontSize(12);
      } else if (this.kind === 'shares') {
        Text('接收者按用户 ID 展示；当前预览和下载未接入。').fontColor(TEXT_MUTED).fontSize(12);
      } else {
        Text('设备类型按登录请求归类，不等同于实际机型。').fontColor(TEXT_MUTED).fontSize(12);
      }
      if (this.state.notice) { Text(this.state.notice).fontColor(PRIMARY); }
      if (this.state.errorMessage) { Text(this.state.errorMessage).fontColor(DANGER); }
      if (this.state.loading) {
        Text('正在读取记录...').fontColor(TEXT_MUTED);
      } else if (!this.state.errorMessage && this.state.rows.length === 0) {
        Text('暂无符合条件的记录').fontColor(TEXT_MUTED);
      } else {
        ForEach(this.state.rows, (item: RecordRow) => {
          Column({ space: 6 }) {
            Text(item.title).fontSize(14).fontColor(TEXT_PRIMARY);
            Text(item.detail).fontSize(12).fontColor(TEXT_MUTED);
            Row({ space: 12 }) {
              Text(item.status).fontSize(12).fontColor(TEXT_PRIMARY).layoutWeight(1);
              if (this.kind !== 'login') {
                Button(this.kind === 'shares' ? '删除共享记录' : '清理这条日志')
                  .enabled(!this.state.busy && !this.state.errorMessage).fontSize(12)
                  .onClick(() => this.confirmRemove(item.id));
              }
            }.width('100%');
          }.width('100%').padding(12).backgroundColor(SURFACE)
            .border({ width: 1, color: BORDER }).borderRadius(8).alignItems(HorizontalAlign.Start);
        }, (item: RecordRow) => item.id);
      }
      Row({ space: 12 }) {
        Button('上一页').enabled(!this.state.busy && this.state.page > 1)
          .onClick(() => this.state.load(this.state.page - 1));
        Text(this.state.errorMessage ? '列表未读取成功' : '第 ' + this.state.page + '/' + this.state.pages + ' 页，共 ' + this.state.total + ' 条');
        Button('下一页').enabled(!this.state.busy && !this.state.errorMessage && this.state.page < this.state.pages)
          .onClick(() => this.state.load(this.state.page + 1));
      }
      if (this.kind === 'login') {
        TextInput({ text: this.beforeTime, placeholder: '清理此时间及之前的记录：yyyy-MM-dd HH:mm:ss' })
          .enabled(!this.state.busy).onChange((value: string) => this.beforeTime = value);
        Button('按时间清理').enabled(!this.state.busy && !this.state.errorMessage && this.beforeTime.trim().length > 0)
          .onClick(() => this.confirmRemove('', this.beforeTime.trim()));
      }
      if (this.kind !== 'shares') {
        Button('清理当前账号全部记录').enabled(!this.state.busy && !this.state.errorMessage)
          .onClick(() => this.confirmRemove());
      }
    }.width('100%').padding({ left: 18, right: 18 }).alignItems(HorizontalAlign.Start);
  }
}
