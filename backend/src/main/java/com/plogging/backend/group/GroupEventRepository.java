package com.plogging.backend.group;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import jakarta.persistence.LockModeType;

public interface GroupEventRepository extends JpaRepository<GroupEvent, Long> {

	List<GroupEvent> findAllByOrderByStartAtAsc();

	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("select event from GroupEvent event where event.id = :eventId")
	Optional<GroupEvent> findByIdForUpdate(@Param("eventId") Long eventId);
}
