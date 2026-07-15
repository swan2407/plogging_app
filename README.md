# 플로깅 환경 활동 플랫폼

> 개인 플로깅 기록, 단체 플로깅 모집, 쓰레기 인증, 커뮤니티 공유, 마이페이지 통계를 하나의 흐름으로 연결한 Flutter + Spring Boot MVP 프로젝트입니다.

현재 프로젝트는 **Flutter 프론트엔드 MVP**, **Spring Boot 백엔드 API**, **PostgreSQL Flyway 마이그레이션**, **Docker 기반 PostgreSQL/pgAdmin 검증 환경**까지 연결한 상태입니다. 

## 1. 프로젝트 소개

플로깅은 걷거나 달리면서 쓰레기를 수거하는 환경 활동입니다. 이 프로젝트는 사용자가 개인 활동을 저장하고, 단체 플로깅을 모집하거나 참여하고, 활동 결과를 커뮤니티에 공유하며, 마이페이지에서 누적 활동 통계를 확인할 수 있도록 설계했습니다.

단순한 화면 구현에 그치지 않고, 활동 데이터가 PostgreSQL에 저장되고 pgAdmin에서 검증 가능하도록 백엔드와 데이터베이스를 연결했습니다.

## 2. 문제 정의

- 플로깅은 이동 중에 이루어지므로 매번 상세 정보를 입력하면 사용자 부담이 커집니다.
- 단체 플로깅 모집 정보가 흩어지면 참여자 관리와 활동 기록 축적이 어렵습니다.
- 활동 결과가 데이터베이스에 남지 않으면 마이페이지 통계, 커뮤니티 공유, 지역별 분석으로 확장하기 어렵습니다.

따라서 MVP에서는 **입력은 단순하게 유지하되, 저장되는 데이터는 구조화된 형태로 관리하는 것**을 핵심 목표로 잡았습니다.

## 3. 구현 상태

### 구현 완료

- Flutter 프론트엔드 MVP 화면 및 주요 사용자 흐름
- Spring Boot 백엔드 프로젝트와 REST API 구현
- PostgreSQL Docker Compose 환경
- pgAdmin을 통한 DB 테이블 및 데이터 검증
- 회원가입/로그인 API
- BCrypt 기반 비밀번호 해시 저장
- 필수 약관 동의 내역 저장
- 단체 플로깅 생성, 목록, 상세, 참여 API
- 개인 플로깅 결과 저장 API
- 쓰레기 인증 기록 저장 API
- mock `imageUrl` 기반 쓰레기 기록 저장
- 마이페이지 활동 기록 백엔드 조회
- PostgreSQL View `user_activity_summary` 기반 마이페이지 통계
- 커뮤니티 게시글, 댓글, 좋아요 API
- Flutter 커뮤니티 게시글 목록/상세/작성/댓글/좋아요 토글 연동
- PostgreSQL 컨테이너 `localhost:5433` 노출
- pgAdmin에서 `users`, `plogging_sessions`, `community_posts` 등 주요 테이블 검증 가능

### 부분 구현 / MVP

- 인증은 운영 JWT가 아니라 `dev-token-{userId}` 형식의 MVP 토큰을 사용합니다.
- Flutter 토큰 저장은 보안 저장소가 아닌 인메모리 상태입니다.
- 커뮤니티 좋아요 여부는 백엔드 응답에 `likedByMe`가 없어 Flutter 인메모리 Set으로 MVP 처리합니다.
- 개인 플로깅 화면은 실제 GPS 경로 추적 없이 MVP 결과 데이터를 저장합니다.
- 쓰레기 사진 인증은 실제 업로드 없이 mock `imageUrl` 문자열을 저장합니다.
- 지도 화면은 실제 지도 SDK가 아니라 mock 마커와 레이어 토글 중심입니다.
- 마이페이지 통계와 활동 기록은 백엔드와 연결되어 있지만, 가입한 단체 목록과 내 게시글 일부 영역은 mock 데이터가 남아 있습니다.

### 향후 구현 예정

- production JWT / refresh token
- 보안 저장소 기반 토큰 저장
- 실제 이미지 업로드 및 파일 저장 서버
- 실제 GPS route tracking
- 실제 map API 연동
- 위치 기반 추천 및 지도 데이터 고도화
- phone verification
- Kakao login
- 관리자 기능 및 커뮤니티 moderation
- production deployment
- app store release

