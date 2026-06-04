# 플로깅 앱 MVP API 명세

본 문서는 향후 Spring Boot 백엔드와 PostgreSQL 데이터베이스 구현을 위한 REST API 계약 초안이다.

- 조회 및 목록 API는 가능한 범위에서 비회원에게 공개한다.
- 기록 생성, 단체 참여, 게시글 작성, 마이페이지 API는 로그인이 필요하다.
- MVP 인증은 JWT 기반으로 구현한다.
- 전화번호 인증은 MVP 필수 범위에 포함하지 않는다.
- 카카오 로그인은 향후 확장 기능으로 다룬다.

## 1. 공통 규칙

### 1.1 기본 정보

| 항목 | 규칙 |
|---|---|
| Base URL | `/api` |
| 인증 방식 | `Authorization: Bearer {accessToken}` |
| 요청/응답 형식 | `application/json` |
| 날짜 및 시간 | ISO-8601, 예: `2026-06-05T09:30:00+09:00` |
| 날짜 | ISO-8601, 예: `2026-06-05` |
| 좌표 | WGS84 기준 `lat`, `lng` |
| ID | 구현 시 `BIGINT` 또는 UUID 중 하나로 통일 |

### 1.2 인증 및 권한

- 공개 API는 인증 헤더 없이 호출할 수 있다.
- 로그인 필수 API는 유효한 access token이 필요하다.
- 수정 및 삭제 API는 작성자, 리더 또는 관리자 권한을 서버에서 검증한다.
- refresh token은 서버 저장 또는 안전한 쿠키 정책 중 하나를 선택해 구현한다.
- 로그아웃 시 refresh token을 폐기한다.

### 1.3 성공 응답 형식

```json
{
  "success": true,
  "data": {
    "id": 123
  }
}
```

목록 응답은 페이지 정보를 포함한다.

```json
{
  "success": true,
  "data": {
    "items": [],
    "page": 0,
    "size": 20,
    "totalElements": 0,
    "totalPages": 0
  }
}
```

생성 성공은 `201 Created`, 조회 및 수정 성공은 `200 OK`, 응답 본문이 없는 삭제 성공은 `204 No Content`를 권장한다.

