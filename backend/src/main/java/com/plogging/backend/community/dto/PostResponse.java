package com.plogging.backend.community.dto;

import java.time.LocalDateTime;

import com.plogging.backend.community.CommunityPost;

public record PostResponse(
	Long id,
	Long userId,
	String authorNickname,
	Long sessionId,
	String category,
	String title,
	String content,
	String imageUrl,
	String regionSido,
	String regionSigungu,
	int likeCount,
	int commentCount,
	LocalDateTime createdAt
) {

	public static PostResponse from(CommunityPost post) {
		return new PostResponse(
			post.getId(),
			post.getUser().getId(),
			post.getUser().getNickname(),
			post.getSession() == null ? null : post.getSession().getId(),
			post.getCategory(),
			post.getTitle(),
			post.getContent(),
			post.getImageUrl(),
			post.getRegionSido(),
			post.getRegionSigungu(),
			post.getLikeCount(),
			post.getCommentCount(),
			post.getCreatedAt()
		);
	}
}
