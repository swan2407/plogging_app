# 플로깅 앱 PostgreSQL 스키마 명세

## 1. 문서 목적

본 문서는 플로깅 앱 MVP의 PostgreSQL 데이터베이스 구조를 정의한다. 향후 Spring Boot 백엔드의 엔티티, Repository, 서비스 로직, 데이터베이스 마이그레이션을 구현할 때 기준으로 사용한다.

인증은 추후 JWT 기반으로 구현하되, 비밀번호는 평문이 아닌 `password_hash`로만 저장한다. 공개 데이터 조회는 비회원에게 허용할 수 있지만 기록 생성, 단체 참여, 게시글 작성, 마이페이지 데이터 접근은 사용자 계정을 전제로 한다.

## 2. ERD 개요

주요 관계는 다음과 같다.

- 사용자 한 명은 여러 플로깅 세션을 가진다.
- 사용자 한 명은 여러 쓰레기 인증 기록을 가진다.
- 사용자는 여러 단체 플로깅 행사를 만들 수 있다.
- 사용자는 여러 단체 플로깅 행사에 참여할 수 있다.
- 플로깅 세션 하나는 여러 이동 경로 좌표를 가진다.
- 플로깅 세션 하나는 여러 쓰레기 인증 기록을 가진다.
- 커뮤니티 게시글은 작성 사용자에게 속한다.
- 커뮤니티 게시글은 하나의 플로깅 세션과 선택적으로 연결될 수 있다.
- 게시글 하나는 여러 댓글과 좋아요를 가진다.
- 단체 플로깅 세션은 하나의 단체 플로깅 행사와 선택적으로 연결된다.

```text
users 1 ── N plogging_sessions 1 ── N plogging_routes
  │                 │
  │                 └──────────── N trash_records
  ├── N trash_records
  ├── N group_events (leader)
  ├── N group_participants N ── 1 group_events
  ├── N community_posts 0..1 ── 1 plogging_sessions
  ├── N comments N ── 1 community_posts
  └── N post_likes N ── 1 community_posts
```

## 3. MVP 테이블

### 3.1 `users`

사용자 계정과 공개 프로필 정보를 저장한다.

| 컬럼 | 타입 | Null | 설명 |
|---|---|---|---|
| `id` | `BIGINT` | N | 사용자 PK |
| `login_id` | `VARCHAR(50)` | N | 로그인 아이디, 고유값 |
| `password_hash` | `VARCHAR(255)` | N | 해시된 비밀번호 |
| `nickname` | `VARCHAR(50)` | N | 닉네임, 고유값 |
| `region_sido` | `VARCHAR(50)` | Y | 선택 시도 |
| `region_sigungu` | `VARCHAR(50)` | Y | 선택 시군구 |
| `profile_image_url` | `TEXT` | Y | 프로필 이미지 URL |
| `role` | `VARCHAR(20)` | N | `USER`, `ADMIN` |
| `provider` | `VARCHAR(20)` | N | `LOCAL`, 향후 `KAKAO` |
| `created_at` | `TIMESTAMP` | N | 생성 시각 |
| `updated_at` | `TIMESTAMP` | N | 수정 시각 |
| `deleted_at` | `TIMESTAMP` | Y | 소프트 삭제 시각 |

### 3.2 `terms_agreements`

사용자별 약관 동의 이력을 버전 단위로 저장한다.

| 컬럼 | 타입 | Null | 설명 |
|---|---|---|---|
| `id` | `BIGINT` | N | 약관 동의 PK |
| `user_id` | `BIGINT` | N | 사용자 FK |
| `terms_type` | `VARCHAR(50)` | N | 약관 종류 |
| `terms_version` | `VARCHAR(20)` | N | 약관 버전 |
| `agreed` | `BOOLEAN` | N | 동의 여부 |
| `agreed_at` | `TIMESTAMP` | N | 동의 또는 철회 시각 |

### 3.3 `plogging_sessions`

