package com.plogging.backend.plogging;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.plogging.backend.auth.CurrentUserService;
import com.plogging.backend.plogging.dto.PloggingSessionResponse;
import com.plogging.backend.plogging.dto.SavePloggingResultRequest;
import com.plogging.backend.user.User;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/plogging/sessions")
public class PloggingController {

	private final PloggingService ploggingService;
	private final CurrentUserService currentUserService;

	public PloggingController(PloggingService ploggingService, CurrentUserService currentUserService) {
		this.ploggingService = ploggingService;
		this.currentUserService = currentUserService;
	}

	@PostMapping("/completed")
	@ResponseStatus(HttpStatus.CREATED)
	public PloggingSessionResponse saveCompleted(
		@Valid @RequestBody SavePloggingResultRequest request
	) {
		User currentUser = currentUserService.requireUser();
		return ploggingService.saveCompleted(request, currentUser);
	}

	@GetMapping("/me")
	public List<PloggingSessionResponse> findMine() {
		User currentUser = currentUserService.requireUser();
		return ploggingService.findMine(currentUser);
	}

	@GetMapping("/{sessionId}")
	public PloggingSessionResponse findMineById(
		@PathVariable Long sessionId
	) {
		User currentUser = currentUserService.requireUser();
		return ploggingService.findMineById(sessionId, currentUser);
	}
}