### 1.4 오류 응답 형식

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "요청 값이 올바르지 않습니다.",
    "details": [
      {
        "field": "startAt",
        "reason": "시작 시간은 종료 시간보다 빨라야 합니다."
      }
    ]
  }
}
```

| HTTP 상태 | 대표 코드 | 의미 |
|---|---|---|
| `400` | `VALIDATION_ERROR` | 요청 값 또는 상태 전이 오류 |
| `401` | `UNAUTHORIZED` | 인증 필요 또는 토큰 만료 |
| `403` | `FORBIDDEN` | 소유권 또는 역할 권한 없음 |
| `404` | `RESOURCE_NOT_FOUND` | 대상 리소스 없음 |
| `409` | `DUPLICATE_RESOURCE` | 중복 아이디, 중복 참여 등 |
| `500` | `INTERNAL_SERVER_ERROR` | 서버 내부 오류 |

### 1.5 페이지 및 필터 규칙

- 기본 페이지 파라미터: `page=0&size=20`
- 정렬 예시: `sort=createdAt,desc`
- 목록 필터는 query parameter를 사용한다.
- 사용자 입력 문자열은 서버에서 길이와 허용 범위를 검증한다.

## 2. 인증 API

### 2.1 엔드포인트

| 단계 | Method | Endpoint | 목적 | 인증 |
|---|---|---|---|---|
| MVP | `POST` | `/api/auth/signup` | 일반 회원가입 | 공개 |
| MVP | `POST` | `/api/auth/login` | 로그인 및 JWT 발급 | 공개 |
| MVP | `POST` | `/api/auth/logout` | refresh token 폐기 | 로그인 |
| MVP | `POST` | `/api/auth/refresh` | access token 재발급 | refresh token |
| MVP | `GET` | `/api/users/me` | 현재 로그인 사용자 조회 | 로그인 |
| Future | `POST` | `/api/auth/kakao` | 카카오 로그인 | 공개 |

### 2.2 회원가입

`POST /api/auth/signup`

지역은 선택 입력이다. `agreements`에는 가입 시점에 동의한 약관 코드와 버전을 기록한다.

```json
{
  "loginId": "plogger01",
  "password": "StrongPassword123!",
  "nickname": "초록걸음",
  "regionSido": "경기도",
  "regionSigungu": "수원시",
  "agreements": [
    {
      "termsCode": "TERMS_OF_SERVICE",
      "version": "1.0",
      "agreed": true
    },
    {
      "termsCode": "PRIVACY_POLICY",
      "version": "1.0",
      "agreed": true
    }
  ]
}
```

```json
{
  "success": true,
  "data": {
    "userId": 101,
    "loginId": "plogger01",
    "nickname": "초록걸음",
    "accessToken": "jwt-access-token",
    "refreshToken": "jwt-refresh-token"
  }
}
```

### 2.3 로그인

`POST /api/auth/login`

```json
{
  "loginId": "plogger01",
  "password": "StrongPassword123!"
}
```

```json
{
  "success": true,
  "data": {
    "accessToken": "jwt-access-token",
    "refreshToken": "jwt-refresh-token",
    "expiresIn": 3600
  }
}
```

### 2.4 로그아웃 및 토큰 재발급

`POST /api/auth/logout`

- 현재 사용자의 refresh token을 폐기한다.
- 인증: 로그인 필수

`POST /api/auth/refresh`

```json
{
  "refreshToken": "jwt-refresh-token"
}
```

```json
{
  "success": true,
  "data": {
    "accessToken": "new-jwt-access-token",
    "refreshToken": "rotated-jwt-refresh-token",
    "expiresIn": 3600
  }
}
```

## 3. 약관 API

| 단계 | Method | Endpoint | 목적 | 인증 |
|---|---|---|---|---|
| MVP | `GET` | `/api/legal/terms` | 현재 적용 중인 약관 목록 및 내용 조회 | 공개 |
| MVP | `POST` | `/api/legal/agreements` | 로그인 사용자의 약관 동의 이력 저장 | 로그인 |

### 3.1 약관 목록 조회

`GET /api/legal/terms`

선택 query: `termsCode`, `version`

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "termsCode": "TERMS_OF_SERVICE",
        "title": "서비스 이용약관",
        "version": "1.0",
        "required": true,
        "content": "약관 본문",
        "effectiveAt": "2026-06-05T00:00:00+09:00"
      }
    ]
  }
}
```

### 3.2 약관 동의 저장

`POST /api/legal/agreements`

```json
{
  "agreements": [
    {
      "termsCode": "LOCATION_TERMS",
      "version": "1.0",
      "agreed": true
    }
  ]
}
```

## 4. 사용자 API

| 단계 | Method | Endpoint | 목적 | 인증 |
|---|---|---|---|---|
| MVP | `GET` | `/api/users/me` | 내 프로필 조회 | 로그인 |
| MVP | `PATCH` | `/api/users/me` | 내 프로필 수정 | 로그인 |
| MVP | `GET` | `/api/users/me/activities` | 내 플로깅 활동 기록 조회 | 로그인 |
| Phase 2 | `GET` | `/api/users/me/statistics` | 내 활동 통계 조회 | 로그인 |

### 4.1 내 프로필 조회 및 수정

`GET /api/users/me`

```json
{
  "success": true,
  "data": {
    "id": 101,
    "loginId": "plogger01",
    "nickname": "초록걸음",
    "regionSido": "경기도",
    "regionSigungu": "수원시",
    "profileImageUrl": null,
    "createdAt": "2026-06-05T09:00:00+09:00"
  }
}
```

`PATCH /api/users/me`

모든 필드는 선택 입력이며, 전달된 필드만 수정한다.

```json
{
  "nickname": "새로운닉네임",
  "regionSido": "서울특별시",
  "regionSigungu": "마포구",
  "profileImageUrl": "https://cdn.example.com/profiles/101.jpg"
}
```

### 4.2 내 활동 기록 및 통계

`GET /api/users/me/activities?page=0&size=20&type=PERSONAL`

- 개인 및 단체 플로깅 완료 기록을 조회한다.
- `type`: `PERSONAL`, `GROUP`

`GET /api/users/me/statistics`

- 마이페이지 요약 통계를 제공한다.
- Phase 2에서 `/api/statistics/me`와 응답 모델을 통합할 수 있다.

## 5. 개인 플로깅 API

개인 플로깅은 모든 API에서 로그인이 필요하다.

