package com.plogging.backend.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record AgreementRequest(
	@NotBlank(message = "약관 유형은 필수입니다.")
	String termsType,

	@NotBlank(message = "약관 버전은 필수입니다.")
	String termsVersion,

	@NotNull(message = "약관 동의 여부는 필수입니다.")
	Boolean agreed
) {
}
