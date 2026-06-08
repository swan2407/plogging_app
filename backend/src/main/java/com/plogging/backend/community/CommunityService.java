package com.plogging.backend.community;

import java.util.List;
import java.util.Set;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.plogging.backend.common.ApiException;
import com.plogging.backend.community.dto.CommentResponse;
import com.plogging.backend.community.dto.CreateCommentRequest;
import com.plogging.backend.community.dto.CreatePostRequest;
import com.plogging.backend.community.dto.PostResponse;
import com.plogging.backend.community.dto.UpdatePostRequest;
import com.plogging.backend.plogging.PloggingSession;
import com.plogging.backend.plogging.PloggingSessionRepository;
import com.plogging.backend.user.User;

@Service
public class CommunityService {

	private static final Set<String> CATEGORIES = Set.of(
		"ACTIVITY_REVIEW",
		"GROUP_PROMOTION",
		"INFO_SHARE",
		"QUESTION"
	);

	private final CommunityPostRepository communityPostRepository;
	private final CommentRepository commentRepository;
	private final PostLikeRepository postLikeRepository;
	private final PloggingSessionRepository ploggingSessionRepository;

	public CommunityService(
		CommunityPostRepository communityPostRepository,
		CommentRepository commentRepository,
		PostLikeRepository postLikeRepository,
		PloggingSessionRepository ploggingSessionRepository
	) {
		this.communityPostRepository = communityPostRepository;
		this.commentRepository = commentRepository;
		this.postLikeRepository = postLikeRepository;
		this.ploggingSessionRepository = ploggingSessionRepository;
	}

	@Transactional(readOnly = true)
	public List<PostResponse> findAll(String category) {
		List<CommunityPost> posts;
		if (category == null || category.isBlank()) {
			posts = communityPostRepository.findAllByDeletedAtIsNullOrderByCreatedAtDesc();
		} else {
			validateCategory(category);
			posts = communityPostRepository.findAllByCategoryAndDeletedAtIsNullOrderByCreatedAtDesc(category);
		}

		return posts.stream()
			.map(PostResponse::from)
			.toList();
	}

	@Transactional(readOnly = true)
	public PostResponse findById(Long postId) {
		return PostResponse.from(getPost(postId));
	}

	@Transactional
	public PostResponse create(CreatePostRequest request, User user) {
		validateCategory(request.category());
		PloggingSession session = findOwnedSession(request.sessionId(), user);

		CommunityPost post = communityPostRepository.save(new CommunityPost(
			user,
			session,
			request.category(),
			request.title(),
			request.content(),
			request.imageUrl(),
			request.regionSido(),
			request.regionSigungu()
		));

		return PostResponse.from(post);
	}

	@Transactional
	public PostResponse update(Long postId, UpdatePostRequest request, User user) {
		CommunityPost post = getPost(postId);
		requireAuthor(post, user);
		validateUpdateRequest(request);

		post.update(
			request.category(),
			request.title(),
			request.content(),
			request.imageUrl(),
			request.regionSido(),
			request.regionSigungu()
		);

		return PostResponse.from(post);
	}

	@Transactional
	public void delete(Long postId, User user) {
		CommunityPost post = getPost(postId);
		requireAuthor(post, user);
		post.softDelete();
	}

	@Transactional
	public PostResponse like(Long postId, User user) {
		CommunityPost post = getPostForUpdate(postId);
		if (postLikeRepository.existsByPostIdAndUserId(postId, user.getId())) {
			throw ApiException.conflict("이미 좋아요를 누른 게시글입니다.");
		}

		postLikeRepository.save(new PostLike(post, user));
		post.increaseLikeCount();
		return PostResponse.from(post);
	}

	@Transactional
	public PostResponse unlike(Long postId, User user) {
		CommunityPost post = getPostForUpdate(postId);
		postLikeRepository.findByPostIdAndUserId(postId, user.getId())
			.ifPresent(like -> {
				postLikeRepository.delete(like);
				post.decreaseLikeCount();
			});

		return PostResponse.from(post);
	}

	@Transactional(readOnly = true)
	public List<CommentResponse> findComments(Long postId) {
		getPost(postId);
		return commentRepository.findAllByPostIdAndDeletedAtIsNullOrderByCreatedAtAsc(postId).stream()
			.map(CommentResponse::from)
			.toList();
	}

	@Transactional
	public CommentResponse createComment(Long postId, CreateCommentRequest request, User user) {
		CommunityPost post = getPostForUpdate(postId);
		Comment comment = commentRepository.save(new Comment(post, user, request.content()));
		post.increaseCommentCount();
		return CommentResponse.from(comment);
	}

	private CommunityPost getPost(Long postId) {
		return communityPostRepository.findByIdAndDeletedAtIsNull(postId)
			.orElseThrow(() -> ApiException.notFound("존재하지 않는 게시글입니다."));
	}

	private CommunityPost getPostForUpdate(Long postId) {
		return communityPostRepository.findByIdAndDeletedAtIsNullForUpdate(postId)
			.orElseThrow(() -> ApiException.notFound("존재하지 않는 게시글입니다."));
	}

	private PloggingSession findOwnedSession(Long sessionId, User user) {
		if (sessionId == null) {
			return null;
		}

		return ploggingSessionRepository.findByIdAndUserId(sessionId, user.getId())
			.orElseThrow(() -> ApiException.badRequest("연결할 수 없는 플로깅 기록입니다."));
	}

	private void requireAuthor(CommunityPost post, User user) {
		if (!post.getUser().getId().equals(user.getId())) {
			throw ApiException.forbidden("게시글 수정 권한이 없습니다.");
		}
	}

	private void validateUpdateRequest(UpdatePostRequest request) {
		if (request.category() != null) {
			validateCategory(request.category());
		}
		if (request.title() != null && request.title().isBlank()) {
			throw ApiException.badRequest("게시글 제목이 필요합니다.");
		}
		if (request.content() != null && request.content().isBlank()) {
			throw ApiException.badRequest("게시글 내용이 필요합니다.");
		}
	}

	private void validateCategory(String category) {
		if (category == null || category.isBlank()) {
			throw ApiException.badRequest("게시글 카테고리가 필요합니다.");
		}
		if (!CATEGORIES.contains(category)) {
			throw ApiException.badRequest("지원하지 않는 게시글 카테고리입니다.");
		}
	}
}
