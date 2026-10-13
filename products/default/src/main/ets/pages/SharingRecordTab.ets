import { RecordListPanel } from '../components/RecordListPanel';

@Component
export struct SharingRecordTab {
  build() { RecordListPanel({ kind: 'shares' }); }
}
