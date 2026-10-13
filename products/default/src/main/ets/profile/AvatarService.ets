import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { AvatarUpload, uploadAvatar } from '../api/userApi';
import { ApiError, ApiErrorKind } from '../api/httpClient';
import { SessionManager } from '../session/SessionManager';
import { ProfileService, ProfileSnapshot, ProfileVerificationError } from './ProfileService';

export class AvatarService {
  static readonly MAX_SIZE: number = 2 * 1024 * 1024;

  private static async readFile(uri: string): Promise<ArrayBuffer> {
    const file = await fileIo.open(uri, fileIo.OpenMode.READ_ONLY);
    try {
      const stat = await fileIo.stat(file.fd);
      if (!Number.isSafeInteger(stat.size) || stat.size <= 0) {
        throw new Error('头像文件不能为空');
      }
      if (stat.size > AvatarService.MAX_SIZE) {
        throw new Error('头像大小不能超过2 MB');
      }
      const data = new ArrayBuffer(stat.size);
      const bytes = new Uint8Array(data);
      let offset = 0;
      while (offset < stat.size) {
        const chunk = new ArrayBuffer(Math.min(65536, stat.size - offset));
        const length = await fileIo.read(file.fd, chunk);
        if (length <= 0 || length > chunk.byteLength) {
          throw new Error('头像文件读取不完整，请重新选择');
        }
        bytes.set(new Uint8Array(chunk, 0, length), offset);
        offset += length;
      }
      return data;
    } finally {
      await fileIo.close(file);
    }
  }

  private static async inspect(data: ArrayBuffer): Promise<AvatarUpload> {
    const source = image.createImageSource(data);
    if (!source) {
      throw new Error('头像必须是可解码的JPG或PNG图片');
    }
    try {
      const info = await source.getImageInfo();
      if (info.mimeType !== 'image/jpeg' && info.mimeType !== 'image/png') {
        throw new Error('头像仅支持JPG、PNG格式');
      }
      const pixels = await source.createPixelMap({ desiredSize: { width: 64, height: 64 } });
      await pixels.release();
      return {
        data: data,
        contentType: info.mimeType,
        remoteFileName: info.mimeType === 'image/png' ? 'avatar.png' : 'avatar.jpg'
      };
    } finally {
      await source.release();
    }
  }

  static async chooseAndUpload(baseline: ProfileSnapshot): Promise<ProfileSnapshot | null> {
    const manager = SessionManager.getInstance();
    const userId = baseline.profile.userId;
    manager.assertCurrentUser(userId, baseline.generation);
    const picker = new photoAccessHelper.PhotoViewPicker();
    const options = new photoAccessHelper.PhotoSelectOptions();
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    options.maxSelectNumber = 1;
    const selected = await picker.select(options);
    manager.assertCurrentUser(userId, baseline.generation);
    if (selected.photoUris.length === 0) {
      return null;
    }
    const file = await AvatarService.inspect(await AvatarService.readFile(selected.photoUris[0]));
    manager.assertCurrentUser(userId, baseline.generation);
    let avatarUrl: string;
    try {
      const response = await uploadAvatar(file);
      if (!response.data || typeof response.data.avatarUrl !== 'string'
        || !response.data.avatarUrl) {
        throw new ApiError(ApiErrorKind.RESPONSE, '头像上传响应缺少avatarUrl');
      }
      avatarUrl = response.data.avatarUrl;
    } catch (error) {
      manager.assertCurrentUser(userId, baseline.generation);
      const failure = error as ApiError;
      if (failure instanceof ApiError && (failure.kind === ApiErrorKind.NETWORK
        || failure.kind === ApiErrorKind.RESPONSE || failure.httpStatus >= 500)) {
        throw new ProfileVerificationError('头像上传结果未确认，请重新读取资料核对。' + failure.message);
      }
      throw error as Error;
    }
    let snapshot: ProfileSnapshot;
    try {
      manager.assertCurrentUser(userId, baseline.generation);
      snapshot = await ProfileService.load();
      manager.assertCurrentUser(userId, baseline.generation);
    } catch (error) {
      manager.assertCurrentUser(userId, baseline.generation);
      throw new ProfileVerificationError('头像上传请求已成功，但重新读取失败。' + (error as Error).message);
    }
    if (snapshot.profile.avatar !== avatarUrl) {
      throw new ProfileVerificationError('头像核对不一致，已显示服务端资料。', snapshot);
    }
    return snapshot;
  }
}