## 4. 주요 기능

### 인증

- 회원가입 시 아이디, 비밀번호, 닉네임, 지역, 약관 동의 정보를 입력합니다.
- 백엔드는 비밀번호를 BCrypt로 해시한 뒤 `users.password_hash`에 저장합니다.
- 약관 동의 내역은 `terms_agreements` 테이블에 저장됩니다.
- 로그인 성공 시 MVP 토큰 `dev-token-{userId}`를 반환합니다.

### 단체 플로깅

- 사용자는 단체 플로깅을 생성하고, 목록과 상세를 조회하고, 모집 중인 활동에 참여할 수 있습니다.
- 생성 폼은 지역, 날짜, 시간, 인원, 장소, 설명을 구조화된 입력으로 받습니다.
- 백엔드는 모집 마감 시간이 활동 시작 시간 이후가 되지 않도록 검증합니다.
- 참여 시 중복 참여, 모집 마감, 정원 초과를 검증합니다.

### 개인 플로깅과 쓰레기 인증

- 플로깅 결과 화면에서 활동 시간, 이동 거리, 지역, 쓰레기 인증 수를 백엔드에 저장합니다.
- 쓰레기 인증 기록은 세션과 연결되어 `trash_records`에 저장됩니다.
- 현재 이미지는 실제 업로드가 아니라 mock `imageUrl` 문자열로 저장합니다.

### 마이페이지

- 내 활동 기록은 `GET /api/plogging/sessions/me`로 백엔드에서 조회합니다.
- 누적 통계는 PostgreSQL View `user_activity_summary`를 통해 계산합니다.
- View는 완료된 플로깅 세션 기준으로 총 활동 횟수, 총 이동 거리, 총 활동 시간, 총 쓰레기 인증 수를 제공합니다.

### 커뮤니티

- 게시글 목록, 상세, 작성, 수정, 삭제, 댓글, 좋아요 API가 구현되어 있습니다.
- Flutter 커뮤니티 화면은 백엔드 게시글을 불러오고, 실패 시 MVP mock fallback을 표시합니다.
- 좋아요 버튼은 `POST /likes`와 `DELETE /likes`를 사용해 토글로 동작합니다.
- 중복 좋아요 응답은 사용자에게 그대로 노출하지 않고 취소 흐름으로 처리합니다.

## 5. 설계 의사결정

### 사진 우선 쓰레기 인증

쓰레기 종류, 개수, 무게를 모두 필수로 입력하게 하면 플로깅 중 사용자의 흐름이 자주 끊깁니다. 그래서 MVP에서는 **사진 인증을 중심에 두고 상세 정보는 선택 입력**으로 설계했습니다. 사용자의 입력 부담을 줄이면서도 향후 이미지 분류나 인증 검수 기능으로 확장할 수 있습니다.

### 구조화된 단체 플로깅 생성 폼

단체 플로깅 생성 정보를 자유 입력에 맡기면 날짜, 지역, 인원 데이터가 불안정해져 검색과 검증이 어려워집니다. 따라서 지역 선택, 날짜/시간 입력, 인원 제한, 장소명, 설명을 구조화해 백엔드와 DB가 검증 가능한 데이터를 받도록 했습니다.

### 모집 마감 검증

모집 마감 시간이 활동 시작 이후로 설정되면 모집 상태가 비정상적으로 유지될 수 있습니다. 백엔드와 DB 제약조건에서 `recruit_deadline_at <= start_at`을 검증해 잘못된 이벤트 상태를 방지했습니다.

### 지도 레이어 토글

단체 플로깅, 쓰레기 기록, 분리수거장, 공공 쓰레기통을 한 화면에 모두 표시하면 시각적 복잡도가 커집니다. MVP 지도 화면은 필요한 정보만 켜고 끌 수 있는 레이어 토글 방식으로 설계했습니다.

### PostgreSQL View 기반 통계

마이페이지 통계는 매번 애플리케이션 코드에서 복잡하게 계산하기보다 PostgreSQL View `user_activity_summary`로 분리했습니다. 실제 화면 요구사항과 직접 연결되는 DB 기능을 사용해 데이터 조회 책임을 명확히 했습니다.

