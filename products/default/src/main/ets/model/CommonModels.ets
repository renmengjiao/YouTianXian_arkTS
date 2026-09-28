/** 共享记录 */
export interface ShareRecord {
  id: number;
  title: string;             // 项目/文件名
  sharedBy: string;          // 分享者
  sharedDate: string;        // 分享日期
  projectId?: string;        // 项目 ID
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

/** 登录记录 */
export interface LoginRecord {
  id: number;
  device: string;
  location: string;
  ip: string;
  time: string;
  status: string;            // success / failed
}

/** 上传记录 */
export interface UploadRecord {
  id: number;
  fileName: string;
  fileSize: string;
  uploadTime: string;
  status: string;            // completed / uploading / failed
  progress?: number;
}
