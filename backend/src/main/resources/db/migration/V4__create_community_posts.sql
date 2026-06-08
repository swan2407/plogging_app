CREATE TABLE community_posts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_id BIGINT,
    category VARCHAR(30) NOT NULL,
    title VARCHAR(150) NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    region_sido VARCHAR(30),
    region_sigungu VARCHAR(50),
    like_count INT NOT NULL DEFAULT 0,
    comment_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT fk_community_posts_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_community_posts_session
        FOREIGN KEY (session_id) REFERENCES plogging_sessions(id),
    CONSTRAINT ck_community_posts_category
        CHECK (category IN ('ACTIVITY_REVIEW', 'GROUP_PROMOTION', 'INFO_SHARE', 'QUESTION')),
    CONSTRAINT ck_community_posts_like_count
        CHECK (like_count >= 0),
    CONSTRAINT ck_community_posts_comment_count
        CHECK (comment_count >= 0)
);

CREATE TABLE comments (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    content VARCHAR(1000) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT fk_comments_post
        FOREIGN KEY (post_id) REFERENCES community_posts(id),
    CONSTRAINT fk_comments_user
        FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE post_likes (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_post_likes_post
        FOREIGN KEY (post_id) REFERENCES community_posts(id),
    CONSTRAINT fk_post_likes_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT uk_post_likes_post_user
        UNIQUE (post_id, user_id)
);

CREATE INDEX idx_community_posts_created_at
    ON community_posts (created_at DESC);
CREATE INDEX idx_community_posts_category_created_at
    ON community_posts (category, created_at DESC);
CREATE INDEX idx_comments_post_created_at
    ON comments (post_id, created_at);
