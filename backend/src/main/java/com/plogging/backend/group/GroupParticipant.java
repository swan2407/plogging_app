package com.plogging.backend.group;

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
@Table(name = "group_participants")
public class GroupParticipant {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "group_event_id", nullable = false)
	private GroupEvent groupEvent;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false)
	private User user;

	@Column(nullable = false, length = 30)
	private String status;

	@Column(name = "joined_at", nullable = false)
	private LocalDateTime joinedAt;

	@Column(name = "canceled_at")
	private LocalDateTime canceledAt;

	@Column(name = "attended_at")
	private LocalDateTime attendedAt;

	protected GroupParticipant() {
	}

	public GroupParticipant(GroupEvent groupEvent, User user) {
		this.groupEvent = groupEvent;
		this.user = user;
		this.status = "JOINED";
		this.joinedAt = LocalDateTime.now();
	}
}
