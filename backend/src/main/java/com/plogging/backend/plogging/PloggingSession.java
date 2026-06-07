package com.plogging.backend.plogging;

import java.time.LocalDateTime;

import com.plogging.backend.group.GroupEvent;
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
@Table(name = "plogging_sessions")
public class PloggingSession {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false)
	private User user;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "group_event_id")
	private GroupEvent groupEvent;

	@Column(nullable = false, length = 20)
	private String type;

	@Column(nullable = false, length = 30)
	private String status;

	@Column(name = "start_at", nullable = false)
	private LocalDateTime startAt;

	@Column(name = "end_at")
	private LocalDateTime endAt;

	@Column(name = "duration_seconds")
	private Integer durationSeconds;

	@Column(name = "distance_meter")
	private Integer distanceMeter;

	@Column(name = "region_sido", length = 30)
	private String regionSido;

	@Column(name = "region_sigungu", length = 50)
	private String regionSigungu;

	@Column(name = "trash_certification_count", nullable = false)
	private int trashCertificationCount;

	@Column(name = "created_at", nullable = false)
	private LocalDateTime createdAt;

	@Column(name = "updated_at", nullable = false)
	private LocalDateTime updatedAt;

	protected PloggingSession() {
	}

	public PloggingSession(
		User user,
		LocalDateTime startAt,
		LocalDateTime endAt,
		int durationSeconds,
		int distanceMeter,
		String regionSido,
		String regionSigungu,
		int trashCertificationCount
	) {
		this.user = user;
		this.type = "PERSONAL";
		this.status = "COMPLETED";
		this.startAt = startAt;
		this.endAt = endAt;
		this.durationSeconds = durationSeconds;
		this.distanceMeter = distanceMeter;
		this.regionSido = regionSido;
		this.regionSigungu = regionSigungu;
		this.trashCertificationCount = trashCertificationCount;
		this.createdAt = LocalDateTime.now();
		this.updatedAt = this.createdAt;
	}

	public Long getId() {
		return id;
	}

	public User getUser() {
		return user;
	}

	public String getType() {
		return type;
	}

	public String getStatus() {
		return status;
	}

	public LocalDateTime getStartAt() {
		return startAt;
	}

	public LocalDateTime getEndAt() {
		return endAt;
	}

	public Integer getDurationSeconds() {
		return durationSeconds;
	}

	public Integer getDistanceMeter() {
		return distanceMeter;
	}

	public String getRegionSido() {
		return regionSido;
	}

	public String getRegionSigungu() {
		return regionSigungu;
	}

	public int getTrashCertificationCount() {
		return trashCertificationCount;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}
}