### Docker Compose 기반 로컬 DB

개발자마다 PostgreSQL 설치 방식과 버전이 달라지는 문제를 줄이기 위해 Docker Compose로 PostgreSQL과 pgAdmin을 함께 구성했습니다. 로컬 PC에서는 `localhost:5433`, Docker 네트워크 내부에서는 `postgres:5432`로 접근합니다.

### mock-first 이후 백엔드 통합

초기에는 Flutter mock 화면으로 사용자 흐름을 빠르게 검증했고, 이후 Spring Boot API와 PostgreSQL 저장 흐름을 연결했습니다. 이 방식은 화면 구조를 먼저 안정화한 뒤 실제 데이터 저장과 검증을 붙이는 데 효과적이었습니다.

## 6. 기술 스택

| 구분 | 기술 | 적용 범위 |
|---|---|---|
| Frontend | Flutter, Dart | 화면, 상태, API 연동 |
| Backend | Spring Boot, Spring Data JPA, JdbcTemplate | REST API, 비즈니스 로직, View 조회 |
| Database | PostgreSQL 16 | Flyway 마이그레이션, 테이블, View |
| Migration | Flyway | V1~V5 DB schema 적용 |
| Auth | BCrypt, dev-token MVP | 비밀번호 해시, MVP 인증 |
| Infrastructure | Docker Compose | PostgreSQL, pgAdmin 로컬 실행 |
| Verification | pgAdmin | 테이블, View, 데이터 검증 |

## 7. 프로젝트 구조

```text
plogging/
├── frontend/              # Flutter 앱
├── backend/               # Spring Boot API 서버
├── docs/
│   ├── api/               # REST API 설계 문서
│   ├── database/          # PostgreSQL 스키마 설계 문서
│   ├── demo/              # 발표 및 시연 시나리오
│   ├── legal/             # 개인정보·위치정보·사진 인증 관련 문서
│   ├── design/            # 디자인 자료
│   └── planning/          # 서비스 기획 문서
└── infra/                 # PostgreSQL 및 pgAdmin Docker Compose
```

## 8. 실행 방법

### PostgreSQL 및 pgAdmin 실행

```bash
cd infra
docker compose up -d
```

PostgreSQL은 로컬 PC에서 `localhost:5433`으로 접근합니다.

기본 Docker Compose 접속 정보:

- Database: `plogging_db`
- User: `plogging_user`
- Password: `plogging_password`
- Local host: `localhost`
- Local port: `5433`

pgAdmin 접속 정보:

- URL: [http://localhost:5050](http://localhost:5050)
- Email: `admin@example.com`
- Password: `admin1234`

pgAdmin 서버 등록 정보:

- Host: `postgres`
- Port: `5432`
- Database: `plogging_db`
- Username: `plogging_user`
- Password: `plogging_password`

> 주의: 현재 `backend/src/main/resources/application.yml`의 DB 비밀번호가 Docker Compose 기본값과 다를 수 있습니다. 백엔드 실행 전 Docker `.env` 또는 `application.yml`의 비밀번호를 같은 값으로 맞춰야 합니다.

### Spring Boot 백엔드 실행

```bash
cd backend
./gradlew bootRun
```

Windows PowerShell:

```powershell
cd backend
.\gradlew.bat bootRun
```

백엔드가 실행되면 Flyway가 `V1`부터 `V5`까지 마이그레이션을 적용합니다.

### Flutter 앱 실행

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

정적 분석:

```bash
cd frontend
flutter analyze
```

## 9. pgAdmin 검증 쿼리

```sql
SELECT * FROM users ORDER BY id DESC;
SELECT * FROM terms_agreements ORDER BY agreed_at DESC;
SELECT * FROM group_events ORDER BY created_at DESC;
SELECT * FROM group_participants ORDER BY joined_at DESC;
SELECT * FROM plogging_sessions ORDER BY created_at DESC;
SELECT * FROM trash_records ORDER BY created_at DESC;
SELECT * FROM user_activity_summary ORDER BY user_id;
SELECT * FROM community_posts ORDER BY created_at DESC;
SELECT * FROM comments ORDER BY created_at DESC;
SELECT * FROM post_likes ORDER BY created_at DESC;
```


