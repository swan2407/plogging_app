import 'package:flutter/material.dart';

import '../model/home_dashboard_models.dart';

const todayPloggingDateText = '5월 25일';
const todayPloggingDescription = '가까운 공원 코스를 따라 가볍게 시작해보세요.';

const todayPloggingMetrics = [
  HomeMetric(icon: Icons.directions_walk, value: '2.4 km', label: '추천 거리'),
  HomeMetric(icon: Icons.delete_outline, value: '12개', label: '목표 수거'),
  HomeMetric(icon: Icons.schedule, value: '35분', label: '예상 시간'),
];

const homeScheduleItems = [
  HomeListItemData(
    icon: Icons.park_outlined,
    title: '한강 산책로 플로깅',
    subtitle: '오늘 오후 6:30 · 마포구',
  ),
  HomeListItemData(
    icon: Icons.local_florist_outlined,
    title: '주말 공원 정리',
    subtitle: '토요일 오전 9:00 · 서대문구',
  ),
];

const homeGroupPreviewItems = [
  HomeListItemData(
    icon: Icons.location_on_outlined,
    title: '연남동 골목 플로깅',
    subtitle: '8명 참여 예정 · 1.2km 거리',
  ),
  HomeListItemData(
    icon: Icons.location_on_outlined,
    title: '홍제천 환경 모임',
    subtitle: '모집중 12/20 · 내일 오후 7:00',
  ),
];

const homeCommunityItems = [
  HomeListItemData(
    icon: Icons.article_outlined,
    title: '오늘 수거한 캔이 정말 많았어요',
    subtitle: '마포구 · 댓글 3개',
  ),
  HomeListItemData(
    icon: Icons.article_outlined,
    title: '처음 플로깅을 시작하는 분들께',
    subtitle: '서대문구 · 좋아요 18개',
  ),
];
