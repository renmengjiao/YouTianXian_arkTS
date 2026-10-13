import { ApiError, ApiErrorKind, PageData } from '../api/httpClient';
import { fetchLoginRecords, clearLoginRecords } from '../api/userApi';
import { fetchUploadRecords, clearUploadRecords } from '../api/uploadApi';
import { fetchSharedRecords, deleteSharedRecord } from '../api/shareApi';
import { SessionManager } from '../session/SessionManager';
import { ClearRecordsResult, RecordTimeFilter, LoginRecordFilter, UploadRecordFilter,
  ShareRecordFilter } from '../model/CommonModels';

export type RecordKind = 'login' | 'uploads' | 'shares';
export interface RecordRow { id: string; title: string; detail: string; status: string; }
interface RecordPage { list: RecordRow[]; total: number; page: number; }

/** 三组记录共用分页与异步保护；不改动认证或网络层。 */
@Observed
export class RecordListState {
  rows: RecordRow[] = [];
  page: number = 1;
  total: number = 0;
  loading: boolean = false;
  mutating: boolean = false;
  errorMessage: string = '';
  notice: string = '';
  readonly pageSize: number = 10;
  private active: boolean = false;
  private generation: number = 0;
  private revision: number = 0;
  private filters: RecordTimeFilter = {};
  private filterValue: string = 'all';
  private kind: RecordKind;

  constructor(kind: RecordKind) { this.kind = kind; }
  get busy(): boolean { return this.loading || this.mutating; }
  get pages(): number { return Math.max(1, Math.ceil(this.total / this.pageSize)); }
  getRevision(): number { return this.revision; }
  activate(): void {
    this.active = true;
    this.generation = SessionManager.getInstance().getSessionGeneration();
  }
  deactivate(): void { this.active = false; this.revision++; }
  private current(revision: number): boolean {
    return this.active && revision === this.revision
      && this.generation === SessionManager.getInstance().getSessionGeneration();
  }

  static validateTime(value: string): void {
    if (!/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/.test(value)) {
      throw new Error('时间格式应为 yyyy-MM-dd HH:mm:ss');
    }
    const year = Number(value.substring(0, 4));
    const month = Number(value.substring(5, 7));
    const day = Number(value.substring(8, 10));
    const hour = Number(value.substring(11, 13));
    const minute = Number(value.substring(14, 16));
    const second = Number(value.substring(17, 19));
    const leap = year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0);
    const days = [31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (year < 1 || month < 1 || month > 12 || day < 1 || day > days[month - 1]
      || hour > 23 || minute > 59 || second > 59) throw new Error('请输入有效的日期和时间');
  }

  async search(start: string, end: string, value: string): Promise<void> {
    if (this.busy || !this.current(this.revision)) return;
    try {
      const filters: RecordTimeFilter = {};
      if (start.trim()) { RecordListState.validateTime(start.trim()); filters.startTime = start.trim(); }
      if (end.trim()) { RecordListState.validateTime(end.trim()); filters.endTime = end.trim(); }
      if (filters.startTime && filters.endTime && filters.startTime > filters.endTime) {
        throw new Error('开始时间不能晚于结束时间');
      }
      const allowed = this.kind === 'login' ? ['all', 'web', 'mobile']
        : this.kind === 'uploads' ? ['all', 'completed', 'failed'] : ['all', 'template', 'image'];
      if (!allowed.includes(value)) throw new Error('筛选值不受当前后端支持');
      this.filters = filters;
      this.filterValue = value;
      await this.load(1);
    } catch (error) { if (this.current(this.revision)) this.errorMessage = (error as Error).message; }
  }