개인 및 단체 플로깅 활동 단위를 저장한다.

| 컬럼 | 타입 | Null | 설명 |
|---|---|---|---|
| `id` | `BIGINT` | N | 세션 PK |
| `user_id` | `BIGINT` | N | 활동 사용자 FK |
| `group_event_id` | `BIGINT` | Y | 단체 행사 FK |
| `type` | `VARCHAR(20)` | N | `PERSONAL`, `GROUP` |
| `status` | `VARCHAR(20)` | N | 세션 상태 |
| `start_at` | `TIMESTAMP` | N | 시작 시각 |
| `end_at` | `TIMESTAMP` | Y | 종료 시각 |
| `duration_seconds` | `INTEGER` | Y | 활동 시간(초) |
| `distance_meter` | `INTEGER` | Y | 이동 거리(m) |
| `start_lat` | `NUMERIC(9,6)` | Y | 시작 위도 |
| `start_lng` | `NUMERIC(10,6)` | Y | 시작 경도 |
| `end_lat` | `NUMERIC(9,6)` | Y | 종료 위도 |
| `end_lng` | `NUMERIC(10,6)` | Y | 종료 경도 |
| `trash_certification_count` | `INTEGER` | N | 쓰레기 인증 수 |
| `created_at` | `TIMESTAMP` | N | 생성 시각 |
| `updated_at` | `TIMESTAMP` | N | 수정 시각 |

### 3.4 `plogging_routes`

플로깅 세션의 이동 경로 좌표를 시간순으로 저장한다.

| 컬럼 | 타입 | Null | 설명 |
|---|---|---|---|
| `id` | `BIGINT` | N | 경로 좌표 PK |
| `session_id` | `BIGINT` | N | 플로깅 세션 FK |
| `lat` | `NUMERIC(9,6)` | N | 위도 |
| `lng` | `NUMERIC(10,6)` | N | 경도 |
| `recorded_at` | `TIMESTAMP` | N | 좌표 기록 시각 |

### 3.5 `trash_records`

플로깅 중 등록한 사진 우선 쓰레기 인증을 저장한다. 사진, 위치는 필수이며 종류, 개수, 무게, 메모는 선택 입력이다.

| 컬럼 | 타입 | Null | 설명 |
|---|---|---|---|
| `id` | `BIGINT` | N | 쓰레기 인증 PK |
| `session_id` | `BIGINT` | N | 플로깅 세션 FK |
| `user_id` | `BIGINT` | N | 등록 사용자 FK |
| `image_url` | `TEXT` | N | 인증 사진 URL |
| `lat` | `NUMERIC(9,6)` | N | 인증 위치 위도 |
| `lng` | `NUMERIC(10,6)` | N | 인증 위치 경도 |
| `trash_type` | `VARCHAR(30)` | Y | 쓰레기 종류 |
| `count` | `INTEGER` | Y | 수거 개수 |
| `weight_gram` | `INTEGER` | Y | 수거 무게(g) |
| `memo` | `TEXT` | Y | 메모 |
| `created_at` | `TIMESTAMP` | N | 생성 시각 |

### 3.6 `group_events`

구조화된 단체 플로깅 행사 정보를 저장한다. 리더, 상태, 현재 참여 인원, 생성 시각은 서버가 관리한다. MVP에서 `recruit_deadline_at`은 `start_at`과 동일하게 설정한다.

