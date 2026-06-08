package com.plogging.backend.community;

import java.time.LocalDateTime;

import com.plogging.backend.plogging.PloggingSession;
import com.plogging.backend.user.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "community_posts")
public class CommunityPost {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false)
	private User user;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "session_id")
	private PloggingSession session;

	@Column(nullable = false, length = 30)
	private String category;

	@Column(nullable = false, length = 150)
	private String title;

	@Column(nullable = false, columnDefinition = "TEXT")
	private String content;

	@Column(name = "image_url", length = 500)
	private String imageUrl;

	@Column(name = "region_sido", length = 30)
	private String regionSido;

	@Column(name = "region_sigungu", length = 50)
	private String regionSigungu;

	@Column(name = "like_count", nullable = false)
	private int likeCount;

	@Column(name = "comment_count", nullable = false)
	private int commentCount;

	@Column(name = "created_at", nullable = false)
	private LocalDateTime createdAt;

	@Column(name = "updated_at", nullable = false)
	private LocalDateTime updatedAt;

	@Column(name = "deleted_at")
	private LocalDateTime deletedAt;

	protected CommunityPost() {
	}

	public CommunityPost(
		User user,
		PloggingSession session,
		String category,
		String title,
		String content,
		String imageUrl,
		String regionSido,
		String regionSigungu
	) {
		this.user = user;
		this.session = session;
		this.category = category;
		this.title = title;
		this.content = content;
		this.imageUrl = imageUrl;
		this.regionSido = regionSido;
		this.regionSigungu = regionSigungu;
		this.likeCount = 0;
		this.commentCount = 0;
		this.createdAt = LocalDateTime.now();
		this.updatedAt = this.createdAt;
	}

	public void update(
		String category,
		String title,
		String content,
		String imageUrl,
		String regionSido,
		String regionSigungu
	) {
		if (category != null) {
			this.category = category;
		}
		if (title != null) {
			this.title = title;
		}
		if (content != null) {
			this.content = content;
		}
		if (imageUrl != null) {
			this.imageUrl = imageUrl;
		}
		if (regionSido != null) {
			this.regionSido = regionSido;
		}
		if (regionSigungu != null) {
			this.regionSigungu = regionSigungu;
		}
		this.updatedAt = LocalDateTime.now();
	}

	public void softDelete() {
		this.deletedAt = LocalDateTime.now();
		this.updatedAt = this.deletedAt;
	}

	public void increaseLikeCount() {
		likeCount++;
		updatedAt = LocalDateTime.now();
	}

	public void decreaseLikeCount() {
		likeCount = Math.max(0, likeCount - 1);
		updatedAt = LocalDateTime.now();
	}

	public void increaseCommentCount() {
		commentCount++;
		updatedAt = LocalDateTime.now();
	}

	public Long getId() {
		return id;
	}

	public User getUser() {
		return user;
	}

	public PloggingSession getSession() {
		return session;
	}

	public String getCategory() {
		return category;
	}

	public String getTitle() {
		return title;
	}

	public String getContent() {
		return content;
	}

	public String getImageUrl() {
		return imageUrl;
	}

	public String getRegionSido() {
		return regionSido;
	}

	public String getRegionSigungu() {
		return regionSigungu;
	}

	public int getLikeCount() {
		return likeCount;
	}

	public int getCommentCount() {
		return commentCount;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}
}
