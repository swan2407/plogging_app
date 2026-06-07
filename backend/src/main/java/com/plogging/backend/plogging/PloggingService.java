package com.plogging.backend.plogging;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.plogging.backend.common.ApiException;
import com.plogging.backend.plogging.dto.PloggingSessionResponse;
import com.plogging.backend.plogging.dto.SavePloggingResultRequest;
import com.plogging.backend.plogging.dto.TrashRecordRequest;
import com.plogging.backend.user.User;

@Service
public class PloggingService {

	private final PloggingSessionRepository ploggingSessionRepository;
	private final TrashRecordRepository trashRecordRepository;

	public PloggingService(
		PloggingSessionRepository ploggingSessionRepository,
		TrashRecordRepository trashRecordRepository
	) {
		this.ploggingSessionRepository = ploggingSessionRepository;
		this.trashRecordRepository = trashRecordRepository;
	}

	@Transactional
	public PloggingSessionResponse saveCompleted(SavePloggingResultRequest request, User user) {
		validate(request);

		List<TrashRecordRequest> trashRequests = request.trashRecords() == null
			? List.of()
			: request.trashRecords();
		int trashCertificationCount = Math.max(request.trashCertificationCount(), trashRequests.size());

		PloggingSession session = ploggingSessionRepository.save(new PloggingSession(
			user,
			request.startAt(),
			request.endAt(),
			request.durationSeconds(),
			request.distanceMeter(),
			request.regionSido(),
			request.regionSigungu(),
			trashCertificationCount
		));

		List<TrashRecord> trashRecords = trashRequests.stream()
			.map(trash -> new TrashRecord(
				session,
				user,
				trash.imageUrl(),
				trash.lat(),
				trash.lng(),
				trash.trashType(),
				trash.count(),
				trash.weightGram(),
				trash.memo()
			))
			.toList();
		trashRecordRepository.saveAll(trashRecords);

		return PloggingSessionResponse.from(session);
	}

	@Transactional(readOnly = true)
	public List<PloggingSessionResponse> findMine(User user) {
		return ploggingSessionRepository.findAllByUserIdOrderByStartAtDesc(user.getId()).stream()
			.map(PloggingSessionResponse::from)
			.toList();
	}

	@Transactional(readOnly = true)
	public PloggingSessionResponse findMineById(Long sessionId, User user) {
		PloggingSession session = ploggingSessionRepository.findByIdAndUserId(sessionId, user.getId())
			.orElseThrow(() -> ApiException.notFound("플로깅 기록을 찾을 수 없습니다."));
		return PloggingSessionResponse.from(session);
	}

	private void validate(SavePloggingResultRequest request) {
		if (!request.endAt().isAfter(request.startAt())) {
			throw ApiException.badRequest("활동 종료 시간은 시작 시간보다 늦어야 합니다.");
		}

		if (request.trashRecords() != null) {
			request.trashRecords().forEach(this::validateTrashCoordinates);
		}
	}

	private void validateTrashCoordinates(TrashRecordRequest trash) {
		validateCoordinate(trash.lat(), new BigDecimal("-90"), new BigDecimal("90"), "위도");
		validateCoordinate(trash.lng(), new BigDecimal("-180"), new BigDecimal("180"), "경도");
	}

	private void validateCoordinate(BigDecimal value, BigDecimal minimum, BigDecimal maximum, String name) {
		if (value != null && (value.compareTo(minimum) < 0 || value.compareTo(maximum) > 0)) {
			throw ApiException.badRequest(name + " 값이 올바르지 않습니다.");
		}
	}
}
