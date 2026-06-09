package com.plogging.backend.map;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.plogging.backend.map.dto.GroupEventMarkerResponse;
import com.plogging.backend.map.dto.TrashRecordMarkerResponse;

@RestController
@RequestMapping("/api/map")
public class MapController {

	private final MapService mapService;

	public MapController(MapService mapService) {
		this.mapService = mapService;
	}

	@GetMapping("/trash-records")
	public List<TrashRecordMarkerResponse> findTrashRecords() {
		return mapService.findTrashRecords();
	}

	@GetMapping("/group-events")
	public List<GroupEventMarkerResponse> findGroupEvents() {
		return mapService.findGroupEvents();
	}
}
