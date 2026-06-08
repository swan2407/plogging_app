package com.plogging.backend.user;

import org.springframework.http.HttpHeaders;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.plogging.backend.auth.CurrentUserService;
import com.plogging.backend.user.dto.UserActivitySummaryResponse;

@RestController
@RequestMapping("/api/users")
public class UserController {

	private final CurrentUserService currentUserService;
	private final UserActivitySummaryService userActivitySummaryService;

	public UserController(
		CurrentUserService currentUserService,
		UserActivitySummaryService userActivitySummaryService
	) {
		this.currentUserService = currentUserService;
		this.userActivitySummaryService = userActivitySummaryService;
	}

	@GetMapping("/me")
	public UserResponse me(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization) {
		User user = currentUserService.requireUser(authorization);

		return new UserResponse(
			user.getId(),
			user.getLoginId(),
			user.getNickname(),
			user.getRegionSido(),
			user.getRegionSigungu()
		);
	}

	@GetMapping("/me/statistics")
	public UserActivitySummaryResponse statistics(
		@RequestHeader(value = HttpHeaders.AUTHORIZATION, required = false) String authorization
	) {
		User user = currentUserService.requireUser(authorization);
		return userActivitySummaryService.findByUser(user);
	}

	public record UserResponse(Long userId, String loginId, String nickname, String regionSido, String regionSigungu) {
	}
}
