package com.plogging.backend.group.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateGroupEventRequest(
	@NotBlank(message = "단체 플로깅 제목은 필수입니다.")
	@Size(max = 100, message = "단체 플로깅 제목은 100자 이하여야 합니다.")
	String title,

	@NotBlank(message = "시도는 필수입니다.")
	@Size(max = 30, message = "시도는 30자 이하여야 합니다.")
	String regionSido,

	@NotBlank(message = "시군구는 필수입니다.")
	@Size(max = 50, message = "시군구는 50자 이하여야 합니다.")
	String regionSigungu,

	@NotNull(message = "활동 시작 시간은 필수입니다.")
	LocalDateTime startAt,

	@NotNull(message = "활동 종료 시간은 필수입니다.")
	LocalDateTime endAt,

	LocalDateTime recruitDeadlineAt,

	@Min(value = 2, message = "모집 인원은 2명 이상 100명 이하로 설정해야 합니다.")
	@Max(value = 100, message = "모집 인원은 2명 이상 100명 이하로 설정해야 합니다.")
	int maxParticipants,

	@NotBlank(message = "집결 장소는 필수입니다.")
	@Size(max = 150, message = "집결 장소는 150자 이하여야 합니다.")
	String placeName,

	@Size(max = 255, message = "주소는 255자 이하여야 합니다.")
	String address,

	BigDecimal lat,

	BigDecimal lng,

	@Size(max = 255, message = "준비물은 255자 이하여야 합니다.")
	String supplies,

	@NotBlank(message = "상세 설명은 필수입니다.")
	String description
) {
}
