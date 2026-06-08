import 'package:flutter/foundation.dart';

import '../model/community_post.dart';

class MockCommunityPostStore {
  MockCommunityPostStore()
    : _posts = ValueNotifier<List<CommunityPost>>(_initialPosts);

  final ValueNotifier<List<CommunityPost>> _posts;

  ValueListenable<List<CommunityPost>> get postsListenable => _posts;

  List<CommunityPost> get posts => List.unmodifiable(_posts.value);

  void addPost(CommunityPost post) {
    _posts.value = [post, ..._posts.value];
  }

  static final _initialPosts = [
    CommunityPost(
      id: -1,
      userId: -1,
      category: 'ACTIVITY_REVIEW',
      title: '망원한강공원에서 40분 플로깅했어요',
      content: '산책로 주변에 일회용 컵이 많아서 집중적으로 주웠습니다. 다음에는 장갑을 더 챙겨가려고요.',
      regionSido: '서울',
      regionSigungu: '마포구',
      authorNickname: '초록걸음',
      sessionId: null,
      imageUrl: null,
      createdAt: DateTime(2026, 5, 26),
      likeCount: 24,
      commentCount: 6,
      sourceType: 'mock',
      linkedActivitySummary: '40분 · 3.2km · 쓰레기 인증 8개',
    ),
    CommunityPost(
      id: -2,
      userId: -2,
      category: 'GROUP_PROMOTION',
      title: '이번 토요일 상암동 단체 플로깅 함께해요',
      content: '오전 10시에 월드컵공원 입구에서 모입니다. 봉투와 집게는 여분을 준비해둘게요.',
      regionSido: '서울',
      regionSigungu: '마포구 상암동',
      authorNickname: '마포러너',
      sessionId: null,
      imageUrl: null,
      createdAt: DateTime(2026, 5, 25),
      likeCount: 31,
      commentCount: 12,
      sourceType: 'mock',
    ),
    CommunityPost(
      id: -3,
      userId: -3,
      category: 'INFO_SHARE',
      title: '분리수거 가능한 투명 페트병 기준 정리',
      content: '라벨을 제거하고 내용물을 비운 뒤 압착하면 수거 효율이 좋아진다고 합니다.',
      regionSido: '서울',
      regionSigungu: '전역',
      authorNickname: '재활용노트',
      sessionId: null,
      imageUrl: null,
      createdAt: DateTime(2026, 5, 24),
      likeCount: 48,
      commentCount: 9,
      sourceType: 'mock',
    ),
    CommunityPost(
      id: -4,
      userId: -4,
      category: 'QUESTION',
      title: '비 오는 날에도 플로깅 모임 진행하시나요?',
      content: '이번 주 예보가 애매해서 다른 분들은 어떤 기준으로 취소 여부를 정하는지 궁금합니다.',
      regionSido: '서울',
      regionSigungu: '서대문구',
      authorNickname: '걷는사람',
      sessionId: null,
      imageUrl: null,
      createdAt: DateTime(2026, 5, 23),
      likeCount: 11,
      commentCount: 8,
      sourceType: 'mock',
    ),
  ];
}

final mockCommunityPostStore = MockCommunityPostStore();
