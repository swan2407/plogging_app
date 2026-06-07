package com.plogging.backend.auth.dto;

import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record SignupRequest(
	@NotBlank(message = "아이디는 필수입니다.")
	@Size(max = 50, message = "아이디는 50자 이하여야 합니다.")
	String loginId,

	@NotBlank(message = "비밀번호는 필수입니다.")
	@Size(min = 8, message = "비밀번호는 8자 이상이어야 합니다.")
	@Pattern(regexp = ".*[A-Za-z].*", message = "비밀번호에는 영문자가 포함되어야 합니다.")
	@Pattern(regexp = ".*\\d.*", message = "비밀번호에는 숫자가 포함되어야 합니다.")
	@Pattern(regexp = ".*[^A-Za-z0-9].*", message = "비밀번호에는 특수문자가 포함되어야 합니다.")
	String password,

	@NotBlank(message = "닉네임은 필수입니다.")
	@Size(max = 50, message = "닉네임은 50자 이하여야 합니다.")
	String nickname,

	@Size(max = 30, message = "시도는 30자 이하여야 합니다.")
	String regionSido,

	@Size(max = 50, message = "시군구는 50자 이하여야 합니다.")
	String regionSigungu,

	@NotNull(message = "약관 동의 목록은 필수입니다.")
	List<@Valid AgreementRequest> agreements
) {
}