  private checkPage<T>(data: PageData<T>, requested: number): void {
    if (!data || !Array.isArray(data.list) || !Number.isSafeInteger(data.total) || data.total < 0
      || data.page !== requested || data.pageSize !== this.pageSize) {
      throw new ApiError(ApiErrorKind.RESPONSE, '记录分页响应格式异常');
    }
  }
  private id(value: string): string {
    if (typeof value !== 'string' || !/^\d+$/.test(value)) {
      throw new ApiError(ApiErrorKind.RESPONSE, '记录 ID 应为数字字符串');
    }
    return value;
  }
  private text(value: string | null): string { return value || '未提供'; }
  private async fetch(page: number): Promise<RecordPage> {
    if (this.kind === 'login') {
      const filter: LoginRecordFilter = {};
      if (this.filters.startTime) filter.startTime = this.filters.startTime;
      if (this.filters.endTime) filter.endTime = this.filters.endTime;
      if (this.filterValue !== 'all') filter.deviceType = this.filterValue;
      const data = (await fetchLoginRecords(page, this.pageSize, filter)).data;
      this.checkPage(data, page);
      const rows = data.list.map((item): RecordRow => ({
        id: this.id(item.id), title: this.text(item.deviceInfo),
        detail: this.text(item.deviceType) + ' · IP ' + this.text(item.ipAddress) + ' · '
          + this.text(item.location) + ' · ' + this.text(item.loginTime)
          + ' · 会话时长（服务端值）' + (item.sessionDuration === null ? '未提供' : String(item.sessionDuration)),
        status: item.status === 'success' ? '登录成功' : item.status === 'failed' ? '登录失败' : item.status
      }));
      return { list: rows, total: data.total, page: data.page };
    }
    if (this.kind === 'uploads') {
      const filter: UploadRecordFilter = {};
      if (this.filters.startTime) filter.startTime = this.filters.startTime;
      if (this.filters.endTime) filter.endTime = this.filters.endTime;
      if (this.filterValue !== 'all') filter.status = this.filterValue;
      const data = (await fetchUploadRecords(page, this.pageSize, filter)).data;
      this.checkPage(data, page);
      const rows = data.list.map((item): RecordRow => ({
        id: this.id(item.id), title: this.text(item.fileName),
        detail: this.text(item.fileSize) + ' · ' + this.text(item.uploadTime)
          + ' · 状态进度 ' + String(item.uploadProgress) + '%（非实时）',
        status: item.uploadStatus === 'completed' ? '已完成' : item.uploadStatus === 'pending' ? '处理中'
          : item.uploadStatus === 'failed' ? '失败' : item.uploadStatus === 'rejected' ? '已拒绝' : item.uploadStatus
      }));
      return { list: rows, total: data.total, page: data.page };
    }
    const filter: ShareRecordFilter = {};
    if (this.filters.startTime) filter.startTime = this.filters.startTime;
    if (this.filters.endTime) filter.endTime = this.filters.endTime;
    if (this.filterValue !== 'all') filter.fileType = this.filterValue;
    const data = (await fetchSharedRecords(page, this.pageSize, filter)).data;
    this.checkPage(data, page);
    const rows = data.list.map((item): RecordRow => ({
      id: this.id(item.id), title: this.text(item.fileName),
      detail: '接收用户 ID：' + (item.sharedWith.length ? item.sharedWith.join('、') : '未提供')
        + ' · ' + this.text(item.shareTime) + ' · ' + (item.permission === 'view' ? '可查看' : item.permission === 'edit' ? '可编辑' : item.permission)
        + ' · 到期时间：' + this.text(item.expireTime),
      status: item.status === 'active' ? '有效' : item.status === 'expired' ? '已过期'
        : item.status === 'revoked' ? '已撤销' : item.status
    }));
    return { list: rows, total: data.total, page: data.page };
  }

  async load(page: number = this.page): Promise<void> {
    if (this.busy || !this.current(this.revision)) return;
    this.notice = '';
    await this.read(page);
  }
  private async read(page: number): Promise<boolean> {
    const revision = ++this.revision;
    this.loading = true;
    this.errorMessage = '';
    this.rows = [];
    this.page = Math.max(1, page);
    try {
      let data = await this.fetch(this.page);
      if (!this.current(revision)) return false;
      const lastPage = Math.max(1, Math.ceil(data.total / this.pageSize));
      if (data.page > lastPage) {
        data = await this.fetch(lastPage);
        if (!this.current(revision)) return false;
      }
      this.rows = data.list;
      this.total = data.total;
      this.page = data.page;
      return true;
    } catch (error) {
      if (this.current(revision)) { this.errorMessage = (error as Error).message || '记录读取失败'; this.total = 0; }
      return false;
    } finally { if (this.current(revision)) this.loading = false; }
  }

  /** 只执行当前页面、当前会话确认的操作。 */
  async remove(revision: number, id: string = '', beforeTime: string = ''): Promise<void> {
    if (!this.current(revision) || this.busy || this.errorMessage) return;
    try {
      if (beforeTime) RecordListState.validateTime(beforeTime.trim());
      if (id) {
        this.id(id);
        if (!this.rows.some((row: RecordRow) => row.id === id)) throw new Error('记录已变化，请重新读取');
      }
      if (this.kind === 'shares' && !id) throw new Error('请选择共享记录');
    } catch (error) { this.errorMessage = (error as Error).message; return; }
    this.mutating = true;
    this.notice = '';
    try {
      let count: number = 0;
      if (this.kind === 'shares') {
        await deleteSharedRecord(id);
      } else {
        let result: ClearRecordsResult;
        if (this.kind === 'uploads') {
          result = (await clearUploadRecords(id ? { ids: [id], clearAll: false } : { clearAll: true })).data;
        } else {
          result = (await clearLoginRecords(beforeTime ? { clearAll: false, beforeTime: beforeTime.trim() } : { clearAll: true })).data;
        }
        if (!result || !Number.isSafeInteger(result.deletedCount) || result.deletedCount < 0) {
          throw new ApiError(ApiErrorKind.RESPONSE, '清理响应缺少有效的 deletedCount');
        }
        count = result.deletedCount;
      }
      if (!this.current(revision)) return;
      this.notice = this.kind === 'shares' ? '共享记录已删除' : '已清理 ' + String(count) + ' 条记录';
      if (!await this.read(this.page) && this.current(this.revision)) {
        this.errorMessage = '操作已成功，但列表重新读取失败：' + this.errorMessage;
      }
    } catch (error) {
      if (this.current(revision)) {
        const failure = error as ApiError;
        const uncertain = failure instanceof ApiError && (failure.kind === ApiErrorKind.NETWORK
          || failure.kind === ApiErrorKind.RESPONSE || failure.httpStatus >= 500);
        this.errorMessage = (uncertain ? '操作结果未确认，请重新读取核对。' : '') + (error as Error).message;
      }
    } finally {
      if (this.active && this.generation === SessionManager.getInstance().getSessionGeneration()) this.mutating = false;
    }
  }
}
