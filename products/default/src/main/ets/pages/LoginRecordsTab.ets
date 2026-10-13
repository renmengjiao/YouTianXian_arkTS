import { RecordListPanel } from '../components/RecordListPanel';

@Component
export struct LoginRecordsTab {
  onBack: () => void = () => {};
  build() {
    Column({ space: 12 }) {
      Button('返回账号安全').onClick(() => this.onBack());
      RecordListPanel({ kind: 'login' });
    }.width('100%');
  }
}
