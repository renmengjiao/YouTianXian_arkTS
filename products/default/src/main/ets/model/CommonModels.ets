/** 后端共享记录：当前用户分享出去的内容。 */
export interface ShareRecord {
  id: string;
  fileName: string | null;
  fileType: string;
  fileSize: string | null;
  sharedWith: string[];
  shareTime: string | null;
  permission: string;
  expireTime: string | null;
  status: string;
  previewUrl: string | null;
  downloadUrl: string | null;
}

/** 消息 */
export interface Message {
  id: number;
  title: string;
  content: string;
  type: string;              // system / task / message
  isRead: boolean;
  createdAt: string;
}

/** 后端登录记录。 */
export interface LoginRecord {
  id: string;
  loginTime: string | null;
  ipAddress: string | null;
  location: string | null;
  deviceType: string | null;
  deviceInfo: string | null;
  status: string;
  sessionDuration: number | null;
}

/** 后端模板上传日志，进度是状态推导值。 */
export interface UploadRecord {
  id: string;
  fileName: string | null;
  fileType: string;
  templateType: string | null;
  fileSize: string | null;
  uploadTime: string | null;
  uploadStatus: string;
  storagePath: string | null;
  uploadProgress: number;
  templateVersion: string | null;
  description: string | null;
}

export interface RecordTimeFilter {
  startTime?: string;
  endTime?: string;
}
export interface LoginRecordFilter extends RecordTimeFilter { deviceType?: string; }
export interface UploadRecordFilter extends RecordTimeFilter { status?: string; }
export interface ShareRecordFilter extends RecordTimeFilter { fileType?: string; }
export interface ClearLoginRecordsRequest { clearAll?: boolean; beforeTime?: string; }
export interface ClearUploadRecordsRequest { clearAll?: boolean; ids?: string[]; }
export interface ClearRecordsResult { deletedCount: number; }