| 컬럼 | 타입 | Null | 설명 |
|---|---|---|---|
| `id` | `BIGINT` | N | 행사 PK |
| `title` | `VARCHAR(100)` | N | 행사 제목 |
| `leader_id` | `BIGINT` | N | 행사 리더 사용자 FK |
| `region_sido` | `VARCHAR(50)` | N | 시도 |
| `region_sigungu` | `VARCHAR(50)` | N | 시군구 |
| `start_at` | `TIMESTAMP` | N | 시작 시각 |
| `end_at` | `TIMESTAMP` | N | 종료 시각 |
| `recruit_deadline_at` | `TIMESTAMP` | N | 모집 마감 시각, MVP에서는 시작 시각과 동일 |
| `max_participants` | `INTEGER` | N | 최대 참여 인원 |
| `current_participants` | `INTEGER` | N | 현재 참여 인원, 서버 관리 |
| `place_name` | `VARCHAR(150)` | N | 집결 장소명 |
| `address` | `TEXT` | Y | 주소 |
| `lat` | `NUMERIC(9,6)` | Y | 집결 장소 위도 |
| `lng` | `NUMERIC(10,6)` | Y | 집결 장소 경도 |
| `supplies` | `TEXT` | Y | 준비물 |
| `description` | `TEXT` | N | 상세 설명 |
| `status` | `VARCHAR(20)` | N | 행사 상태, 서버 관리 |
| `created_at` | `TIMESTAMP` | N | 생성 시각 |
| `updated_at` | `TIMESTAMP` | N | 수정 시각 |
| `canceled_at` | `TIMESTAMP` | Y | 취소 시각 |

### 3.7 `group_participants`

사용자의 단체 플로깅 참여 상태를 저장한다.

| 컬럼 | 타입 | Null | 설명 |
|---|---|---|---|
| `id` | `BIGINT` | N | 참여 PK |
| `group_event_id` | `BIGINT` | N | 단체 행사 FK |
| `user_id` | `BIGINT` | N | 참여 사용자 FK |
| `status` | `VARCHAR(20)` | N | `JOINED`, `CANCELED`, `ATTENDED` |
| `joined_at` | `TIMESTAMP` | N | 참여 시각 |
| `canceled_at` | `TIMESTAMP` | Y | 참여 취소 시각 |
| `attended_at` | `TIMESTAMP` | Y | 출석 처리 시각 |

### 3.8 `community_posts`

사용자 커뮤니티 게시글을 저장한다. 활동 후기 게시글은 플로깅 세션과 선택적으로 연결할 수 있다.

| 컬럼 | 타입 | Null | 설명 |
|---|---|---|---|
| `id` | `BIGINT` | N | 게시글 PK |
| `user_id` | `BIGINT` | N | 작성 사용자 FK |
| `session_id` | `BIGINT` | Y | 연결된 플로깅 세션 FK |
| `category` | `VARCHAR(30)` | N | 게시글 카테고리 |
| `title` | `VARCHAR(150)` | N | 제목 |
| `content` | `TEXT` | N | 내용 |
| `image_url` | `TEXT` | Y | 대표 이미지 URL |
| `region_sido` | `VARCHAR(50)` | Y | 공개 시도 |
| `region_sigungu` | `VARCHAR(50)` | Y | 공개 시군구 |
| `like_count` | `INTEGER` | N | 좋아요 수 |
| `comment_count` | `INTEGER` | N | 댓글 수 |
| `created_at` | `TIMESTAMP` | N | 생성 시각 |
| `updated_at` | `TIMESTAMP` | N | 수정 시각 |
| `deleted_at` | `TIMESTAMP` | Y | 소프트 삭제 시각 |

### 3.9 `comments`

게시글 댓글을 저장한다.

| 컬럼 | 타입 | Null | 설명 |
|---|---|---|---|
| `id` | `BIGINT` | N | 댓글 PK |
| `post_id` | `BIGINT` | N | 게시글 FK |
| `user_id` | `BIGINT` | N | 작성 사용자 FK |
| `content` | `TEXT` | N | 댓글 내용 |
| `created_at` | `TIMESTAMP` | N | 생성 시각 |
| `updated_at` | `TIMESTAMP` | N | 수정 시각 |
| `deleted_at` | `TIMESTAMP` | Y | 소프트 삭제 시각 |

### 3.10 `post_likes`

사용자별 게시글 좋아요를 저장한다.

