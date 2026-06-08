package com.plogging.backend.community.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateCommentRequest(
	@NotBlank(message = "댓글 내용이 필요합니다.")
	@Size(max = 1000, message = "댓글 내용은 1000자 이하여야 합니다.")
	String content
) {
}
