import 'package:flutter/material.dart';

import '../model/my_page_models.dart';

const mockMyPageStats = [
  MyPageStat(
    label: '이번 달 플로깅',
    value: '7회',
    icon: Icons.calendar_month_outlined,
  ),
  MyPageStat(label: '총 이동 거리', value: '74.6km', icon: Icons.route_outlined),
  MyPageStat(label: '쓰레기 인증 수', value: '156개', icon: Icons.delete_outline),
  MyPageStat(label: '참여한 단체 플로깅 수', value: '5회', icon: Icons.groups_outlined),
];

const mockJoinedGroupPloggings = [
  JoinedGroupPlogging(
    title: '한강공원 저녁 플로깅',
    date: '2026.05.30',
    region: '서울 마포구',
    status: '참여 예정',
  ),
  JoinedGroupPlogging(
    title: '홍대 골목 정리 모임',
    date: '2026.05.18',
    region: '서울 마포구',
    status: '완료',
  ),
  JoinedGroupPlogging(
    title: '월드컵공원 주말 플로깅',
    date: '2026.05.11',
    region: '서울 상암동',
    status: '완료',
  ),
];

const mockMyPagePosts = [
  MyPagePost(
    title: '오늘 주운 병뚜껑만 20개예요',
    createdDate: '2026.05.24',
    likes: 18,
    comments: 4,
  ),
  MyPagePost(
    title: '초보 플로거를 위한 준비물',
    createdDate: '2026.05.12',
    likes: 31,
    comments: 9,
  ),
  MyPagePost(
    title: '마포 산책로 쓰레기 지도 공유',
    createdDate: '2026.05.03',
    likes: 24,
    comments: 6,
  ),
];
