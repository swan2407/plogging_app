package com.plogging.backend.auth;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.plogging.backend.auth.dto.AgreementRequest;
import com.plogging.backend.auth.dto.AuthResponse;
import com.plogging.backend.auth.dto.LoginRequest;
import com.plogging.backend.auth.dto.RefreshTokenRequest;
import com.plogging.backend.auth.dto.SignupRequest;
import com.plogging.backend.auth.dto.TokenRefreshResponse;
import com.plogging.backend.common.ApiException;
import com.plogging.backend.terms.TermsAgreement;
import com.plogging.backend.terms.TermsAgreementRepository;
import com.plogging.backend.user.User;
import com.plogging.backend.user.UserRepository;

@Service
public class AuthService {

	private static final Set<String> REQUIRED_AGREEMENTS = Set.of(
		"TERMS_OF_SERVICE",
		"PRIVACY_POLICY",
		"LOCATION_TERMS",
		"PHOTO_CERTIFICATION_POLICY"
	);

	private final UserRepository userRepository;
	private final TermsAgreementRepository termsAgreementRepository;
	private final PasswordEncoder passwordEncoder;
	private final JwtTokenProvider jwtTokenProvider;

	public AuthService(
		UserRepository userRepository,
		TermsAgreementRepository termsAgreementRepository,
		PasswordEncoder passwordEncoder,
		JwtTokenProvider jwtTokenProvider
	) {
		this.userRepository = userRepository;
		this.termsAgreementRepository = termsAgreementRepository;
		this.passwordEncoder = passwordEncoder;
		this.jwtTokenProvider = jwtTokenProvider;
	}

	@Transactional
	public AuthResponse signup(SignupRequest request) {
		validateDuplicates(request);
		validateRequiredAgreements(request.agreements());

		User user = userRepository.save(new User(
			request.loginId(),
			passwordEncoder.encode(request.password()),
			request.nickname(),
			request.regionSido(),
			request.regionSigungu()
		));

		List<TermsAgreement> agreements = request.agreements().stream()
			.map(agreement -> new TermsAgreement(
				user,
				agreement.termsType(),
				agreement.termsVersion(),
				agreement.agreed()
			))
			.toList();
		termsAgreementRepository.saveAll(agreements);

		return authResponse(user);
	}

	@Transactional(readOnly = true)
	public TokenRefreshResponse refresh(RefreshTokenRequest request) {
		Long userId = jwtTokenProvider.validateRefreshTokenAndGetUserId(request.refreshToken());
		User user = userRepository.findById(userId)
			.orElseThrow(() -> ApiException.unauthorized("로그인이 필요합니다."));

		return new TokenRefreshResponse(
			jwtTokenProvider.createAccessToken(user),
			jwtTokenProvider.createRefreshToken(user)
		);
	}

	@Transactional(readOnly = true)
	public AuthResponse login(LoginRequest request) {
		User user = userRepository.findByLoginId(request.loginId())
			.filter(candidate -> passwordEncoder.matches(request.password(), candidate.getPasswordHash()))
			.orElseThrow(() -> ApiException.unauthorized("아이디 또는 비밀번호가 올바르지 않습니다."));

		return authResponse(user);
	}

	private void validateDuplicates(SignupRequest request) {
		if (userRepository.existsByLoginId(request.loginId())) {
			throw ApiException.conflict("이미 사용 중인 아이디입니다.");
		}
		if (userRepository.existsByNickname(request.nickname())) {
			throw ApiException.conflict("이미 사용 중인 닉네임입니다.");
		}
	}

	private void validateRequiredAgreements(List<AgreementRequest> agreements) {
		Set<String> agreedTypes = agreements.stream()
			.filter(agreement -> Boolean.TRUE.equals(agreement.agreed()))
			.map(AgreementRequest::termsType)
			.collect(Collectors.toSet());

		if (!agreedTypes.containsAll(REQUIRED_AGREEMENTS)) {
			throw ApiException.badRequest("필수 약관에 모두 동의해야 합니다.");
		}
	}

	private AuthResponse authResponse(User user) {
		return new AuthResponse(
			jwtTokenProvider.createAccessToken(user),
			jwtTokenProvider.createRefreshToken(user),
			user.getId(),
			user.getNickname()
		);
	}
}
