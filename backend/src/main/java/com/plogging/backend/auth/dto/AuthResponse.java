package com.plogging.backend.auth.dto;

public record AuthResponse(String accessToken, String refreshToken, Long userId, String nickname) {
}
