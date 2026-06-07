package com.plogging.backend.plogging.dto;

import java.time.LocalDateTime;
import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

public record SavePloggingResultRequest(
	@NotNull(message = "활동 시작 시간이 필요합니다.")
	LocalDateTime startAt,

	@NotNull(message = "활동 종료 시간이 필요합니다.")
	LocalDateTime endAt,

	@Positive(message = "활동 시간은 0보다 커야 합니다.")
	int durationSeconds,

	@PositiveOrZero(message = "이동 거리는 0 이상이어야 합니다.")
	int distanceMeter,

	@Size(max = 30, message = "시도는 30자 이하여야 합니다.")
	String regionSido,

	@Size(max = 50, message = "시군구는 50자 이하여야 합니다.")
	String regionSigungu,

	@PositiveOrZero(message = "쓰레기 인증 횟수는 0 이상이어야 합니다.")
	int trashCertificationCount,

	List<@Valid TrashRecordRequest> trashRecords
) {
}
