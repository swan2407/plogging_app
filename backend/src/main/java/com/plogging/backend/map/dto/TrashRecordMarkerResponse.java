package com.plogging.backend.map.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import com.plogging.backend.plogging.TrashRecord;

public record TrashRecordMarkerResponse(
	Long id,
	String imageUrl,
	BigDecimal lat,
	BigDecimal lng,
	String trashType,
	String memo,
	LocalDateTime createdAt
) {

	public static TrashRecordMarkerResponse from(TrashRecord record) {
		return new TrashRecordMarkerResponse(
			record.getId(),
			record.getImageUrl(),
			record.getLat(),
			record.getLng(),
			record.getTrashType(),
			record.getMemo(),
			record.getCreatedAt()
		);
	}
}
