package com.plogging.backend.community;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.plogging.backend.auth.CurrentUserService;
import com.plogging.backend.community.dto.CommentResponse;
import com.plogging.backend.community.dto.CreateCommentRequest;
import com.plogging.backend.community.dto.CreatePostRequest;
import com.plogging.backend.community.dto.PostResponse;
import com.plogging.backend.community.dto.UpdatePostRequest;
import com.plogging.backend.user.User;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api")
public class CommunityController {

	private final CommunityService communityService;
	private final CurrentUserService currentUserService;

	public CommunityController(CommunityService communityService, CurrentUserService currentUserService) {
		this.communityService = communityService;
		this.currentUserService = currentUserService;
	}

	@GetMapping("/posts")
	public List<PostResponse> findPosts(@RequestParam(required = false) String category) {
		return communityService.findAll(category);
	}

	@GetMapping("/posts/{postId}")
	public PostResponse findPost(@PathVariable Long postId) {
		return communityService.findById(postId);
	}

	@PostMapping("/posts")
	@ResponseStatus(HttpStatus.CREATED)
	public PostResponse createPost(
		@Valid @RequestBody CreatePostRequest request
	) {
		User user = currentUserService.requireUser();
		return communityService.create(request, user);
	}

	@PatchMapping("/posts/{postId}")
	public PostResponse updatePost(
		@PathVariable Long postId,
		@Valid @RequestBody UpdatePostRequest request
	) {
		User user = currentUserService.requireUser();
		return communityService.update(postId, request, user);
	}

	@DeleteMapping("/posts/{postId}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void deletePost(
		@PathVariable Long postId
	) {
		User user = currentUserService.requireUser();
		communityService.delete(postId, user);
	}

	@PostMapping("/posts/{postId}/likes")
	public PostResponse likePost(
		@PathVariable Long postId
	) {
		User user = currentUserService.requireUser();
		return communityService.like(postId, user);
	}

	@DeleteMapping("/posts/{postId}/likes")
	public PostResponse unlikePost(
		@PathVariable Long postId
	) {
		User user = currentUserService.requireUser();
		return communityService.unlike(postId, user);
	}

	@GetMapping("/posts/{postId}/comments")
	public List<CommentResponse> findComments(@PathVariable Long postId) {
		return communityService.findComments(postId);
	}

	@PostMapping("/posts/{postId}/comments")
	@ResponseStatus(HttpStatus.CREATED)
	public CommentResponse createComment(
		@PathVariable Long postId,
		@Valid @RequestBody CreateCommentRequest request
	) {
		User user = currentUserService.requireUser();
		return communityService.createComment(postId, request, user);
	}
}
