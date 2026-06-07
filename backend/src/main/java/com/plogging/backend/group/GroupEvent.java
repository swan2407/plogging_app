package com.plogging.backend.group;

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
@Table(name = "group_events")
public class GroupEvent {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false, length = 100)
	private String title;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "leader_id", nullable = false)
	private User leader;

	@Column(name = "region_sido", nullable = false, length = 30)
	private String regionSido;

	@Column(name = "region_sigungu", nullable = false, length = 50)
	private String regionSigungu;

	@Column(name = "start_at", nullable = false)
	private LocalDateTime startAt;

	@Column(name = "end_at", nullable = false)
	private LocalDateTime endAt;

	@Column(name = "recruit_deadline_at", nullable = false)
	private LocalDateTime recruitDeadlineAt;

	@Column(name = "max_participants", nullable = false)
	private int maxParticipants;

	@Column(name = "current_participants", nullable = false)
	private int currentParticipants;

	@Column(name = "place_name", nullable = false, length = 150)
	private String placeName;

	@Column(length = 255)
	private String address;

	@Column(precision = 10, scale = 7)
	private BigDecimal lat;

	@Column(precision = 10, scale = 7)
	private BigDecimal lng;

	@Column(length = 255)
	private String supplies;

	@Column(nullable = false, columnDefinition = "TEXT")
	private String description;

	@Column(nullable = false, length = 30)
	private String status;

	@Column(name = "created_at", nullable = false)
	private LocalDateTime createdAt;

	@Column(name = "updated_at", nullable = false)
	private LocalDateTime updatedAt;

	@Column(name = "canceled_at")
	private LocalDateTime canceledAt;

	protected GroupEvent() {
	}

	public GroupEvent(
		String title,
		User leader,
		String regionSido,
		String regionSigungu,
		LocalDateTime startAt,
		LocalDateTime endAt,
		LocalDateTime recruitDeadlineAt,
		int maxParticipants,
		String placeName,
		String address,
		BigDecimal lat,
		BigDecimal lng,
		String supplies,
		String description
	) {
		this.title = title;
		this.leader = leader;
		this.regionSido = regionSido;
		this.regionSigungu = regionSigungu;
		this.startAt = startAt;
		this.endAt = endAt;
		this.recruitDeadlineAt = recruitDeadlineAt;
		this.maxParticipants = maxParticipants;
		this.currentParticipants = 0;
		this.placeName = placeName;
		this.address = address;
		this.lat = lat;
		this.lng = lng;
		this.supplies = supplies;
		this.description = description;
		this.status = "RECRUITING";
		this.createdAt = LocalDateTime.now();
		this.updatedAt = this.createdAt;
	}

	public void increaseParticipants() {
		currentParticipants++;
		updatedAt = LocalDateTime.now();
	}

	public Long getId() {
		return id;
	}

	public String getTitle() {
		return title;
	}

	public User getLeader() {
		return leader;
	}

	public String getRegionSido() {
		return regionSido;
	}

	public String getRegionSigungu() {
		return regionSigungu;
	}

	public LocalDateTime getStartAt() {
		return startAt;
	}

	public LocalDateTime getEndAt() {
		return endAt;
	}

	public LocalDateTime getRecruitDeadlineAt() {
		return recruitDeadlineAt;
	}

	public int getMaxParticipants() {
		return maxParticipants;
	}

	public int getCurrentParticipants() {
		return currentParticipants;
	}

	public String getPlaceName() {
		return placeName;
	}

	public String getAddress() {
		return address;
	}

	public BigDecimal getLat() {
		return lat;
	}

	public BigDecimal getLng() {
		return lng;
	}

	public String getSupplies() {
		return supplies;
	}

	public String getDescription() {
		return description;
	}

	public String getStatus() {
		return status;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}
}
