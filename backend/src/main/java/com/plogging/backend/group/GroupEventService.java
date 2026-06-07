package com.plogging.backend.group;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.plogging.backend.common.ApiException;
import com.plogging.backend.group.dto.CreateGroupEventRequest;
import com.plogging.backend.group.dto.GroupEventResponse;
import com.plogging.backend.user.User;

@Service
public class GroupEventService {

	private static final String RECRUITING = "RECRUITING";

	private final GroupEventRepository groupEventRepository;
	private final GroupParticipantRepository groupParticipantRepository;

	public GroupEventService(
		GroupEventRepository groupEventRepository,
		GroupParticipantRepository groupParticipantRepository
	) {
		this.groupEventRepository = groupEventRepository;
		this.groupParticipantRepository = groupParticipantRepository;
	}

	@Transactional(readOnly = true)
	public List<GroupEventResponse> findAll() {
		return groupEventRepository.findAllByOrderByStartAtAsc().stream()
			.map(GroupEventResponse::from)
			.toList();
	}

	@Transactional(readOnly = true)
	public GroupEventResponse findById(Long eventId) {
		return GroupEventResponse.from(getEvent(eventId));
	}

	@Transactional
	public GroupEventResponse create(CreateGroupEventRequest request, User leader) {
		validateCreateRequest(request);
		LocalDateTime recruitDeadlineAt = request.recruitDeadlineAt() == null
			? request.startAt()
			: request.recruitDeadlineAt();

		GroupEvent event = groupEventRepository.save(new GroupEvent(
			request.title(),
			leader,
			request.regionSido(),
			request.regionSigungu(),
			request.startAt(),
			request.endAt(),
			recruitDeadlineAt,
			request.maxParticipants(),
			request.placeName(),
			request.address(),
			request.lat(),
			request.lng(),
			request.supplies(),
			request.description()
		));

		return GroupEventResponse.from(event);
	}

	@Transactional
	public GroupEventResponse join(Long eventId, User user) {
		GroupEvent event = groupEventRepository.findByIdForUpdate(eventId)
			.orElseThrow(() -> ApiException.notFound("단체 플로깅을 찾을 수 없습니다."));

		if (!RECRUITING.equals(event.getStatus())) {
			throw ApiException.badRequest("현재 모집 중인 단체 플로깅이 아닙니다.");
		}
		if (LocalDateTime.now().isAfter(event.getRecruitDeadlineAt())) {
			throw ApiException.badRequest("모집이 마감된 단체 플로깅입니다.");
		}
		if (groupParticipantRepository.existsByGroupEventIdAndUserId(eventId, user.getId())) {
			throw ApiException.conflict("이미 참여한 단체 플로깅입니다.");
		}
		if (event.getCurrentParticipants() >= event.getMaxParticipants()) {
			throw ApiException.conflict("모집 인원이 마감되었습니다.");
		}

		groupParticipantRepository.save(new GroupParticipant(event, user));
		event.increaseParticipants();

		return GroupEventResponse.from(event);
	}

	private GroupEvent getEvent(Long eventId) {
		return groupEventRepository.findById(eventId)
			.orElseThrow(() -> ApiException.notFound("단체 플로깅을 찾을 수 없습니다."));
	}

	private void validateCreateRequest(CreateGroupEventRequest request) {
		if (!request.endAt().isAfter(request.startAt())) {
			throw ApiException.badRequest("활동 종료 시간은 시작 시간보다 늦어야 합니다.");
		}

		LocalDateTime recruitDeadlineAt = request.recruitDeadlineAt();
		if (recruitDeadlineAt != null && recruitDeadlineAt.isAfter(request.startAt())) {
			throw ApiException.badRequest("모집 마감 시간은 활동 시작 시간 이후로 설정할 수 없습니다.");
		}

		if (request.maxParticipants() < 2 || request.maxParticipants() > 100) {
			throw ApiException.badRequest("모집 인원은 2명 이상 100명 이하로 설정해야 합니다.");
		}

		validateCoordinate(request.lat(), new BigDecimal("-90"), new BigDecimal("90"), "위도");
		validateCoordinate(request.lng(), new BigDecimal("-180"), new BigDecimal("180"), "경도");
	}

	private void validateCoordinate(BigDecimal value, BigDecimal minimum, BigDecimal maximum, String name) {
		if (value != null && (value.compareTo(minimum) < 0 || value.compareTo(maximum) > 0)) {
			throw ApiException.badRequest(name + " 값이 올바르지 않습니다.");
		}
	}
}
