import 'package:flutter/foundation.dart';

import '../model/activity_record.dart';

class MockActivityRecordStore {
  MockActivityRecordStore()
    : _records = ValueNotifier<List<ActivityRecord>>(_initialRecords);

  final ValueNotifier<List<ActivityRecord>> _records;

  ValueListenable<List<ActivityRecord>> get recordsListenable => _records;

  List<ActivityRecord> get records => List.unmodifiable(_records.value);

  void addRecord(ActivityRecord record) {
    _records.value = [record, ..._records.value];
  }

  static const _initialRecords = [
    ActivityRecord(
      id: 'mock-personal-20260525',
      type: '개인',
      date: '2026.05.25',
      region: '서울 마포구',
      duration: '42분',
      distance: '3.2km',
      trashCertificationCount: 8,
      summary: '퇴근길 산책로 플로깅',
    ),
    ActivityRecord(
      id: 'mock-group-20260518',
      type: '단체',
      date: '2026.05.18',
      region: '서울 마포구',
      duration: '1시간 12분',
      distance: '5.4km',
      trashCertificationCount: 21,
      summary: '홍대 골목 정리 모임',
    ),
    ActivityRecord(
      id: 'mock-personal-20260509',
      type: '개인',
      date: '2026.05.09',
      region: '서울 상암동',
      duration: '35분',
      distance: '2.6km',
      trashCertificationCount: 6,
      summary: '공원 둘레길 쓰레기 수거',
    ),
  ];
}

final mockActivityRecordStore = MockActivityRecordStore();