| 컬럼 | 타입 | Null | 설명 |
|---|---|---|---|
| `id` | `BIGINT` | N | 좋아요 PK |
| `post_id` | `BIGINT` | N | 게시글 FK |
| `user_id` | `BIGINT` | N | 사용자 FK |
| `created_at` | `TIMESTAMP` | N | 생성 시각 |

### 3.11 `recycling_spots`

지도 레이어에서 사용하는 분리수거 장소와 공공 쓰레기통 위치를 저장한다.

| 컬럼 | 타입 | Null | 설명 |
|---|---|---|---|
| `id` | `BIGINT` | N | 장소 PK |
| `name` | `VARCHAR(150)` | N | 장소명 |
| `type` | `VARCHAR(30)` | N | `RECYCLING_CENTER`, `PUBLIC_TRASH_BIN` |
| `region_sido` | `VARCHAR(50)` | N | 시도 |
| `region_sigungu` | `VARCHAR(50)` | N | 시군구 |
| `address` | `TEXT` | N | 주소 |
| `lat` | `NUMERIC(9,6)` | N | 위도 |
| `lng` | `NUMERIC(10,6)` | N | 경도 |
| `description` | `TEXT` | Y | 설명 |
| `source` | `VARCHAR(255)` | Y | 데이터 출처 |
| `created_at` | `TIMESTAMP` | N | 생성 시각 |
| `updated_at` | `TIMESTAMP` | N | 수정 시각 |

지도 레이어는 `group_events`, `trash_records`, `recycling_spots`를 각각 조회하며, `recycling_spots.type`으로 분리수거 장소와 공공 쓰레기통을 구분한다.

### 3.12 `notices`

서비스 공지사항을 저장한다.

| 컬럼 | 타입 | Null | 설명 |
|---|---|---|---|
| `id` | `BIGINT` | N | 공지 PK |
| `title` | `VARCHAR(150)` | N | 제목 |
| `content` | `TEXT` | N | 내용 |
| `created_at` | `TIMESTAMP` | N | 생성 시각 |
| `updated_at` | `TIMESTAMP` | N | 수정 시각 |

### 3.13 `user_activity_summary` View

사용자별 완료된 플로깅 활동을 집계하는 View다. 마이페이지 통계에서 총 플로깅 횟수, 총 이동 거리, 총 활동 시간, 총 쓰레기 인증 수를 조회할 때 사용한다.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `user_id` | `BIGINT` | 사용자 ID |
| `total_plogging_count` | `BIGINT` | 완료된 플로깅 총 횟수 |
| `total_distance_meter` | `BIGINT` | 완료된 플로깅 총 이동 거리(m) |
| `total_duration_seconds` | `BIGINT` | 완료된 플로깅 총 활동 시간(초) |
| `total_trash_certification_count` | `BIGINT` | 완료된 플로깅의 총 쓰레기 인증 수 |

## 4. Phase 2 / Future 테이블

| 테이블 | 단계 | 목적 |
|---|---|---|
| `notifications` | Phase 2 | 단체 행사 변경, 댓글, 좋아요 등 사용자 알림 저장 |
| `reports` | Phase 2 | 게시글, 댓글, 사용자 신고 및 처리 상태 저장 |
| `image_uploads` | Phase 2 | 업로드 파일의 소유자, 저장 키, 용도, 상태 관리 |
| `admin_logs` | Future | 관리자 데이터 변경 및 운영 작업 감사 로그 |
| `child_guardian_consents` | Future | 만 14세 미만 사용자 법정대리인 동의 이력 관리 |

이미지 업로드 기능이 분리되면 `trash_records.image_url`, `community_posts.image_url`, `users.profile_image_url`은 `image_uploads` 참조 방식으로 확장할 수 있다.

## 5. 제약조건 및 인덱스

### 5.1 권장 제약조건

