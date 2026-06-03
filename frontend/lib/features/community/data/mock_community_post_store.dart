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

  static const _initialPosts = [
    CommunityPost(
      id: 'mock-post-1',
      category: '활동 후기',
      title: '망원한강공원에서 40분 플로깅했어요',
      content: '산책로 주변에 일회용 컵이 많아서 집중적으로 주웠습니다. 다음에는 장갑을 더 챙겨가려고요.',
      region: '서울 마포구',
      authorNickname: '초록걸음',
      createdDate: '5월 26일',
      likeCount: 24,
      commentCount: 6,
      sourceType: 'mock',
      linkedActivitySummary: '40분 · 3.2km · 쓰레기 인증 8개',
    ),
    CommunityPost(
      id: 'mock-post-2',
      category: '모집 홍보',
      title: '이번 토요일 상암동 단체 플로깅 함께해요',
      content: '오전 10시에 월드컵공원 입구에서 모입니다. 봉투와 집게는 여분을 준비해둘게요.',
      region: '서울 마포구 상암동',
      authorNickname: '마포러너',
      createdDate: '5월 25일',
      likeCount: 31,
      commentCount: 12,
      sourceType: 'mock',
    ),
    CommunityPost(
      id: 'mock-post-3',
      category: '정보 공유',
      title: '분리수거 가능한 투명 페트병 기준 정리',
      content: '라벨을 제거하고 내용물을 비운 뒤 압착하면 수거 효율이 좋아진다고 합니다.',
      region: '서울 전역',
      authorNickname: '재활용노트',
      createdDate: '5월 24일',
      likeCount: 48,
      commentCount: 9,
      sourceType: 'mock',
    ),
    CommunityPost(
      id: 'mock-post-4',
      category: '질문',
      title: '비 오는 날에도 플로깅 모임 진행하시나요?',
      content: '이번 주 예보가 애매해서 다른 분들은 어떤 기준으로 취소 여부를 정하는지 궁금합니다.',
      region: '서울 서대문구',
      authorNickname: '걷는사람',
      createdDate: '5월 23일',
      likeCount: 11,
      commentCount: 8,
      sourceType: 'mock',
    ),
  ];
}

final mockCommunityPostStore = MockCommunityPostStore();

const communityPostCategories = ['활동 후기', '모집 홍보', '정보 공유', '질문'];
const communityPostFilterCategories = ['전체', ...communityPostCategories];
