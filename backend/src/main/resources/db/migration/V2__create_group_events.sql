CREATE TABLE group_events (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    leader_id BIGINT NOT NULL,
    region_sido VARCHAR(30) NOT NULL,
    region_sigungu VARCHAR(50) NOT NULL,
    start_at TIMESTAMP NOT NULL,
    end_at TIMESTAMP NOT NULL,
    recruit_deadline_at TIMESTAMP NOT NULL,
    max_participants INT NOT NULL,
    current_participants INT NOT NULL DEFAULT 0,
    place_name VARCHAR(150) NOT NULL,
    address VARCHAR(255),
    lat NUMERIC(10, 7),
    lng NUMERIC(10, 7),
    supplies VARCHAR(255),
    description TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'RECRUITING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    canceled_at TIMESTAMP,
    CONSTRAINT fk_group_events_leader
        FOREIGN KEY (leader_id) REFERENCES users(id),
    CONSTRAINT ck_group_events_time
        CHECK (end_at > start_at),
    CONSTRAINT ck_group_events_deadline
        CHECK (recruit_deadline_at <= start_at),
    CONSTRAINT ck_group_events_max_participants
        CHECK (max_participants BETWEEN 2 AND 100),
    CONSTRAINT ck_group_events_current_participants
        CHECK (current_participants BETWEEN 0 AND max_participants),
    CONSTRAINT ck_group_events_lat
        CHECK (lat IS NULL OR lat BETWEEN -90 AND 90),
    CONSTRAINT ck_group_events_lng
        CHECK (lng IS NULL OR lng BETWEEN -180 AND 180)
);

CREATE TABLE group_participants (
    id BIGSERIAL PRIMARY KEY,
    group_event_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'JOINED',
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    canceled_at TIMESTAMP,
    attended_at TIMESTAMP,
    CONSTRAINT fk_group_participants_event
        FOREIGN KEY (group_event_id) REFERENCES group_events(id),
    CONSTRAINT fk_group_participants_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT uk_group_participants_event_user
        UNIQUE (group_event_id, user_id)
);

CREATE INDEX idx_group_events_start_at ON group_events (start_at);
CREATE INDEX idx_group_events_region ON group_events (region_sido, region_sigungu);
CREATE INDEX idx_group_participants_user ON group_participants (user_id, joined_at DESC);
