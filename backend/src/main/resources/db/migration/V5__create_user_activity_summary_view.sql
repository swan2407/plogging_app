CREATE OR REPLACE VIEW user_activity_summary AS
SELECT
    u.id AS user_id,
    u.nickname AS nickname,
    COUNT(ps.id)::BIGINT AS total_plogging_count,
    COALESCE(SUM(ps.distance_meter), 0)::BIGINT AS total_distance_meter,
    COALESCE(SUM(ps.duration_seconds), 0)::BIGINT AS total_duration_seconds,
    COALESCE(SUM(ps.trash_certification_count), 0)::BIGINT
        AS total_trash_certification_count
FROM users u
LEFT JOIN plogging_sessions ps
    ON ps.user_id = u.id
    AND ps.status = 'COMPLETED'
GROUP BY u.id, u.nickname;
