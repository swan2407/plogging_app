package com.plogging.backend.auth;

public record JwtAuthenticatedUser(Long userId, String loginId, String role) {
}
