package com.plogging.backend.auth;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.plogging.backend.common.ApiException;
import com.plogging.backend.user.User;
import com.plogging.backend.user.UserRepository;

@Service
public class CurrentUserService {

	private final UserRepository userRepository;

	public CurrentUserService(UserRepository userRepository) {
		this.userRepository = userRepository;
	}

	public User requireUser() {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		if (authentication == null || !authentication.isAuthenticated()
			|| !(authentication.getPrincipal() instanceof JwtAuthenticatedUser authenticatedUser)) {
			throw ApiException.unauthorized("로그인이 필요합니다.");
		}

		return userRepository.findById(authenticatedUser.userId())
			.orElseThrow(() -> ApiException.unauthorized("로그인이 필요합니다."));
	}
}
