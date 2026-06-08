package com.plogging.backend.auth;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.plogging.backend.common.ApiException;
import com.plogging.backend.user.User;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

@Component
public class JwtTokenProvider {

	private static final String TOKEN_TYPE_CLAIM = "tokenType";
	private static final String ACCESS_TOKEN_TYPE = "access";
	private static final String REFRESH_TOKEN_TYPE = "refresh";

	private final SecretKey secretKey;
	private final long accessTokenValiditySeconds;
	private final long refreshTokenValiditySeconds;

	public JwtTokenProvider(
		@Value("${jwt.secret}") String secret,
		@Value("${jwt.access-token-validity-seconds}") long accessTokenValiditySeconds,
		@Value("${jwt.refresh-token-validity-seconds}") long refreshTokenValiditySeconds
	) {
		if (secret.getBytes(StandardCharsets.UTF_8).length < 32) {
			throw new IllegalArgumentException("jwt.secret must be at least 32 bytes for HS256.");
		}
		this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
		this.accessTokenValiditySeconds = accessTokenValiditySeconds;
		this.refreshTokenValiditySeconds = refreshTokenValiditySeconds;
	}

	public String createAccessToken(User user) {
		return createToken(user, ACCESS_TOKEN_TYPE, accessTokenValiditySeconds);
	}

	public String createRefreshToken(User user) {
		return createToken(user, REFRESH_TOKEN_TYPE, refreshTokenValiditySeconds);
	}

	public JwtAuthenticatedUser validateAccessToken(String token) {
		Claims claims = parseClaims(token);
		if (!ACCESS_TOKEN_TYPE.equals(claims.get(TOKEN_TYPE_CLAIM, String.class))) {
			throw ApiException.unauthorized("로그인이 필요합니다.");
		}
		return toAuthenticatedUser(claims);
	}

	public Long validateRefreshTokenAndGetUserId(String token) {
		Claims claims = parseClaims(token);
		if (!REFRESH_TOKEN_TYPE.equals(claims.get(TOKEN_TYPE_CLAIM, String.class))) {
			throw ApiException.unauthorized("로그인이 필요합니다.");
		}
		return Long.valueOf(claims.getSubject());
	}

	private String createToken(User user, String tokenType, long validitySeconds) {
		Instant now = Instant.now();
		Instant expiresAt = now.plusSeconds(validitySeconds);

		return Jwts.builder()
			.subject(String.valueOf(user.getId()))
			.claim("userId", user.getId())
			.claim("loginId", user.getLoginId())
			.claim("role", user.getRole())
			.claim(TOKEN_TYPE_CLAIM, tokenType)
			.issuedAt(Date.from(now))
			.expiration(Date.from(expiresAt))
			.signWith(secretKey)
			.compact();
	}

	private Claims parseClaims(String token) {
		try {
			return Jwts.parser()
				.verifyWith(secretKey)
				.build()
				.parseSignedClaims(token)
				.getPayload();
		} catch (JwtException | IllegalArgumentException exception) {
			throw ApiException.unauthorized("로그인이 필요합니다.");
		}
	}

	private JwtAuthenticatedUser toAuthenticatedUser(Claims claims) {
		return new JwtAuthenticatedUser(
			Long.valueOf(claims.getSubject()),
			claims.get("loginId", String.class),
			claims.get("role", String.class)
		);
	}
}
