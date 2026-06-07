package com.plogging.backend.terms;

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
@Table(name = "terms_agreements")
public class TermsAgreement {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false)
	private User user;

	@Column(name = "terms_type", nullable = false, length = 50)
	private String termsType;

	@Column(name = "terms_version", nullable = false, length = 30)
	private String termsVersion;

	@Column(nullable = false)
	private boolean agreed;

	@Column(name = "agreed_at", nullable = false, insertable = false, updatable = false)
	private LocalDateTime agreedAt;

	protected TermsAgreement() {
	}

	public TermsAgreement(User user, String termsType, String termsVersion, boolean agreed) {
		this.user = user;
		this.termsType = termsType;
		this.termsVersion = termsVersion;
		this.agreed = agreed;
	}
}