- `users.login_id`는 고유해야 한다.
- `users.nickname`은 고유해야 한다.
- `post_likes(post_id, user_id)`는 고유해야 한다.
- `group_participants(group_event_id, user_id)`는 고유해야 한다.
- `terms_agreements(user_id, terms_type, terms_version)`는 고유해야 한다.
- 위도는 `-90` 이상 `90` 이하, 경도는 `-180` 이상 `180` 이하로 제한한다.
- 개수, 무게, 거리, 시간, 참여 인원, 집계 컬럼은 음수가 될 수 없다.
- `group_events.end_at > group_events.start_at`이어야 한다.
- MVP에서 `group_events.recruit_deadline_at = group_events.start_at`이어야 한다.
- `group_events.current_participants <= group_events.max_participants`이어야 한다.
- `plogging_sessions.type = PERSONAL`이면 `group_event_id`는 `NULL`이어야 한다.
- `plogging_sessions.type = GROUP`이면 `group_event_id`가 있어야 한다.

### 5.2 권장 인덱스

- 지역 조회: `(region_sido, region_sigungu)`
- 행사 시간 조회: `group_events(start_at)`
- 세션 시간 조회: `plogging_sessions(start_at)`
- 사용자별 목록: `plogging_sessions(user_id, created_at DESC)`
- 세션별 경로: `plogging_routes(session_id, recorded_at)`
- 세션별 쓰레기 인증: `trash_records(session_id, created_at)`
- 지도 범위 조회: 각 지도 테이블의 `(lat, lng)`
- 게시글 목록: `community_posts(created_at DESC)` 및 `(category, created_at DESC)`
- 댓글 목록: `comments(post_id, created_at)`

대규모 지도 범위 검색이 필요해지면 PostGIS의 `geography(Point, 4326)` 컬럼과 GiST 인덱스 도입을 검토한다.

### 5.3 외래 키 관계

| 자식 테이블 컬럼 | 부모 테이블 컬럼 | 삭제 정책 권장 |
|---|---|---|
| `terms_agreements.user_id` | `users.id` | `RESTRICT` |
| `plogging_sessions.user_id` | `users.id` | `RESTRICT` |
| `plogging_sessions.group_event_id` | `group_events.id` | `SET NULL` |
| `plogging_routes.session_id` | `plogging_sessions.id` | `CASCADE` |
| `trash_records.session_id` | `plogging_sessions.id` | `CASCADE` |
| `trash_records.user_id` | `users.id` | `RESTRICT` |
| `group_events.leader_id` | `users.id` | `RESTRICT` |
| `group_participants.group_event_id` | `group_events.id` | `CASCADE` |
| `group_participants.user_id` | `users.id` | `RESTRICT` |
| `community_posts.user_id` | `users.id` | `RESTRICT` |
| `community_posts.session_id` | `plogging_sessions.id` | `SET NULL` |
| `comments.post_id` | `community_posts.id` | `CASCADE` |
| `comments.user_id` | `users.id` | `RESTRICT` |
| `post_likes.post_id` | `community_posts.id` | `CASCADE` |
| `post_likes.user_id` | `users.id` | `RESTRICT` |

## 6. Enum 값

PostgreSQL enum 타입 또는 `VARCHAR + CHECK` 방식 중 하나로 통일한다. MVP 초안은 변경과 마이그레이션이 쉬운 `VARCHAR + CHECK`를 사용한다.

| 구분 | 값 |
|---|---|
| 사용자 역할 | `USER`, `ADMIN` |
| 인증 제공자 | `LOCAL`, `KAKAO` |
| 플로깅 세션 유형 | `PERSONAL`, `GROUP` |
| 플로깅 세션 상태 | `IN_PROGRESS`, `PAUSED`, `COMPLETED`, `CANCELED` |
| 단체 행사 상태 | `RECRUITING`, `CLOSED`, `IN_PROGRESS`, `COMPLETED`, `CANCELED` |
| 참여 상태 | `JOINED`, `CANCELED`, `ATTENDED` |
| 쓰레기 종류 | `PLASTIC`, `CAN`, `GLASS`, `PAPER`, `VINYL`, `GENERAL`, `FOOD`, `OTHER` |
| 커뮤니티 카테고리 | `ACTIVITY_REVIEW`, `RECRUITMENT`, `INFORMATION`, `QUESTION` |
| 재활용 장소 유형 | `RECYCLING_CENTER`, `PUBLIC_TRASH_BIN` |

