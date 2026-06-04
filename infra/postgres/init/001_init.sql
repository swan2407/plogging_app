-- The application schema will be managed by Spring Boot migrations or future SQL migration files.
CREATE TABLE IF NOT EXISTS health_check (
    id INTEGER PRIMARY KEY,
    status VARCHAR(20) NOT NULL,
    checked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO health_check (id, status)
VALUES (1, 'ok')
ON CONFLICT (id) DO NOTHING;
