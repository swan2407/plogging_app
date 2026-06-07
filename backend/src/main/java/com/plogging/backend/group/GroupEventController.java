package com.plogging.backend.group;

import java.util.List;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.plogging.backend.auth.CurrentUserService;
import com.plogging.backend.group.dto.CreateGroupEventRequest;
import com.plogging.backend.group.dto.GroupEventResponse;
import com.plogging.backend.user.User;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/group-events")
public class GroupEventController {

	private final GroupEventService groupEventService;
	private final CurrentUserService currentUserService;

	public GroupEventController(GroupEventService groupEventService, CurrentUserService currentUserService) {
		this.groupEventService = groupEventService;
		this.currentUserService = currentUserService;
	}

	@GetMapping
	public List<GroupEventResponse> findAll() {
		return groupEventService.findAll();
	}

	@GetMapping("/{eventId}")
	public GroupEventResponse findById(@PathVariable Long eventId) {
		return groupEventService.findById(eventId);
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public GroupEventResponse create(
		@RequestHeader(value = HttpHeaders.AUTHORIZATION, required = false) String authorization,
		@Valid @RequestBody CreateGroupEventRequest request
	) {
		User currentUser = currentUserService.requireUser(authorization);
		return groupEventService.create(request, currentUser);
	}

	@PostMapping("/{eventId}/join")
	public GroupEventResponse join(
		@PathVariable Long eventId,
		@RequestHeader(value = HttpHeaders.AUTHORIZATION, required = false) String authorization
	) {
		User currentUser = currentUserService.requireUser(authorization);
		return groupEventService.join(eventId, currentUser);
	}
}
