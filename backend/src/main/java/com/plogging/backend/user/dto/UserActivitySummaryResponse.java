package com.plogging.backend.user.dto;

public record UserActivitySummaryResponse(
	Long userId,
	String nickname,
	long totalPloggingCount,
	long totalDistanceMeter,
	long totalDurationSeconds,
	long totalTrashCertificationCount
) {
}
