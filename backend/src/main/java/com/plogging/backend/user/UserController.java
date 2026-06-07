package com.plogging.backend.user;

import org.springframework.http.HttpHeaders;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.plogging.backend.common.ApiException;

@RestController
@RequestMapping("/api/users")
public class UserController {

	private static final String TOKEN_PREFIX = "Bearer dev-token-";

	private final UserRepository userRepository;

	public UserController(UserRepository userRepository) {
		this.userRepository = userRepository;
	}

	@GetMapping("/me")
	public UserResponse me(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization) {
		Long userId = parseUserId(authorization);
		User user = userRepository.findById(userId)
			.orElseThrow(() -> ApiException.unauthorized("유효하지 않은 개발용 access token입니다."));

		return new UserResponse(
			user.getId(),
			user.getLoginId(),
			user.getNickname(),
			user.getRegionSido(),
			user.getRegionSigungu()
		);
	}

	private Long parseUserId(String authorization) {
		if (!authorization.startsWith(TOKEN_PREFIX)) {
			throw ApiException.unauthorized("유효하지 않은 개발용 access token입니다.");
		}

		try {
			return Long.valueOf(authorization.substring(TOKEN_PREFIX.length()));
		} catch (NumberFormatException exception) {
			throw ApiException.unauthorized("유효하지 않은 개발용 access token입니다.");
		}
	}

	public record UserResponse(Long userId, String loginId, String nickname, String regionSido, String regionSigungu) {
	}
}
