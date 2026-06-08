package com.plogging.backend.auth.dto;

public record TokenRefreshResponse(String accessToken, String refreshToken) {
}
