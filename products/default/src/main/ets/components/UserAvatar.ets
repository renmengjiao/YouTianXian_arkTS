import { resolveAvatarUrl } from '../api/ResourceUrl';
import { PRIMARY } from '../constants/CommonConstants';

@Component
export struct UserAvatar {
  @Prop avatar: string | null = null;
  @Prop nickname: string = '';
  @Prop avatarSize: number = 64;
  @State private failedUrl: string = '';

  @Builder
  private buildImage(url: string) {
    Image(url)
      .width(this.avatarSize).height(this.avatarSize).borderRadius(this.avatarSize / 2)
      .objectFit(ImageFit.Cover)
      .onError(() => this.failedUrl = url);
  }

  build() {
    if (resolveAvatarUrl(this.avatar) && this.failedUrl !== resolveAvatarUrl(this.avatar)) {
      this.buildImage(resolveAvatarUrl(this.avatar));
    } else {
      Text(this.nickname.slice(0, 1) || '用')
        .width(this.avatarSize).height(this.avatarSize).textAlign(TextAlign.Center)
        .fontSize(this.avatarSize * 0.4).fontWeight(FontWeight.Bold)
        .fontColor(Color.White).backgroundColor(PRIMARY).borderRadius(this.avatarSize / 2);
    }
  }
}
