package com.plogging.backend.community;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface PostLikeRepository extends JpaRepository<PostLike, Long> {

	boolean existsByPostIdAndUserId(Long postId, Long userId);

	Optional<PostLike> findByPostIdAndUserId(Long postId, Long userId);
}