## 7. MVP PostgreSQL DDL 초안

아래 DDL은 구현 시작점이다. 운영 적용 전 Flyway 또는 Liquibase 마이그레이션 파일로 분리하고, 삭제 정책과 시간대 정책을 최종 확정해야 한다.

```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    login_id VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nickname VARCHAR(50) NOT NULL UNIQUE,
    region_sido VARCHAR(50),
    region_sigungu VARCHAR(50),
    profile_image_url TEXT,
    role VARCHAR(20) NOT NULL DEFAULT 'USER'
        CHECK (role IN ('USER', 'ADMIN')),
    provider VARCHAR(20) NOT NULL DEFAULT 'LOCAL'
        CHECK (provider IN ('LOCAL', 'KAKAO')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE terms_agreements (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    terms_type VARCHAR(50) NOT NULL,
    terms_version VARCHAR(20) NOT NULL,
    agreed BOOLEAN NOT NULL,
    agreed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, terms_type, terms_version)
);

CREATE TABLE group_events (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    leader_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    region_sido VARCHAR(50) NOT NULL,
    region_sigungu VARCHAR(50) NOT NULL,
    start_at TIMESTAMP NOT NULL,
    end_at TIMESTAMP NOT NULL,
    recruit_deadline_at TIMESTAMP NOT NULL,
    max_participants INTEGER NOT NULL CHECK (max_participants > 0),
    current_participants INTEGER NOT NULL DEFAULT 0
        CHECK (current_participants >= 0),
    place_name VARCHAR(150) NOT NULL,
    address TEXT,
    lat NUMERIC(9,6) CHECK (lat BETWEEN -90 AND 90),
    lng NUMERIC(10,6) CHECK (lng BETWEEN -180 AND 180),
    supplies TEXT,
    description TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'RECRUITING'
        CHECK (status IN ('RECRUITING', 'CLOSED', 'IN_PROGRESS', 'COMPLETED', 'CANCELED')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    canceled_at TIMESTAMP,
    CHECK (end_at > start_at),
    CHECK (recruit_deadline_at = start_at),
    CHECK (current_participants <= max_participants)
);

CREATE TABLE plogging_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    group_event_id BIGINT REFERENCES group_events(id) ON DELETE SET NULL,
    type VARCHAR(20) NOT NULL
        CHECK (type IN ('PERSONAL', 'GROUP')),
    status VARCHAR(20) NOT NULL DEFAULT 'IN_PROGRESS'
        CHECK (status IN ('IN_PROGRESS', 'PAUSED', 'COMPLETED', 'CANCELED')),
    start_at TIMESTAMP NOT NULL,
    end_at TIMESTAMP,
    duration_seconds INTEGER CHECK (duration_seconds >= 0),
    distance_meter INTEGER CHECK (distance_meter >= 0),
    start_lat NUMERIC(9,6) CHECK (start_lat BETWEEN -90 AND 90),
    start_lng NUMERIC(10,6) CHECK (start_lng BETWEEN -180 AND 180),
    end_lat NUMERIC(9,6) CHECK (end_lat BETWEEN -90 AND 90),
    end_lng NUMERIC(10,6) CHECK (end_lng BETWEEN -180 AND 180),
    trash_certification_count INTEGER NOT NULL DEFAULT 0
        CHECK (trash_certification_count >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_at IS NULL OR end_at >= start_at),
    CHECK (
        (type = 'PERSONAL' AND group_event_id IS NULL)
        OR (type = 'GROUP' AND group_event_id IS NOT NULL)
    )
);

CREATE TABLE plogging_routes (
    id BIGSERIAL PRIMARY KEY,
    session_id BIGINT NOT NULL REFERENCES plogging_sessions(id) ON DELETE CASCADE,
    lat NUMERIC(9,6) NOT NULL CHECK (lat BETWEEN -90 AND 90),
    lng NUMERIC(10,6) NOT NULL CHECK (lng BETWEEN -180 AND 180),
    recorded_at TIMESTAMP NOT NULL
);

CREATE TABLE trash_records (
    id BIGSERIAL PRIMARY KEY,
    session_id BIGINT NOT NULL REFERENCES plogging_sessions(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    image_url TEXT NOT NULL,
    lat NUMERIC(9,6) NOT NULL CHECK (lat BETWEEN -90 AND 90),
    lng NUMERIC(10,6) NOT NULL CHECK (lng BETWEEN -180 AND 180),
    trash_type VARCHAR(30)
        CHECK (trash_type IS NULL OR trash_type IN (
            'PLASTIC', 'CAN', 'GLASS', 'PAPER', 'VINYL',
            'GENERAL', 'FOOD', 'OTHER'
        )),
    count INTEGER CHECK (count IS NULL OR count > 0),
    weight_gram INTEGER CHECK (weight_gram IS NULL OR weight_gram >= 0),
    memo TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE group_participants (
    id BIGSERIAL PRIMARY KEY,
    group_event_id BIGINT NOT NULL REFERENCES group_events(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    status VARCHAR(20) NOT NULL DEFAULT 'JOINED'
        CHECK (status IN ('JOINED', 'CANCELED', 'ATTENDED')),
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    canceled_at TIMESTAMP,
    attended_at TIMESTAMP,
    UNIQUE (group_event_id, user_id)
);

CREATE TABLE community_posts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    session_id BIGINT REFERENCES plogging_sessions(id) ON DELETE SET NULL,
    category VARCHAR(30) NOT NULL
        CHECK (category IN ('ACTIVITY_REVIEW', 'RECRUITMENT', 'INFORMATION', 'QUESTION')),
    title VARCHAR(150) NOT NULL,
    content TEXT NOT NULL,
    image_url TEXT,
    region_sido VARCHAR(50),
    region_sigungu VARCHAR(50),
    like_count INTEGER NOT NULL DEFAULT 0 CHECK (like_count >= 0),
    comment_count INTEGER NOT NULL DEFAULT 0 CHECK (comment_count >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE comments (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE post_likes (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (post_id, user_id)
);

CREATE TABLE recycling_spots (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    type VARCHAR(30) NOT NULL
        CHECK (type IN ('RECYCLING_CENTER', 'PUBLIC_TRASH_BIN')),
    region_sido VARCHAR(50) NOT NULL,
    region_sigungu VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    lat NUMERIC(9,6) NOT NULL CHECK (lat BETWEEN -90 AND 90),
    lng NUMERIC(10,6) NOT NULL CHECK (lng BETWEEN -180 AND 180),
    description TEXT,
    source VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notices (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE VIEW user_activity_summary AS
SELECT
    u.id AS user_id,
    COUNT(ps.id) AS total_plogging_count,
    COALESCE(SUM(ps.distance_meter), 0)::BIGINT AS total_distance_meter,
    COALESCE(SUM(ps.duration_seconds), 0)::BIGINT AS total_duration_seconds,
    COALESCE(SUM(ps.trash_certification_count), 0)::BIGINT
        AS total_trash_certification_count
FROM users u
LEFT JOIN plogging_sessions ps
    ON ps.user_id = u.id
    AND ps.status = 'COMPLETED'
GROUP BY u.id;

CREATE INDEX idx_users_region
    ON users (region_sido, region_sigungu);

CREATE INDEX idx_group_events_region
    ON group_events (region_sido, region_sigungu);
CREATE INDEX idx_group_events_start_at
    ON group_events (start_at);
CREATE INDEX idx_group_events_location
    ON group_events (lat, lng);

CREATE INDEX idx_plogging_sessions_user_created
    ON plogging_sessions (user_id, created_at DESC);
CREATE INDEX idx_plogging_sessions_start_at
    ON plogging_sessions (start_at);

CREATE INDEX idx_plogging_routes_session_recorded
    ON plogging_routes (session_id, recorded_at);

CREATE INDEX idx_trash_records_session_created
    ON trash_records (session_id, created_at);
CREATE INDEX idx_trash_records_location
    ON trash_records (lat, lng);

CREATE INDEX idx_group_participants_user
    ON group_participants (user_id, joined_at DESC);

CREATE INDEX idx_community_posts_created
    ON community_posts (created_at DESC);
CREATE INDEX idx_community_posts_category_created
    ON community_posts (category, created_at DESC);
CREATE INDEX idx_community_posts_region
    ON community_posts (region_sido, region_sigungu);

CREATE INDEX idx_comments_post_created
    ON comments (post_id, created_at);

CREATE INDEX idx_recycling_spots_region
    ON recycling_spots (region_sido, region_sigungu);
CREATE INDEX idx_recycling_spots_location
    ON recycling_spots (lat, lng);
```

