package com.plogging.backend.user;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import com.plogging.backend.user.dto.UserActivitySummaryResponse;

@Service
public class UserActivitySummaryService {

	private final JdbcTemplate jdbcTemplate;

	public UserActivitySummaryService(JdbcTemplate jdbcTemplate) {
		this.jdbcTemplate = jdbcTemplate;
	}

	public UserActivitySummaryResponse findByUser(User user) {
		List<UserActivitySummaryResponse> summaries = jdbcTemplate.query(
			"""
			SELECT
			    user_id,
			    nickname,
			    total_plogging_count,
			    total_distance_meter,
			    total_duration_seconds,
			    total_trash_certification_count
			FROM user_activity_summary
			WHERE user_id = ?
			""",
			(rs, rowNum) -> new UserActivitySummaryResponse(
				rs.getLong("user_id"),
				rs.getString("nickname"),
				rs.getLong("total_plogging_count"),
				rs.getLong("total_distance_meter"),
				rs.getLong("total_duration_seconds"),
				rs.getLong("total_trash_certification_count")
			),
			user.getId()
		);

		if (!summaries.isEmpty()) {
			return summaries.get(0);
		}

		return new UserActivitySummaryResponse(
			user.getId(),
			user.getNickname(),
			0,
			0,
			0,
			0
		);
	}
}
