package com.plogging.backend.common;

import java.util.Comparator;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingRequestHeaderException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

	@ExceptionHandler(ApiException.class)
	public ResponseEntity<ErrorResponse> handleApiException(ApiException exception) {
		return ResponseEntity.status(exception.getStatus())
			.body(new ErrorResponse(exception.getMessage()));
	}

	@ExceptionHandler(MethodArgumentNotValidException.class)
	public ResponseEntity<ErrorResponse> handleValidationException(MethodArgumentNotValidException exception) {
		String message = exception.getBindingResult().getFieldErrors().stream()
			.sorted(Comparator.comparing(error -> error.getField()))
			.map(error -> error.getDefaultMessage())
			.findFirst()
			.orElse("요청 값이 올바르지 않습니다.");

		return ResponseEntity.badRequest().body(new ErrorResponse(message));
	}

	@ExceptionHandler(MissingRequestHeaderException.class)
	public ResponseEntity<ErrorResponse> handleMissingHeaderException(MissingRequestHeaderException exception) {
		return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
			.body(new ErrorResponse("Authorization 헤더가 필요합니다."));
	}

	@ExceptionHandler(DataIntegrityViolationException.class)
	public ResponseEntity<ErrorResponse> handleDataIntegrityViolation(DataIntegrityViolationException exception) {
		return ResponseEntity.status(HttpStatus.CONFLICT)
			.body(new ErrorResponse("이미 사용 중인 아이디 또는 닉네임입니다."));
	}

	public record ErrorResponse(String message) {
	}
}