## 8. 데이터 수집 정책

- 위치정보는 플로깅 기록, 쓰레기 인증, 단체 행사 장소, 지도 기능 제공에 필요한 경우에만 수집한다.
- 다른 사용자의 실시간 위치와 실시간 이동 경로는 저장 목적 외에 공개하지 않는다.
- 커뮤니티 게시글에는 정확한 좌표를 노출하지 않고 선택된 `region_sido`, `region_sigungu` 수준만 공개한다.
- 쓰레기 인증은 사진을 필수로 하며 종류, 개수, 무게, 메모는 선택적으로 수집한다.
- 단체 행사 지역, 활동 일시, 참여 인원, 장소는 가능한 한 구조화된 필드로 저장한다.
- 사용자 탈퇴와 콘텐츠 삭제 정책은 소프트 삭제 및 법적 보존 요구사항을 함께 고려한다.
- 공개 지도 응답은 사용자 식별 정보와 세션 전체 이동 경로를 포함하지 않는다.

## 9. 백엔드 구현 시 주의점

- 단체 행사 참여는 트랜잭션 안에서 행사 행을 잠그고 정원, 상태, 모집 마감을 다시 확인해야 한다.
- 동시 참여 요청으로 `current_participants`가 `max_participants`를 초과하지 않도록 비관적 잠금 또는 원자적 업데이트를 사용한다.
- 단체 행사 상태와 현재 참여 인원은 클라이언트 입력을 신뢰하지 않고 서버에서 계산한다.
- MVP에서 단체 행사 생성 시 `recruit_deadline_at`은 서버가 `start_at`과 동일하게 설정한다.
- 비밀번호는 BCrypt, Argon2 등 검증된 해시 알고리즘으로 처리하고 평문을 저장하거나 로그에 남기지 않는다.
- 프론트엔드에서 검증한 입력도 백엔드에서 길이, 형식, 권한, 상태 전이를 다시 검증한다.
- 쓰레기 인증의 `user_id`는 JWT 사용자와 세션 소유자가 일치하는지 확인한다.
- 게시글의 연결 세션은 작성자 본인의 접근 가능한 세션인지 검증한다.
- `like_count`, `comment_count`, `trash_certification_count`, `current_participants` 갱신은 트랜잭션으로 일관성을 보장한다.
- 이미지 업로드는 향후 별도 저장소와 업로드 API로 분리하고, 데이터베이스에는 검증된 URL 또는 저장 키만 보관한다.
- `updated_at` 자동 갱신은 애플리케이션 감사 기능 또는 PostgreSQL 트리거 중 하나로 일관되게 처리한다.
- 운영 환경에서는 시간대 정책을 확정하고 필요하면 `TIMESTAMP WITH TIME ZONE` 사용을 검토한다.
