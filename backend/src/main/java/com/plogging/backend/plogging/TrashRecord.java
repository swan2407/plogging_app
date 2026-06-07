package com.plogging.backend.plogging;

import java.math.BigDecimal;
import java.time.LocalDateTime;

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
@Table(name = "trash_records")
public class TrashRecord {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "session_id", nullable = false)
	private PloggingSession session;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false)
	private User user;

	@Column(name = "image_url", nullable = false, length = 500)
	private String imageUrl;

	@Column(nullable = false, precision = 10, scale = 7)
	private BigDecimal lat;

	@Column(nullable = false, precision = 10, scale = 7)
	private BigDecimal lng;

	@Column(name = "trash_type", length = 50)
	private String trashType;

	private Integer count;

	@Column(name = "weight_gram")
	private Integer weightGram;

	@Column(length = 500)
	private String memo;

	@Column(name = "created_at", nullable = false)
	private LocalDateTime createdAt;

	protected TrashRecord() {
	}

	public TrashRecord(
		PloggingSession session,
		User user,
		String imageUrl,
		BigDecimal lat,
		BigDecimal lng,
		String trashType,
		Integer count,
		Integer weightGram,
		String memo
	) {
		this.session = session;
		this.user = user;
		this.imageUrl = imageUrl;
		this.lat = lat;
		this.lng = lng;
		this.trashType = trashType;
		this.count = count;
		this.weightGram = weightGram;
		this.memo = memo;
		this.createdAt = LocalDateTime.now();
	}
}
