import { asset } from '@kit.AssetStoreKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

export interface RememberedSession {
  backendUrl: string;
  refreshToken: string;
}

/** 仅保存刷新令牌，不保存密码或访问令牌。 */
export class SessionStore {
  private static alias(): Uint8Array {
    return new util.TextEncoder().encodeInto('YouTianXian.session.v1');
  }

  private static query(): asset.AssetMap {
    const query: asset.AssetMap = new Map<asset.Tag, asset.Value>();
    query.set(asset.Tag.ALIAS, SessionStore.alias());
    return query;
  }

  static async read(): Promise<RememberedSession | null> {
    const query = SessionStore.query();
    query.set(asset.Tag.RETURN_TYPE, asset.ReturnType.ALL);
    query.set(asset.Tag.RETURN_LIMIT, 1);
    let entries: asset.AssetMap[];
    try {
      entries = await asset.query(query);
    } catch (error) {
      if ((error as BusinessError).code === asset.ErrorCode.NOT_FOUND) {
        return null;
      }
      throw new Error('无法读取本机登录状态，请重试');
    }
    if (entries.length === 0) {
      return null;
    }
    const secret = entries[0].get(asset.Tag.SECRET);
    if (!(secret instanceof Uint8Array)) {
      await SessionStore.clear();
      return null;
    }
    let session: RememberedSession;
    try {
      session = JSON.parse(new util.TextDecoder('utf-8')
        .decodeToString(secret)) as RememberedSession;
    } catch {
      await SessionStore.clear();
      return null;
    }
    if (!session || typeof session.backendUrl !== 'string'
      || typeof session.refreshToken !== 'string'
      || session.refreshToken.length === 0) {
      await SessionStore.clear();
      return null;
    }
    return session;
  }

  static async save(session: RememberedSession): Promise<void> {
    const attributes = SessionStore.query();
    attributes.set(asset.Tag.SECRET, new util.TextEncoder()
      .encodeInto(JSON.stringify(session)));
    attributes.set(asset.Tag.ACCESSIBILITY, asset.Accessibility.DEVICE_UNLOCKED);
    attributes.set(asset.Tag.AUTH_TYPE, asset.AuthType.NONE);
    attributes.set(asset.Tag.CONFLICT_RESOLUTION, asset.ConflictResolution.OVERWRITE);
    try {
      await asset.add(attributes);
    } catch {
      throw new Error('无法保存登录状态；请重试或取消记住登录');
    }
  }

  static async clear(): Promise<void> {
    try {
      await asset.remove(SessionStore.query());
    } catch (error) {
      if ((error as BusinessError).code !== asset.ErrorCode.NOT_FOUND) {
        throw new Error('无法清除本机记住的登录状态，请重试');
      }
    }
  }
}
