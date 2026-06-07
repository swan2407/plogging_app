CREATE TABLE plogging_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    group_event_id BIGINT,
    type VARCHAR(20) NOT NULL DEFAULT 'PERSONAL',
    status VARCHAR(30) NOT NULL DEFAULT 'COMPLETED',
    start_at TIMESTAMP NOT NULL,
    end_at TIMESTAMP,
    duration_seconds INT,
    distance_meter INT,
    start_lat NUMERIC(10, 7),
    start_lng NUMERIC(10, 7),
    end_lat NUMERIC(10, 7),
    end_lng NUMERIC(10, 7),
    region_sido VARCHAR(30),
    region_sigungu VARCHAR(50),
    trash_certification_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_plogging_sessions_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_plogging_sessions_group_event
        FOREIGN KEY (group_event_id) REFERENCES group_events(id),
    CONSTRAINT ck_plogging_sessions_time
        CHECK (end_at IS NULL OR end_at > start_at),
    CONSTRAINT ck_plogging_sessions_duration
        CHECK (duration_seconds IS NULL OR duration_seconds > 0),
    CONSTRAINT ck_plogging_sessions_distance
        CHECK (distance_meter IS NULL OR distance_meter >= 0),
    CONSTRAINT ck_plogging_sessions_trash_count
        CHECK (trash_certification_count >= 0),
    CONSTRAINT ck_plogging_sessions_start_lat
        CHECK (start_lat IS NULL OR start_lat BETWEEN -90 AND 90),
    CONSTRAINT ck_plogging_sessions_start_lng
        CHECK (start_lng IS NULL OR start_lng BETWEEN -180 AND 180),
    CONSTRAINT ck_plogging_sessions_end_lat
        CHECK (end_lat IS NULL OR end_lat BETWEEN -90 AND 90),
    CONSTRAINT ck_plogging_sessions_end_lng
        CHECK (end_lng IS NULL OR end_lng BETWEEN -180 AND 180)
);

CREATE TABLE trash_records (
    id BIGSERIAL PRIMARY KEY,
    session_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    lat NUMERIC(10, 7) NOT NULL,
    lng NUMERIC(10, 7) NOT NULL,
    trash_type VARCHAR(50),
    count INT,
    weight_gram INT,
    memo VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_trash_records_session
        FOREIGN KEY (session_id) REFERENCES plogging_sessions(id),
    CONSTRAINT fk_trash_records_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT ck_trash_records_lat
        CHECK (lat BETWEEN -90 AND 90),
    CONSTRAINT ck_trash_records_lng
        CHECK (lng BETWEEN -180 AND 180),
    CONSTRAINT ck_trash_records_count
        CHECK (count IS NULL OR count >= 0),
    CONSTRAINT ck_trash_records_weight
        CHECK (weight_gram IS NULL OR weight_gram >= 0)
);

CREATE INDEX idx_plogging_sessions_user_start
    ON plogging_sessions (user_id, start_at DESC);
CREATE INDEX idx_trash_records_session
    ON trash_records (session_id, created_at);
