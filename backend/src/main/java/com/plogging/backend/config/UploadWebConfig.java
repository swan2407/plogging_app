package com.plogging.backend.config;

import java.nio.file.Path;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class UploadWebConfig implements WebMvcConfigurer {

	private final Path uploadDirectory;
	private final String publicUrlPrefix;

	public UploadWebConfig(
		@Value("${app.upload.dir}") String uploadDirectory,
		@Value("${app.upload.public-url-prefix}") String publicUrlPrefix
	) {
		this.uploadDirectory = Path.of(uploadDirectory).toAbsolutePath().normalize();
		this.publicUrlPrefix = normalizePublicUrlPrefix(publicUrlPrefix);
	}

	@Override
	public void addResourceHandlers(ResourceHandlerRegistry registry) {
		String resourceLocation = uploadDirectory.toUri().toString();
		if (!resourceLocation.endsWith("/")) {
			resourceLocation += "/";
		}
		registry.addResourceHandler(publicUrlPrefix + "/**")
			.addResourceLocations(resourceLocation);
	}

	private String normalizePublicUrlPrefix(String prefix) {
		String normalized = prefix.startsWith("/") ? prefix : "/" + prefix;
		while (normalized.endsWith("/") && normalized.length() > 1) {
			normalized = normalized.substring(0, normalized.length() - 1);
		}
		return normalized;
	}
}
