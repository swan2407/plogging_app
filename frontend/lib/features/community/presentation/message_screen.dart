import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../auth/presentation/login_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);
  static const _inactive = Color(0xFFE5E7EB);

  String _selectedCategory = '전체';

  List<_CommunityPost> get _visiblePosts {
    if (_selectedCategory == '전체') {
      return _mockPosts;
    }

    return _mockPosts
        .where((post) => post.category == _selectedCategory)
        .toList();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onWritePressed() {
    if (!mockAuthController.isLoggedIn) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const LoginScreen(popAfterLogin: true),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('글쓰기'),
          content: const Text('게시글 작성 기능은 이후 연결 예정입니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visiblePosts = _visiblePosts;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            const _CommunitySummaryCard(),
            const SizedBox(height: 18),
            _CategoryFilterCard(
              selectedCategory: _selectedCategory,
              onCategoryPressed: _selectCategory,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _onWritePressed,
                icon: const Icon(Icons.edit_outlined, size: 22),
                label: const Text(
                  '글쓰기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: _green.withValues(alpha: 0.26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _PostListSection(posts: visiblePosts),
          ],
        ),
      ),
    );
  }
}

class _CommunitySummaryCard extends StatelessWidget {
  const _CommunitySummaryCard();

  @override
  Widget build(BuildContext context) {
    return _CommunityCard(
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _MessageScreenState._lightGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: _MessageScreenState._green,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '플로깅 이야기',
                  style: TextStyle(
                    color: _MessageScreenState._darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  '우리 동네 플로깅 활동을 공유해보세요.',
                  style: TextStyle(
                    color: _MessageScreenState._grayText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterCard extends StatelessWidget {
  const _CategoryFilterCard({
    required this.selectedCategory,
    required this.onCategoryPressed,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategoryPressed;

  @override
  Widget build(BuildContext context) {
    return _CommunityCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.tune_outlined, title: '카테고리'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final category in _categories)
                _CategoryChip(
                  label: category,
                  selected: selectedCategory == category,
                  onPressed: () => onCategoryPressed(category),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? _MessageScreenState._green
              : _MessageScreenState._inactive,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _MessageScreenState._green
                : _MessageScreenState._grayText.withValues(alpha: 0.18),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _MessageScreenState._grayText,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PostListSection extends StatelessWidget {
  const _PostListSection({required this.posts});

  final List<_CommunityPost> posts;

  @override
  Widget build(BuildContext context) {
    return _CommunityCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.article_outlined, title: '게시글'),
          const SizedBox(height: 14),
          if (posts.isEmpty)
            const _EmptyPostList()
          else
            for (var index = 0; index < posts.length; index++) ...[
              _PostCard(post: posts[index]),
              if (index != posts.length - 1) const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final _CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _MessageScreenState._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _MessageScreenState._lightGreen,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  post.category,
                  style: const TextStyle(
                    color: _MessageScreenState._green,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                post.createdDate,
                style: const TextStyle(
                  color: _MessageScreenState._grayText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _MessageScreenState._darkText,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _MessageScreenState._grayText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                color: _MessageScreenState._green,
                size: 17,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  post.region,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _MessageScreenState._darkText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.person_outline,
                color: _MessageScreenState._grayText,
                size: 17,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  post.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _MessageScreenState._grayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.favorite_border,
                color: _MessageScreenState._grayText,
                size: 17,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.likeCount}',
                style: const TextStyle(
                  color: _MessageScreenState._grayText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.mode_comment_outlined,
                color: _MessageScreenState._grayText,
                size: 17,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.commentCount}',
                style: const TextStyle(
                  color: _MessageScreenState._grayText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPostList extends StatelessWidget {
  const _EmptyPostList();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: _MessageScreenState._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        '선택한 카테고리의 게시글이 없습니다.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _MessageScreenState._grayText,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _MessageScreenState._lightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _MessageScreenState._green, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _MessageScreenState._darkText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _CommunityPost {
  const _CommunityPost({
    required this.category,
    required this.title,
    required this.preview,
    required this.region,
    required this.author,
    required this.createdDate,
    required this.likeCount,
    required this.commentCount,
  });

  final String category;
  final String title;
  final String preview;
  final String region;
  final String author;
  final String createdDate;
  final int likeCount;
  final int commentCount;
}

const _categories = ['전체', '활동 후기', '모집 홍보', '정보 공유', '질문'];

const _mockPosts = [
  _CommunityPost(
    category: '활동 후기',
    title: '망원한강공원에서 40분 플로깅했어요',
    preview: '산책로 주변에 일회용 컵이 많아서 집중적으로 주웠습니다. 다음에는 장갑을 더 챙겨가려고요.',
    region: '서울 마포구',
    author: '초록걸음',
    createdDate: '5월 26일',
    likeCount: 24,
    commentCount: 6,
  ),
  _CommunityPost(
    category: '모집 홍보',
    title: '이번 토요일 상암동 단체 플로깅 함께해요',
    preview: '오전 10시에 월드컵공원 입구에서 모입니다. 봉투와 집게는 여분을 준비해둘게요.',
    region: '서울 마포구 상암동',
    author: '마포러너',
    createdDate: '5월 25일',
    likeCount: 31,
    commentCount: 12,
  ),
  _CommunityPost(
    category: '정보 공유',
    title: '분리수거 가능한 투명 페트병 기준 정리',
    preview: '라벨을 제거하고 내용물을 비운 뒤 압착하면 수거 효율이 좋아진다고 합니다.',
    region: '서울 전역',
    author: '재활용노트',
    createdDate: '5월 24일',
    likeCount: 48,
    commentCount: 9,
  ),
  _CommunityPost(
    category: '질문',
    title: '비 오는 날에도 플로깅 모임 진행하시나요?',
    preview: '이번 주 예보가 애매해서 다른 분들은 어떤 기준으로 취소 여부를 정하는지 궁금합니다.',
    region: '서울 서대문구',
    author: '걷는사람',
    createdDate: '5월 23일',
    likeCount: 11,
    commentCount: 8,
  ),
  _CommunityPost(
    category: '활동 후기',
    title: '홍대 골목길 담배꽁초 수거 후기',
    preview: '짧은 거리였지만 생각보다 수거량이 많았습니다. 주변 상점 분들이 응원해주셔서 힘이 났어요.',
    region: '서울 마포구 홍대입구',
    author: '골목지킴이',
    createdDate: '5월 22일',
    likeCount: 37,
    commentCount: 5,
  ),
];
