package com.plogging.backend.plogging.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

public record TrashRecordRequest(
	@NotBlank(message = "쓰레기 인증 이미지 URL이 필요합니다.")
	@Size(max = 500, message = "쓰레기 인증 이미지 URL은 500자 이하여야 합니다.")
	String imageUrl,

	@NotNull(message = "쓰레기 인증 위도가 필요합니다.")
	BigDecimal lat,

	@NotNull(message = "쓰레기 인증 경도가 필요합니다.")
	BigDecimal lng,

	@Size(max = 50, message = "쓰레기 종류는 50자 이하여야 합니다.")
	String trashType,

	@PositiveOrZero(message = "쓰레기 개수는 0 이상이어야 합니다.")
	Integer count,

	@PositiveOrZero(message = "쓰레기 무게는 0 이상이어야 합니다.")
	Integer weightGram,

	@Size(max = 500, message = "메모는 500자 이하여야 합니다.")
	String memo
) {
}
