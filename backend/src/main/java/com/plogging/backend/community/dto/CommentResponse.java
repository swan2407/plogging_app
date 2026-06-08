package com.plogging.backend.community.dto;

import java.time.LocalDateTime;

import com.plogging.backend.community.Comment;

public record CommentResponse(
	Long id,
	Long postId,
	Long userId,
	String authorNickname,
	String content,
	LocalDateTime createdAt
) {

	public static CommentResponse from(Comment comment) {
		return new CommentResponse(
			comment.getId(),
			comment.getPost().getId(),
			comment.getUser().getId(),
			comment.getUser().getNickname(),
			comment.getContent(),
			comment.getCreatedAt()
		);
	}
}
