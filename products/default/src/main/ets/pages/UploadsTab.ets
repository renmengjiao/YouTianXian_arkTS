import { RecordListPanel } from '../components/RecordListPanel';

@Component
export struct UploadsTab {
  build() { RecordListPanel({ kind: 'uploads' }); }
}
