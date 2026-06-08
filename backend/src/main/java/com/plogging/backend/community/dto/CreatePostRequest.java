package com.plogging.backend.community.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreatePostRequest(
	@NotBlank(message = "게시글 카테고리가 필요합니다.")
	String category,

	@NotBlank(message = "게시글 제목이 필요합니다.")
	@Size(max = 150, message = "게시글 제목은 150자 이하여야 합니다.")
	String title,

	@NotBlank(message = "게시글 내용이 필요합니다.")
	String content,

	Long sessionId,

	@Size(max = 500, message = "이미지 URL은 500자 이하여야 합니다.")
	String imageUrl,

	@Size(max = 30, message = "시도는 30자 이하여야 합니다.")
	String regionSido,

	@Size(max = 50, message = "시군구는 50자 이하여야 합니다.")
	String regionSigungu
) {
}