| 단계 | Method | Endpoint | 목적 | 인증 |
|---|---|---|---|---|
| MVP | `POST` | `/api/plogging/sessions` | 개인 플로깅 세션 시작 | 로그인 |
| MVP | `PATCH` | `/api/plogging/sessions/{sessionId}/pause` | 세션 일시정지 | 로그인 |
| MVP | `PATCH` | `/api/plogging/sessions/{sessionId}/resume` | 세션 재개 | 로그인 |
| MVP | `PATCH` | `/api/plogging/sessions/{sessionId}/finish` | 세션 종료 및 결과 확정 | 로그인 |
| MVP | `GET` | `/api/plogging/sessions/{sessionId}` | 내 세션 상세 조회 | 로그인 |
| MVP | `GET` | `/api/plogging/sessions/me` | 내 세션 목록 조회 | 로그인 |

세션 상태는 `IN_PROGRESS`, `PAUSED`, `COMPLETED`, `CANCELED`를 사용한다.

### 5.1 세션 시작

`POST /api/plogging/sessions`

```json
{
  "startedAt": "2026-06-05T09:30:00+09:00",
  "startLat": 37.2825,
  "startLng": 127.0435
}
```

```json
{
  "success": true,
  "data": {
    "sessionId": 5001,
    "type": "PERSONAL",
    "status": "IN_PROGRESS",
    "startedAt": "2026-06-05T09:30:00+09:00"
  }
}
```

### 5.2 세션 상태 변경

`PATCH /api/plogging/sessions/{sessionId}/pause`

`PATCH /api/plogging/sessions/{sessionId}/resume`

- 본인 소유 세션만 변경할 수 있다.
- 허용되지 않은 상태 전이는 `400 VALIDATION_ERROR`로 응답한다.

`PATCH /api/plogging/sessions/{sessionId}/finish`

```json
{
  "finishedAt": "2026-06-05T10:20:00+09:00",
  "endLat": 37.285,
  "endLng": 127.046,
  "distanceMeter": 3250,
  "durationSecond": 3000
}
```

```json
{
  "success": true,
  "data": {
    "sessionId": 5001,
    "status": "COMPLETED",
    "distanceMeter": 3250,
    "durationSecond": 3000,
    "trashRecordCount": 2
  }
}
```

### 5.3 세션 조회

`GET /api/plogging/sessions/{sessionId}`

- 로그인 사용자가 접근 가능한 세션 상세와 쓰레기 인증 요약을 조회한다.

`GET /api/plogging/sessions/me?page=0&size=20&status=COMPLETED`

- 내 개인 플로깅 세션 목록을 조회한다.

## 6. 쓰레기 인증 API

쓰레기 인증은 사진 우선 방식이다. `imageUrl`, `lat`, `lng`만 필수이며 종류, 개수, 무게, 메모는 선택 입력이다.

| 단계 | Method | Endpoint | 목적 | 인증 |
|---|---|---|---|---|
| MVP | `POST` | `/api/trash-records` | 진행 중인 세션에 쓰레기 사진 인증 등록 | 로그인 |
| MVP | `GET` | `/api/trash-records/session/{sessionId}` | 세션별 쓰레기 인증 조회 | 로그인 |
| Phase 2 | `GET` | `/api/trash-records/map` | 공개 가능한 쓰레기 인증 지도 조회 | 공개 |

### 6.1 쓰레기 인증 등록

`POST /api/trash-records`

```json
{
  "sessionId": 5001,
  "imageUrl": "https://cdn.example.com/trash/record-9001.jpg",
  "lat": 37.2831,
  "lng": 127.0441,
  "trashType": "PLASTIC",
  "count": 3,
  "weightGram": 120,
  "memo": "산책로 주변에서 수거"
}
```

```json
{
  "success": true,
  "data": {
    "id": 9001,
    "sessionId": 5001,
    "imageUrl": "https://cdn.example.com/trash/record-9001.jpg",
    "lat": 37.2831,
    "lng": 127.0441,
    "trashType": "PLASTIC",
    "count": 3,
    "weightGram": 120,
    "memo": "산책로 주변에서 수거",
    "createdAt": "2026-06-05T09:45:00+09:00"
  }
}
```

### 6.2 쓰레기 인증 조회

`GET /api/trash-records/session/{sessionId}`

- 본인 또는 접근 권한이 있는 세션의 인증 목록을 조회한다.

