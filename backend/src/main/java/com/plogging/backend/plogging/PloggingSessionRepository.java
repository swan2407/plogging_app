package com.plogging.backend.plogging;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface PloggingSessionRepository extends JpaRepository<PloggingSession, Long> {

	List<PloggingSession> findAllByUserIdOrderByStartAtDesc(Long userId);

	Optional<PloggingSession> findByIdAndUserId(Long id, Long userId);
}
