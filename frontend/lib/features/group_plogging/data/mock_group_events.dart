import '../model/group_event.dart';

// Development fallback shown only when the backend group-event list cannot load.
final fallbackGroupEvents = [
  GroupEvent(
    id: -1,
    title: '한강공원 아침 플로깅',
    leaderId: -1,
    leaderNickname: '초록러너',
    regionSido: '서울',
    regionSigungu: '마포구',
    startAt: DateTime(2026, 6, 8, 8),
    endAt: DateTime(2026, 6, 8, 10),
    recruitDeadlineAt: DateTime(2026, 6, 8, 6),
    maxParticipants: 20,
    currentParticipants: 12,
    placeName: '망원한강공원 2번 출구',
    address: null,
    supplies: '장갑, 집게, 물병',
    description: '백엔드 연결 실패 시 표시되는 개발용 예시 데이터입니다.',
    status: 'RECRUITING',
    createdAt: DateTime(2026, 6, 1),
  ),
];
