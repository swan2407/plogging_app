package com.plogging.backend.user;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "users")
public class User {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(name = "login_id", nullable = false, unique = true, length = 50)
	private String loginId;

	@Column(name = "password_hash", nullable = false, length = 255)
	private String passwordHash;

	@Column(nullable = false, unique = true, length = 50)
	private String nickname;

	@Column(name = "region_sido", length = 30)
	private String regionSido;

	@Column(name = "region_sigungu", length = 50)
	private String regionSigungu;

	@Column(name = "profile_image_url", length = 500)
	private String profileImageUrl;

	@Column(nullable = false, length = 20)
	private String role = "USER";

	@Column(nullable = false, length = 20)
	private String provider = "LOCAL";

	@Column(name = "created_at", nullable = false, insertable = false, updatable = false)
	private LocalDateTime createdAt;

	@Column(name = "updated_at", nullable = false, insertable = false)
	private LocalDateTime updatedAt;

	@Column(name = "deleted_at")
	private LocalDateTime deletedAt;

	protected User() {
	}

	public User(String loginId, String passwordHash, String nickname, String regionSido, String regionSigungu) {
		this.loginId = loginId;
		this.passwordHash = passwordHash;
		this.nickname = nickname;
		this.regionSido = regionSido;
		this.regionSigungu = regionSigungu;
	}

	public Long getId() {
		return id;
	}

	public String getLoginId() {
		return loginId;
	}

	public String getPasswordHash() {
		return passwordHash;
	}

	public String getNickname() {
		return nickname;
	}

	public String getRegionSido() {
		return regionSido;
	}

	public String getRegionSigungu() {
		return regionSigungu;
	}
}
