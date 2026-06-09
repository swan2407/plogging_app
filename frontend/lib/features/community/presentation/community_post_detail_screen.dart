import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/community_api_service.dart';
import '../data/community_liked_post_store.dart';
import '../model/community_post.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  const CommunityPostDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  State<CommunityPostDetailScreen> createState() =>
      _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);

  final _communityApiService = CommunityApiService();
  final _commentController = TextEditingController();

  CommunityPost? _post;
  List<CommunityComment> _comments = const [];
  bool _isLoadingPost = true;
  bool _isLoadingComments = true;
  bool _isSubmittingComment = false;
  bool _isTogglingLike = false;
  String? _postErrorMessage;
  String? _commentsErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    setState(() {
      _isLoadingPost = true;
      _postErrorMessage = null;
    });

    try {
      final post = await _communityApiService.fetchPostDetail(widget.postId);
      if (mounted) {
        setState(() => _post = post);
      }
    } on CommunityApiException catch (exception) {
      debugPrint('Community post detail load failed: $exception');
      if (mounted) {
        setState(() => _postErrorMessage = exception.message);
      }
    } catch (error) {
      debugPrint('Community post detail load failed: $error');
      if (mounted) {
        setState(() => _postErrorMessage = '게시글을 불러오지 못했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPost = false);
      }
    }
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoadingComments = true;
      _commentsErrorMessage = null;
    });

    try {
      final comments = await _communityApiService.fetchComments(widget.postId);
      if (mounted) {
        setState(() => _comments = comments);
      }
    } on CommunityApiException catch (exception) {
      debugPrint('Community comments load failed: $exception');
      if (mounted) {
        setState(() => _commentsErrorMessage = exception.message);
      }
    } catch (error) {
      debugPrint('Community comments load failed: $error');
      if (mounted) {
        setState(() => _commentsErrorMessage = '댓글을 불러오지 못했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingComments = false);
      }
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
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

    setState(() => _isSubmittingComment = true);
    try {
      await _communityApiService.createComment(
        widget.postId,
        content,
        accessToken,
      );
      _commentController.clear();
      await _loadComments();
      await _loadPost();
    } on CommunityApiException catch (exception) {
      debugPrint('Community comment create failed: $exception');
      if (mounted) {
        _showMessage(exception.message);
      }
    } catch (error) {
      debugPrint('Community comment create failed: $error');
      if (mounted) {
        _showMessage('댓글 등록에 실패했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingComment = false);
      }
    }
  }

  Future<void> _toggleLike() async {
    final post = _post;
    if (post == null || _isTogglingLike) {
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

    final wasLiked = communityLikedPostStore.isLiked(post.id);
    setState(() => _isTogglingLike = true);
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
        setState(() => _post = updated);
      }
    } on CommunityApiException catch (exception) {
      debugPrint('Community like toggle failed: $exception');
      if (!wasLiked && exception.isDuplicateLike) {
        await _markAlreadyLiked(post);
      } else if (wasLiked && _isUnlikeStateConflict(exception)) {
        if (mounted) {
          communityLikedPostStore.markUnliked(post.id);
          setState(() => _post = _safelyUnliked(post));
        }
      } else if (mounted) {
        _showMessage('좋아요 처리에 실패했습니다.');
      }
    } catch (error) {
      debugPrint('Community like toggle failed: $error');
      if (mounted) {
        _showMessage('좋아요 처리에 실패했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isTogglingLike = false);
      }
    }
  }

  Future<void> _markAlreadyLiked(CommunityPost post) async {
    try {
      final updated = await _communityApiService.fetchPostDetail(post.id);
      if (mounted) {
        communityLikedPostStore.markLiked(post.id);
        setState(() => _post = updated);
      }
    } catch (error) {
      debugPrint('Community liked-state refresh failed: $error');
      if (mounted) {
        communityLikedPostStore.markLiked(post.id);
        setState(() {});
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

  Future<void> _refresh() async {
    await Future.wait([_loadPost(), _loadComments()]);
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
      appBar: AppBar(
        title: const Text('게시글 상세'),
        backgroundColor: _background,
        foregroundColor: _darkText,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              if (_isLoadingPost)
                const _LoadingCard(message: '게시글을 불러오는 중입니다.')
              else if (_postErrorMessage != null)
                _ErrorCard(message: _postErrorMessage!, onRetry: _loadPost)
              else if (_post != null)
                _PostDetailCard(
                  post: _post!,
                  isLiked: communityLikedPostStore.isLiked(_post!.id),
                  isTogglingLike: _isTogglingLike,
                  onLikePressed: _toggleLike,
                ),
              const SizedBox(height: 18),
              _CommentInputCard(
                controller: _commentController,
                isSubmitting: _isSubmittingComment,
                onSubmit: _submitComment,
              ),
              const SizedBox(height: 18),
              _CommentsCard(
                comments: _comments,
                isLoading: _isLoadingComments,
                errorMessage: _commentsErrorMessage,
                onRetry: _loadComments,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostDetailCard extends StatelessWidget {
  const _PostDetailCard({
    required this.post,
    required this.isLiked,
    required this.isTogglingLike,
    required this.onLikePressed,
  });

  final CommunityPost post;
  final bool isLiked;
  final bool isTogglingLike;
  final VoidCallback onLikePressed;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CategoryBadge(label: post.categoryLabel),
              const Spacer(),
              Text(
                post.createdDate,
                style: const TextStyle(
                  color: _CommunityPostDetailScreenState._grayText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            post.title,
            style: const TextStyle(
              color: _CommunityPostDetailScreenState._darkText,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                color: _CommunityPostDetailScreenState._green,
                size: 18,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  post.region,
                  style: const TextStyle(
                    color: _CommunityPostDetailScreenState._grayText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.person_outline,
                color: _CommunityPostDetailScreenState._grayText,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                post.authorNickname,
                style: const TextStyle(
                  color: _CommunityPostDetailScreenState._grayText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            post.content,
            style: const TextStyle(
              color: _CommunityPostDetailScreenState._darkText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: isTogglingLike ? null : onLikePressed,
                icon: Icon(
                  isTogglingLike
                      ? Icons.hourglass_empty
                      : isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 19,
                ),
                label: Text('${post.likeCount}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isLiked
                      ? Colors.redAccent
                      : _CommunityPostDetailScreenState._grayText,
                  side: BorderSide(
                    color: isLiked
                        ? Colors.redAccent
                        : _CommunityPostDetailScreenState._grayText.withValues(
                            alpha: 0.28,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.mode_comment_outlined, size: 19),
                label: Text('${post.commentCount}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentInputCard extends StatelessWidget {
  const _CommentInputCard({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '댓글을 입력하세요',
                filled: true,
                fillColor: _CommunityPostDetailScreenState._background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: _CommunityPostDetailScreenState._green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(isSubmitting ? '등록 중' : '등록'),
          ),
        ],
      ),
    );
  }
}

class _CommentsCard extends StatelessWidget {
  const _CommentsCard({
    required this.comments,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final List<CommunityComment> comments;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.comment_outlined, title: '댓글'),
          const SizedBox(height: 14),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null)
            _InlineError(message: errorMessage!, onRetry: onRetry)
          else if (comments.isEmpty)
            const _EmptyComments()
          else
            for (var index = 0; index < comments.length; index++) ...[
              _CommentTile(comment: comments[index]),
              if (index != comments.length - 1)
                const Divider(height: 22, color: Color(0xFFE5E7EB)),
            ],
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final CommunityComment comment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.person_outline,
              color: _CommunityPostDetailScreenState._grayText,
              size: 17,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                comment.authorNickname,
                style: const TextStyle(
                  color: _CommunityPostDetailScreenState._darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              comment.createdDate,
              style: const TextStyle(
                color: _CommunityPostDetailScreenState._grayText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          comment.content,
          style: const TextStyle(
            color: _CommunityPostDetailScreenState._darkText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              color: _CommunityPostDetailScreenState._grayText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: _InlineError(message: message, onRetry: onRetry),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: const TextStyle(
            color: _CommunityPostDetailScreenState._grayText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_outlined),
          label: const Text('다시 시도'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _CommunityPostDetailScreenState._green,
            side: const BorderSide(
              color: _CommunityPostDetailScreenState._green,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyComments extends StatelessWidget {
  const _EmptyComments();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: _CommunityPostDetailScreenState._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        '아직 댓글이 없어요.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _CommunityPostDetailScreenState._grayText,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _CommunityPostDetailScreenState._lightGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _CommunityPostDetailScreenState._green,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _CommunityPostDetailScreenState._green, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _CommunityPostDetailScreenState._darkText,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

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
