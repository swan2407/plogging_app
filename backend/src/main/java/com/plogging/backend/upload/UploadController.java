package com.plogging.backend.upload;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import com.plogging.backend.upload.dto.UploadResponse;

@RestController
@RequestMapping("/api/uploads")
public class UploadController {

	private final ImageStorageService imageStorageService;

	public UploadController(ImageStorageService imageStorageService) {
		this.imageStorageService = imageStorageService;
	}

	@PostMapping(value = "/images", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	@ResponseStatus(HttpStatus.CREATED)
	public UploadResponse uploadImage(@RequestParam("file") MultipartFile file) {
		String storedFileName = imageStorageService.store(file);
		String imageUrl = ServletUriComponentsBuilder.fromCurrentContextPath()
			.path(imageStorageService.publicPath(storedFileName))
			.toUriString();
		return new UploadResponse(imageUrl);
	}
}
