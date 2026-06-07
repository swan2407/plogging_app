package com.plogging.backend.auth;

import org.springframework.stereotype.Service;

import com.plogging.backend.common.ApiException;
import com.plogging.backend.user.User;
import com.plogging.backend.user.UserRepository;

@Service
public class CurrentUserService {

	private static final String TOKEN_PREFIX = "Bearer dev-token-";

	private final UserRepository userRepository;

	public CurrentUserService(UserRepository userRepository) {
		this.userRepository = userRepository;
	}

	public User requireUser(String authorization) {
		if (authorization == null || !authorization.startsWith(TOKEN_PREFIX)) {
			throw ApiException.unauthorized("로그인이 필요합니다.");
		}

		Long userId;
		try {
			userId = Long.valueOf(authorization.substring(TOKEN_PREFIX.length()));
		} catch (NumberFormatException exception) {
			throw ApiException.unauthorized("로그인이 필요합니다.");
		}

		return userRepository.findById(userId)
			.orElseThrow(() -> ApiException.unauthorized("로그인이 필요합니다."));
	}
}
