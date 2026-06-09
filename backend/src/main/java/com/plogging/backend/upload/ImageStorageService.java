package com.plogging.backend.upload;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import com.plogging.backend.common.ApiException;

@Service
public class ImageStorageService {

	private static final Map<String, String> DEFAULT_EXTENSION_BY_CONTENT_TYPE = Map.of(
		"image/jpeg", "jpg",
		"image/png", "png",
		"image/webp", "webp"
	);
	private static final Map<String, Set<String>> EXTENSIONS_BY_CONTENT_TYPE = Map.of(
		"image/jpeg", Set.of("jpg", "jpeg"),
		"image/png", Set.of("png"),
		"image/webp", Set.of("webp")
	);

	private final Path uploadDirectory;
	private final String publicUrlPrefix;

	public ImageStorageService(
		@Value("${app.upload.dir}") String uploadDirectory,
		@Value("${app.upload.public-url-prefix}") String publicUrlPrefix
	) {
		this.uploadDirectory = Path.of(uploadDirectory).toAbsolutePath().normalize();
		this.publicUrlPrefix = normalizePublicUrlPrefix(publicUrlPrefix);
	}

	public String store(MultipartFile file) {
		if (file == null || file.isEmpty()) {
			throw ApiException.badRequest("이미지 파일이 필요합니다.");
		}

		String contentType = normalizeContentType(file.getContentType());
		if (!DEFAULT_EXTENSION_BY_CONTENT_TYPE.containsKey(contentType)) {
			throw ApiException.badRequest("지원하지 않는 이미지 형식입니다.");
		}

		String extension = resolveExtension(file.getOriginalFilename(), contentType);
		String storedFileName = UUID.randomUUID() + "." + extension;
		Path targetFile = uploadDirectory.resolve(storedFileName).normalize();

		if (!targetFile.startsWith(uploadDirectory)) {
			throw ApiException.badRequest("지원하지 않는 이미지 형식입니다.");
		}

		try {
			Files.createDirectories(uploadDirectory);
			try (InputStream inputStream = file.getInputStream()) {
				Files.copy(inputStream, targetFile, StandardCopyOption.REPLACE_EXISTING);
			}
			return storedFileName;
		} catch (IOException | SecurityException exception) {
			throw ApiException.internalServerError("이미지 업로드에 실패했습니다.");
		}
	}

	public String publicPath(String storedFileName) {
		return publicUrlPrefix + "/" + storedFileName;
	}

	private String resolveExtension(String originalFilename, String contentType) {
		String originalExtension = StringUtils.getFilenameExtension(originalFilename);
		if (originalExtension != null) {
			String normalizedExtension = originalExtension.toLowerCase(Locale.ROOT);
			if (EXTENSIONS_BY_CONTENT_TYPE.get(contentType).contains(normalizedExtension)) {
				return normalizedExtension;
			}
		}
		return DEFAULT_EXTENSION_BY_CONTENT_TYPE.get(contentType);
	}

	private String normalizeContentType(String contentType) {
		return contentType == null ? "" : contentType.toLowerCase(Locale.ROOT);
	}

	private String normalizePublicUrlPrefix(String prefix) {
		String normalized = prefix.startsWith("/") ? prefix : "/" + prefix;
		while (normalized.endsWith("/") && normalized.length() > 1) {
			normalized = normalized.substring(0, normalized.length() - 1);
		}
		return normalized;
	}
}