`GET /api/trash-records/map?minLat=37.1&maxLat=37.5&minLng=126.8&maxLng=127.2`

- 지도 영역 내 공개 가능한 인증 위치만 조회한다.
- 응답에는 작성자 개인정보와 정밀 활동 경로를 포함하지 않는다.

## 7. 단체 플로깅 API

단체 플로깅 목록과 상세는 공개한다. 생성, 참여, 참여 취소, 행사 취소, 내 목록 조회는 로그인이 필요하다.

| 단계 | Method | Endpoint | 목적 | 인증 |
|---|---|---|---|---|
| Phase 2 | `GET` | `/api/group-events` | 단체 플로깅 목록 조회 | 공개 |
| Phase 2 | `POST` | `/api/group-events` | 단체 플로깅 생성 | 로그인 |
| Phase 2 | `GET` | `/api/group-events/{eventId}` | 단체 플로깅 상세 조회 | 공개 |
| Phase 2 | `POST` | `/api/group-events/{eventId}/join` | 단체 플로깅 참여 | 로그인 |
| Phase 2 | `DELETE` | `/api/group-events/{eventId}/join` | 참여 취소 | 로그인 |
| Phase 2 | `PATCH` | `/api/group-events/{eventId}/cancel` | 리더의 행사 취소 | 로그인, 리더 |
| Phase 2 | `GET` | `/api/group-events/me/joined` | 내가 참여한 행사 조회 | 로그인 |
| Phase 2 | `GET` | `/api/group-events/me/created` | 내가 만든 행사 조회 | 로그인 |

### 7.1 목록 및 상세 조회

`GET /api/group-events?page=0&size=20&regionSido=경기도&regionSigungu=수원시&status=RECRUITING`

`GET /api/group-events/{eventId}`

단체 플로깅 상태는 `RECRUITING`, `CLOSED`, `IN_PROGRESS`, `COMPLETED`, `CANCELED`를 사용한다.

### 7.2 단체 플로깅 생성

`POST /api/group-events`

지역은 시도와 시군구로 구조화한다. 앱은 DatePicker와 TimePicker 결과를 결합해 `startAt`, `endAt`을 전송한다. 최대 참여 인원은 카운터 입력값을 전송한다.

```json
{
  "title": "광교호수공원 주말 플로깅",
  "regionSido": "경기도",
  "regionSigungu": "수원시",
  "startAt": "2026-06-13T09:00:00+09:00",
  "endAt": "2026-06-13T11:00:00+09:00",
  "maxParticipants": 20,
  "placeName": "광교호수공원 제1주차장",
  "address": "경기도 수원시 영통구 광교호수로 165",
  "lat": 37.2825,
  "lng": 127.065,
  "supplies": "장갑, 집게, 개인 물",
  "description": "호수공원 산책로를 함께 정리합니다."
}
```

다음 필드는 사용자 입력을 받지 않고 서버가 관리한다.

| 필드 | 서버 처리 |
|---|---|
| `leaderId` | JWT 인증 사용자 ID로 설정 |
| `currentParticipants` | 생성 시 리더 포함 정책에 따라 서버가 계산 |
| `status` | 시작 시점과 취소 여부에 따라 서버가 관리 |
| `recruitDeadline` | MVP에서는 `startAt`과 동일하게 자동 설정 |

```json
{
  "success": true,
  "data": {
    "id": 7001,
    "leaderId": 101,
    "currentParticipants": 1,
    "status": "RECRUITING",
    "recruitDeadline": "2026-06-13T09:00:00+09:00"
  }
}
```

### 7.3 참여 및 취소

`POST /api/group-events/{eventId}/join`

- 정원 초과, 모집 마감, 중복 참여를 서버에서 차단한다.

`DELETE /api/group-events/{eventId}/join`

- 로그인 사용자의 참여를 취소한다.

`PATCH /api/group-events/{eventId}/cancel`

```json
{
  "reason": "기상 악화"
}
```

- 행사 리더만 취소할 수 있다.

## 8. 커뮤니티 API

게시글과 댓글 조회는 공개한다. 작성, 수정, 삭제, 좋아요는 로그인이 필요하다.

