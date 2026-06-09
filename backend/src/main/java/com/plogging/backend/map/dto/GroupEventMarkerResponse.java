package com.plogging.backend.map.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import com.plogging.backend.group.GroupEvent;

public record GroupEventMarkerResponse(
	Long id,
	String title,
	String placeName,
	String address,
	BigDecimal lat,
	BigDecimal lng,
	LocalDateTime startAt,
	String status,
	int currentParticipants,
	int maxParticipants
) {

	public static GroupEventMarkerResponse from(GroupEvent event) {
		return new GroupEventMarkerResponse(
			event.getId(),
			event.getTitle(),
			event.getPlaceName(),
			event.getAddress(),
			event.getLat(),
			event.getLng(),
			event.getStartAt(),
			event.getStatus(),
			event.getCurrentParticipants(),
			event.getMaxParticipants()
		);
	}
}
