package com.plogging.backend.group;

import org.springframework.data.jpa.repository.JpaRepository;

public interface GroupParticipantRepository extends JpaRepository<GroupParticipant, Long> {

	boolean existsByGroupEventIdAndUserId(Long groupEventId, Long userId);

	long countByGroupEventIdAndStatus(Long groupEventId, String status);
}
