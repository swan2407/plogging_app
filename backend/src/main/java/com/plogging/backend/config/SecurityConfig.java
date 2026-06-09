package com.plogging.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.plogging.backend.auth.JwtAuthenticationFilter;

@Configuration
public class SecurityConfig {

	private final JwtAuthenticationFilter jwtAuthenticationFilter;

	public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter) {
		this.jwtAuthenticationFilter = jwtAuthenticationFilter;
	}

	@Bean
	public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
		http
			.csrf(csrf -> csrf.disable())
			.cors(Customizer.withDefaults())
			.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
			.exceptionHandling(exception -> exception.authenticationEntryPoint((request, response, authException) -> {
				response.setStatus(HttpStatus.UNAUTHORIZED.value());
				response.setCharacterEncoding("UTF-8");
				response.setContentType(MediaType.APPLICATION_JSON_VALUE);
				response.getWriter().write("{\"message\":\"로그인이 필요합니다.\"}");
			}))
			.authorizeHttpRequests(auth -> auth
				.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
				.requestMatchers(HttpMethod.POST, "/api/auth/signup", "/api/auth/login", "/api/auth/refresh").permitAll()
				.requestMatchers(HttpMethod.GET, "/api/health/**").permitAll()
				.requestMatchers(HttpMethod.GET, "/uploads/**").permitAll()
				.requestMatchers(HttpMethod.GET, "/api/group-events", "/api/group-events/*").permitAll()
				.requestMatchers(HttpMethod.GET, "/api/posts", "/api/posts/*", "/api/posts/*/comments").permitAll()
				.anyRequest().authenticated()
			)
			.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

		return http.build();
	}
}