| 단계 | Method | Endpoint | 목적 | 인증 |
|---|---|---|---|---|
| Phase 2 | `GET` | `/api/posts` | 게시글 목록 조회 | 공개 |
| Phase 2 | `POST` | `/api/posts` | 게시글 작성 | 로그인 |
| Phase 2 | `GET` | `/api/posts/{postId}` | 게시글 상세 조회 | 공개 |
| Phase 2 | `PATCH` | `/api/posts/{postId}` | 게시글 수정 | 로그인, 작성자 |
| Phase 2 | `DELETE` | `/api/posts/{postId}` | 게시글 삭제 | 로그인, 작성자 |
| Phase 2 | `POST` | `/api/posts/{postId}/likes` | 좋아요 등록 | 로그인 |
| Phase 2 | `DELETE` | `/api/posts/{postId}/likes` | 좋아요 취소 | 로그인 |
| Phase 2 | `GET` | `/api/posts/{postId}/comments` | 댓글 목록 조회 | 공개 |
| Phase 2 | `POST` | `/api/posts/{postId}/comments` | 댓글 작성 | 로그인 |
| Phase 2 | `DELETE` | `/api/comments/{commentId}` | 댓글 삭제 | 로그인, 작성자 |

### 8.1 게시글 목록 및 작성

`GET /api/posts?page=0&size=20&category=ACTIVITY_REVIEW&regionSido=경기도`

`POST /api/posts`

```json
{
  "category": "ACTIVITY_REVIEW",
  "title": "오늘 플로깅 후기",
  "content": "산책로 주변을 정리했습니다.",
  "imageUrls": [
    "https://cdn.example.com/posts/post-1.jpg"
  ],
  "regionSido": "경기도",
  "regionSigungu": "수원시",
  "sessionId": 5001
}
```

```json
{
  "success": true,
  "data": {
    "id": 8001,
    "author": {
      "id": 101,
      "nickname": "초록걸음"
    },
    "category": "ACTIVITY_REVIEW",
    "title": "오늘 플로깅 후기",
    "likeCount": 0,
    "commentCount": 0,
    "createdAt": "2026-06-05T11:00:00+09:00"
  }
}
```

### 8.2 게시글 수정 및 삭제

`GET /api/posts/{postId}`

`PATCH /api/posts/{postId}`

```json
{
  "title": "수정된 플로깅 후기",
  "content": "내용을 수정했습니다."
}
```

`DELETE /api/posts/{postId}`

- 작성자 또는 관리자만 수정 및 삭제할 수 있다.

### 8.3 좋아요 및 댓글

`POST /api/posts/{postId}/likes`

`DELETE /api/posts/{postId}/likes`

- 사용자별 게시글 좋아요는 하나만 허용한다.

`GET /api/posts/{postId}/comments?page=0&size=50`

`POST /api/posts/{postId}/comments`

```json
{
  "content": "좋은 활동이네요!"
}
```

`DELETE /api/comments/{commentId}`

- 댓글 작성자 또는 관리자만 삭제할 수 있다.

## 9. 지도 API

지도 화면은 레이어별 API를 독립적으로 호출한다. 사용자가 레이어를 켜면 해당 API를 호출하고, 끄면 지도에서 결과를 제거한다. 모든 API는 현재 지도 영역의 bounding box를 query parameter로 받는 방식을 권장한다.

| 단계 | Method | Endpoint | 목적 | 인증 |
|---|---|---|---|---|
| Phase 2 | `GET` | `/api/map/group-events` | 단체 플로깅 위치 레이어 | 공개 |
| Phase 2 | `GET` | `/api/map/trash-records` | 공개 쓰레기 인증 위치 레이어 | 공개 |
| Phase 2 | `GET` | `/api/map/recycling-spots` | 분리수거 장소 레이어 | 공개 |
| Phase 2 | `GET` | `/api/map/public-trash-bins` | 공공 쓰레기통 레이어 | 공개 |

공통 요청 예시:

```text
GET /api/map/group-events?minLat=37.1&maxLat=37.5&minLng=126.8&maxLng=127.2
```

공통 응답 예시:

```json
{
  "success": true,
  "data": {
    "layer": "GROUP_EVENTS",
    "items": [
      {
        "id": 7001,
        "name": "광교호수공원 주말 플로깅",
        "lat": 37.2825,
        "lng": 127.065,
        "summary": "2026-06-13 09:00, 모집 중"
      }
    ]
  }
}
```

- 쓰레기 인증 레이어는 개인정보와 사용자 이동 경로를 노출하지 않는다.
- 데이터가 많은 레이어는 지도 확대 수준 또는 클러스터링 기준을 적용한다.

