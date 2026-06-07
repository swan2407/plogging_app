package com.plogging.backend.plogging.dto;

import java.time.LocalDateTime;

import com.plogging.backend.plogging.PloggingSession;

public record PloggingSessionResponse(
	Long id,
	Long userId,
	String type,
	String status,
	LocalDateTime startAt,
	LocalDateTime endAt,
	Integer durationSeconds,
	Integer distanceMeter,
	String regionSido,
	String regionSigungu,
	int trashCertificationCount,
	LocalDateTime createdAt
) {

	public static PloggingSessionResponse from(PloggingSession session) {
		return new PloggingSessionResponse(
			session.getId(),
			session.getUser().getId(),
			session.getType(),
			session.getStatus(),
			session.getStartAt(),
			session.getEndAt(),
			session.getDurationSeconds(),
			session.getDistanceMeter(),
			session.getRegionSido(),
			session.getRegionSigungu(),
			session.getTrashCertificationCount(),
			session.getCreatedAt()
		);
	}
}
