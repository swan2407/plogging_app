package com.plogging.backend.auth.dto;

public record AuthResponse(String accessToken, Long userId, String nickname) {
}