## 10. 통계 API

| 단계 | Method | Endpoint | 목적 | 인증 |
|---|---|---|---|---|
| Phase 2 | `GET` | `/api/statistics/me` | 내 활동 상세 통계 | 로그인 |
| Future | `GET` | `/api/statistics/regions` | 지역별 공개 통계 | 공개 |
| Future | `GET` | `/api/statistics/trash-types` | 쓰레기 유형별 공개 통계 | 공개 |
| Future | `GET` | `/api/statistics/monthly` | 월별 공개 통계 | 공개 |

### 10.1 내 통계

`GET /api/statistics/me?from=2026-01-01&to=2026-06-30`

```json
{
  "success": true,
  "data": {
    "completedSessions": 12,
    "totalDistanceMeter": 48200,
    "totalDurationSecond": 39600,
    "trashRecordCount": 31,
    "estimatedWeightGram": 5200
  }
}
```

### 10.2 공개 통계

`GET /api/statistics/regions?from=2026-01-01&to=2026-06-30`

`GET /api/statistics/trash-types?from=2026-01-01&to=2026-06-30`

`GET /api/statistics/monthly?year=2026`

- 개인을 식별할 수 없는 집계 데이터만 반환한다.

## 11. 관리자 및 공지 API

공지 조회와 관리자 작성 기능은 Future 범위다. 관리자 API는 JWT의 관리자 역할을 검증해야 한다.

| 단계 | Method | Endpoint | 목적 | 인증 |
|---|---|---|---|---|
| Future | `GET` | `/api/notices` | 공지 목록 조회 | 공개 |
| Future | `POST` | `/api/notices` | 공지 작성 | 관리자 |
| Future | `PATCH` | `/api/notices/{noticeId}` | 공지 수정 | 관리자 |
| Future | `DELETE` | `/api/notices/{noticeId}` | 공지 삭제 | 관리자 |

공지 작성 예시:

```json
{
  "title": "서비스 점검 안내",
  "content": "점검 시간 동안 일부 기능 이용이 제한됩니다.",
  "publishedAt": "2026-06-10T09:00:00+09:00"
}
```

## 12. MVP 우선순위

### 12.1 MVP

백엔드 최초 구현 범위다.

- JWT 회원가입, 로그인, 로그아웃, 토큰 재발급
- 현재 사용자 프로필 조회 및 수정
- 약관 조회 및 동의 이력 저장
- 개인 플로깅 시작, 일시정지, 재개, 종료, 조회
- 사진 우선 쓰레기 인증 등록 및 세션별 조회
- 내 활동 기록 조회

### 12.2 Phase 2

핵심 MVP 이후 서비스 연결 범위다.

- 단체 플로깅 목록, 상세, 생성, 참여, 취소
- 커뮤니티 게시글, 댓글, 좋아요
- 지도 레이어 API
- 쓰레기 인증 지도 조회
- 내 활동 통계

### 12.3 Future

운영 및 확장 범위다.

- 카카오 로그인
- 지역별, 쓰레기 유형별, 월별 공개 통계
- 공지 및 관리자 기능
- 전화번호 인증
- 이미지 업로드 저장소 연동 고도화

## 13. 구현 시 주요 검증 규칙

- 회원가입 시 필수 약관 동의 여부와 약관 버전을 서버에서 검증한다.
- `regionSido`, `regionSigungu`는 사용자 프로필에서는 선택 입력이다.
- 개인 플로깅 세션은 로그인 사용자만 생성할 수 있으며 동시에 진행 가능한 세션 수를 제한한다.
- 쓰레기 인증은 본인의 진행 중인 세션에만 등록할 수 있다.
- 쓰레기 인증의 `imageUrl`, `lat`, `lng`는 필수다.
- 단체 플로깅의 `endAt`은 `startAt`보다 늦어야 한다.
- 단체 플로깅의 모집 마감은 MVP에서 `startAt`과 동일하게 서버가 설정한다.
- 단체 플로깅의 리더, 상태, 현재 참여 인원은 서버가 관리한다.
- 게시글 및 댓글 수정·삭제는 작성자 또는 관리자만 가능하다.
- 공개 지도와 통계 응답에는 개인 식별 정보와 정밀 이동 경로를 포함하지 않는다.
