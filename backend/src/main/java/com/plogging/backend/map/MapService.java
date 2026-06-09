package com.plogging.backend.map;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.plogging.backend.group.GroupEventRepository;
import com.plogging.backend.map.dto.GroupEventMarkerResponse;
import com.plogging.backend.map.dto.TrashRecordMarkerResponse;
import com.plogging.backend.plogging.TrashRecordRepository;

@Service
public class MapService {

	private final TrashRecordRepository trashRecordRepository;
	private final GroupEventRepository groupEventRepository;

	public MapService(
		TrashRecordRepository trashRecordRepository,
		GroupEventRepository groupEventRepository
	) {
		this.trashRecordRepository = trashRecordRepository;
		this.groupEventRepository = groupEventRepository;
	}

	@Transactional(readOnly = true)
	public List<TrashRecordMarkerResponse> findTrashRecords() {
		return trashRecordRepository.findAll().stream()
			.map(TrashRecordMarkerResponse::from)
			.toList();
	}

	@Transactional(readOnly = true)
	public List<GroupEventMarkerResponse> findGroupEvents() {
		return groupEventRepository.findAllByOrderByStartAtAsc().stream()
			.filter(event -> event.getLat() != null && event.getLng() != null)
			.map(GroupEventMarkerResponse::from)
			.toList();
	}
}
