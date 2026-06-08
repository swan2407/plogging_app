package com.plogging.backend.community;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import jakarta.persistence.LockModeType;

public interface CommunityPostRepository extends JpaRepository<CommunityPost, Long> {

	List<CommunityPost> findAllByDeletedAtIsNullOrderByCreatedAtDesc();

	List<CommunityPost> findAllByCategoryAndDeletedAtIsNullOrderByCreatedAtDesc(String category);

	Optional<CommunityPost> findByIdAndDeletedAtIsNull(Long id);

	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("select post from CommunityPost post where post.id = :postId and post.deletedAt is null")
	Optional<CommunityPost> findByIdAndDeletedAtIsNullForUpdate(@Param("postId") Long postId);
}
