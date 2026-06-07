CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    login_id VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nickname VARCHAR(50) NOT NULL UNIQUE,
    region_sido VARCHAR(30),
    region_sigungu VARCHAR(50),
    profile_image_url VARCHAR(500),
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    provider VARCHAR(20) NOT NULL DEFAULT 'LOCAL',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE terms_agreements (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    terms_type VARCHAR(50) NOT NULL,
    terms_version VARCHAR(30) NOT NULL,
    agreed BOOLEAN NOT NULL,
    agreed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_terms_agreements_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT uk_terms_agreements_user_type_version
        UNIQUE (user_id, terms_type, terms_version)
);
