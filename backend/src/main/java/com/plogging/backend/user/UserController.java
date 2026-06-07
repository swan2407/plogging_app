package com.plogging.backend.user;

import org.springframework.http.HttpHeaders;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.plogging.backend.auth.CurrentUserService;

@RestController
@RequestMapping("/api/users")
public class UserController {

	private final CurrentUserService currentUserService;

	public UserController(CurrentUserService currentUserService) {
		this.currentUserService = currentUserService;
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

	public record UserResponse(Long userId, String loginId, String nickname, String regionSido, String regionSigungu) {
	}
}
