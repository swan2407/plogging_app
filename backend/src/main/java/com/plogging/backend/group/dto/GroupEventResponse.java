package com.plogging.backend.group.dto;

import java.time.LocalDateTime;

import com.plogging.backend.group.GroupEvent;

public record GroupEventResponse(
	Long id,
	String title,
	Long leaderId,
	String leaderNickname,
	String regionSido,
	String regionSigungu,
	LocalDateTime startAt,
	LocalDateTime endAt,
	LocalDateTime recruitDeadlineAt,
	int maxParticipants,
	int currentParticipants,
	String placeName,
	String address,
	String supplies,
	String description,
	String status,
	LocalDateTime createdAt
) {

	public static GroupEventResponse from(GroupEvent event) {
		return new GroupEventResponse(
			event.getId(),
			event.getTitle(),
			event.getLeader().getId(),
			event.getLeader().getNickname(),
			event.getRegionSido(),
			event.getRegionSigungu(),
			event.getStartAt(),
			event.getEndAt(),
			event.getRecruitDeadlineAt(),
			event.getMaxParticipants(),
			event.getCurrentParticipants(),
			event.getPlaceName(),
			event.getAddress(),
			event.getSupplies(),
			event.getDescription(),
			event.getStatus(),
			event.getCreatedAt()
		);
	}
}
