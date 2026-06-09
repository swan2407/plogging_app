package com.plogging.backend.waste.dto;

import java.util.List;

public record WasteDisposalPageResponse(
	String source,
	int pageNo,
	int numOfRows,
	int totalCount,
	List<WasteDisposalItemResponse> items
) {
}
