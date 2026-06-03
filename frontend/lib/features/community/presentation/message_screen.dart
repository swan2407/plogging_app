import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/mock_community_post_store.dart';
import '../model/community_post.dart';
import 'community_post_create_screen.dart';

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

  List<CommunityPost> _visiblePosts(List<CommunityPost> posts) {
    if (_selectedCategory == '전체') {
      return posts;
    }

    return posts.where((post) => post.category == _selectedCategory).toList();
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

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const CommunityPostCreateScreen(
          initialCategory: '활동 후기',
          initialRegion: '서울 마포구',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ValueListenableBuilder<List<CommunityPost>>(
          valueListenable: mockCommunityPostStore.postsListenable,
          builder: (context, posts, child) {
            final visiblePosts = _visiblePosts(posts);

            return ListView(
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
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
            );
          },
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
              for (final category in communityPostFilterCategories)
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

  final List<CommunityPost> posts;

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

  final CommunityPost post;

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
            post.content,
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
                  post.authorNickname,
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
