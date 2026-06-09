package com.plogging.backend.waste;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.plogging.backend.common.ApiException;
import com.plogging.backend.waste.dto.WasteDisposalPageResponse;

@RestController
@RequestMapping("/api/waste-disposal")
public class WasteDisposalController {

	private final WasteDisposalService wasteDisposalService;

	public WasteDisposalController(WasteDisposalService wasteDisposalService) {
		this.wasteDisposalService = wasteDisposalService;
	}

	@GetMapping
	public WasteDisposalPageResponse findWasteDisposalInformation(
		@RequestParam(required = false) String sido,
		@RequestParam(required = false) String sigungu,
		@RequestParam(required = false) String keyword,
		@RequestParam(defaultValue = "1") int pageNo,
		@RequestParam(defaultValue = "20") int numOfRows
	) {
		if (pageNo < 1) {
			throw ApiException.badRequest("pageNo는 1 이상이어야 합니다.");
		}
		if (numOfRows < 1 || numOfRows > 100) {
			throw ApiException.badRequest("numOfRows는 1 이상 100 이하여야 합니다.");
		}
		return wasteDisposalService.findAll(sido, sigungu, keyword, pageNo, numOfRows);
	}
}
