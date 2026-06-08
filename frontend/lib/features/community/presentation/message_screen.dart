import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/community_api_service.dart';
import '../data/community_liked_post_store.dart';
import '../data/mock_community_post_store.dart';
import '../model/community_post.dart';
import 'community_post_create_screen.dart';
import 'community_post_detail_screen.dart';

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

  final _communityApiService = CommunityApiService();
  String _selectedCategory = '전체';
  List<CommunityPost> _posts = const [];
  bool _isLoading = true;
  bool _usingMockFallback = false;
  String? _errorMessage;
  final Set<int> _likingPostIds = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final posts = await _communityApiService.fetchPosts(
        category: communityCategoryValue(_selectedCategory),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = posts;
        _usingMockFallback = false;
      });
    } on CommunityApiException catch (exception) {
      _useMockFallback(exception.message);
    } catch (_) {
      _useMockFallback('게시글을 불러오지 못했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _useMockFallback(String message) {
    if (!mounted) {
      return;
    }
    final category = communityCategoryValue(_selectedCategory);
    setState(() {
      _errorMessage = message;
      _usingMockFallback = true;
      _posts = mockCommunityPostStore.posts
          .where((post) => category == null || post.category == category)
          .toList();
    });
  }

  void _selectCategory(String category) {
    setState(() => _selectedCategory = category);
    _loadPosts();
  }

  Future<void> _onWritePressed() async {
    if (!mockAuthController.isLoggedIn) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const LoginScreen(popAfterLogin: true),
        ),
      );
      return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => const CommunityPostCreateScreen(
          initialCategory: '활동 후기',
          initialRegion: '서울 마포구',
        ),
      ),
    );
    if (created == true) {
      await _loadPosts();
    }
  }

  Future<void> _likePost(CommunityPost post) async {
    if (post.sourceType == 'mock') {
      _showMessage('백엔드 연결 후 좋아요를 사용할 수 있습니다.');
      return;
    }

    final accessToken = mockAuthController.accessToken;
    if (accessToken == null) {
      _showMessage('로그인이 필요합니다.');
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const LoginScreen(popAfterLogin: true),
        ),
      );
      return;
    }

    setState(() => _likingPostIds.add(post.id));
    final wasLiked = communityLikedPostStore.isLiked(post.id);
    try {
      final updated = wasLiked
          ? await _communityApiService.unlikePost(post.id, accessToken)
          : await _communityApiService.likePost(post.id, accessToken);
      if (mounted) {
        if (wasLiked) {
          communityLikedPostStore.markUnliked(post.id);
        } else {
          communityLikedPostStore.markLiked(post.id);
        }
        setState(() {
          _posts = _posts
              .map((item) => item.id == updated.id ? updated : item)
              .toList();
        });
      }
    } on CommunityApiException catch (exception) {
      if (!wasLiked && exception.isDuplicateLike) {
        await _forceUnlike(post, accessToken);
      } else if (wasLiked && _isUnlikeStateConflict(exception)) {
        if (mounted) {
          communityLikedPostStore.markUnliked(post.id);
          setState(() {
            _posts = _posts
                .map((item) => item.id == post.id ? _safelyUnliked(item) : item)
                .toList();
          });
        }
      } else if (mounted) {
        _showMessage('좋아요 처리에 실패했습니다.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('좋아요 처리에 실패했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _likingPostIds.remove(post.id));
      }
    }
  }

  Future<void> _forceUnlike(CommunityPost post, String accessToken) async {
    try {
      final updated = await _communityApiService.unlikePost(
        post.id,
        accessToken,
      );
      if (mounted) {
        communityLikedPostStore.markUnliked(post.id);
        setState(() {
          _posts = _posts
              .map((item) => item.id == updated.id ? updated : item)
              .toList();
        });
      }
    } catch (_) {
      if (mounted) {
        communityLikedPostStore.markUnliked(post.id);
        setState(() {
          _posts = _posts
              .map((item) => item.id == post.id ? _safelyUnliked(item) : item)
              .toList();
        });
      }
    }
  }

  bool _isUnlikeStateConflict(CommunityApiException exception) {
    return exception.statusCode == 404 || exception.statusCode == 409;
  }

  CommunityPost _safelyUnliked(CommunityPost post) {
    return post.copyWith(
      likeCount: post.likeCount > 0 ? post.likeCount - 1 : 0,
    );
  }

  Future<void> _openPostDetail(CommunityPost post) async {
    if (post.sourceType == 'mock') {
      _showMessage('백엔드 연결 후 상세 화면을 사용할 수 있습니다.');
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CommunityPostDetailScreen(postId: post.id),
      ),
    );
    await _loadPosts();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPosts,
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
              const SizedBox(height: 18),
              if (_errorMessage != null)
                _CommunityLoadError(
                  message: _usingMockFallback
                      ? '$_errorMessage\n임시 게시글을 표시합니다.'
                      : _errorMessage!,
                  onRetry: _loadPosts,
                ),
              if (_errorMessage != null) const SizedBox(height: 18),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                _PostListSection(
                  posts: _posts,
                  likingPostIds: _likingPostIds,
                  onLikePressed: _likePost,
                  onPostPressed: _openPostDetail,
                ),
            ],
          ),
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
  const _PostListSection({
    required this.posts,
    required this.likingPostIds,
    required this.onLikePressed,
    required this.onPostPressed,
  });

  final List<CommunityPost> posts;
  final Set<int> likingPostIds;
  final ValueChanged<CommunityPost> onLikePressed;
  final ValueChanged<CommunityPost> onPostPressed;

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
              _PostCard(
                post: posts[index],
                isLiked: communityLikedPostStore.isLiked(posts[index].id),
                isLiking: likingPostIds.contains(posts[index].id),
                onLikePressed: () => onLikePressed(posts[index]),
                onPostPressed: () => onPostPressed(posts[index]),
              ),
              if (index != posts.length - 1) const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.isLiked,
    required this.isLiking,
    required this.onLikePressed,
    required this.onPostPressed,
  });

  final CommunityPost post;
  final bool isLiked;
  final bool isLiking;
  final VoidCallback onLikePressed;
  final VoidCallback onPostPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPostPressed,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
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
                        post.categoryLabel,
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
                    InkWell(
                      onTap: isLiking ? null : onLikePressed,
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          isLiking
                              ? Icons.hourglass_empty
                              : isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isLiked
                              ? Colors.redAccent
                              : _MessageScreenState._grayText,
                          size: 17,
                        ),
                      ),
                    ),
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
          ),
        ],
      ),
    );
  }
}

class _CommunityLoadError extends StatelessWidget {
  const _CommunityLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _CommunityCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: _MessageScreenState._grayText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('다시 시도'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _MessageScreenState._green,
              side: const BorderSide(color: _MessageScreenState._green),
            ),
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
