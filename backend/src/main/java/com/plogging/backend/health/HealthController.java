package com.plogging.backend.health;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/health")
public class HealthController {

	private final JdbcTemplate jdbcTemplate;

	public HealthController(JdbcTemplate jdbcTemplate) {
		this.jdbcTemplate = jdbcTemplate;
	}

	@GetMapping
	public ServiceHealthResponse health() {
		return new ServiceHealthResponse("OK", "plogging-backend");
	}

	@GetMapping("/db")
	public DatabaseHealthResponse databaseHealth() {
		return jdbcTemplate.queryForObject(
			"SELECT current_database(), current_user",
			(resultSet, rowNumber) -> new DatabaseHealthResponse(
				"OK",
				resultSet.getString(1),
				resultSet.getString(2)
			)
		);
	}

	public record ServiceHealthResponse(String status, String service) {
	}

	public record DatabaseHealthResponse(String status, String database, String user) {
	}
}
