package com.plogging.backend.plogging;

import org.springframework.data.jpa.repository.JpaRepository;

public interface TrashRecordRepository extends JpaRepository<TrashRecord, Long> {
}
