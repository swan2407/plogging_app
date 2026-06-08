# 플로깅 MVP 데모 시나리오

이 문서는 포트폴리오 발표나 교수/면접관 시연을 위한 실습형 데모 스크립트입니다. 현재 프로젝트는 운영 배포 버전이 아니라 Flutter, Spring Boot, PostgreSQL, pgAdmin을 연결한 MVP입니다.

## 1. Demo Preparation

데모 전 확인할 항목:

- Docker Desktop 실행
- Flutter SDK 설치 및 Chrome 실행 가능
- Java와 Gradle Wrapper 실행 가능
- PostgreSQL 컨테이너 포트 `localhost:5433` 사용 가능
- pgAdmin 포트 `localhost:5050` 사용 가능
- 백엔드 DB 비밀번호와 Docker PostgreSQL 비밀번호 일치

주의 사항:

- 인증은 production JWT가 아니라 `dev-token-{userId}` MVP 방식입니다.
- 이미지는 실제 업로드가 아니라 mock `imageUrl` 문자열로 저장됩니다.
- GPS route tracking과 실제 지도 API는 아직 구현되지 않았습니다.
- Flutter Web/Chrome 기준으로 `http://localhost:8080` 백엔드에 접근합니다.

## 2. Required Commands

### 2.1 PostgreSQL 및 pgAdmin 실행

```powershell
cd infra
docker compose up -d
```

컨테이너 확인:

```powershell
docker ps
```

### 2.2 Spring Boot 백엔드 실행

```powershell
cd backend
.\gradlew.bat bootRun
```

macOS/Linux:

```bash
cd backend
./gradlew bootRun
```

### 2.3 Flutter 앱 실행

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

### 2.4 pgAdmin 접속

- URL: `http://localhost:5050`
- Email: `admin@example.com`
- Password: `admin1234`

pgAdmin 서버 등록:

- Host: `postgres`
- Port: `5432`
- Database: `plogging_db`
- Username: `plogging_user`
- Password: `plogging_password`

로컬 DB 클라이언트에서 직접 접속할 때:

- Host: `localhost`
- Port: `5433`

## 3. Demo Flow

### 1. PostgreSQL Docker 시작

`infra` 폴더에서 Docker Compose를 실행합니다.

```powershell
docker compose up -d
```

확인 포인트:

- `plogging-postgres` 컨테이너가 실행 중인지 확인합니다.
- `plogging-pgadmin` 컨테이너가 실행 중인지 확인합니다.

### 2. Spring Boot 백엔드 시작

`backend` 폴더에서 백엔드를 실행합니다.

```powershell
.\gradlew.bat bootRun
```

확인 포인트:

- 서버가 `8080` 포트에서 실행됩니다.
- Flyway가 `V1`부터 `V5`까지 마이그레이션을 적용합니다.
- `user_activity_summary` View가 생성됩니다.

### 3. Flutter 앱 시작

`frontend` 폴더에서 Flutter 앱을 Chrome으로 실행합니다.

```powershell
flutter run -d chrome
```

확인 포인트:

- 앱이 브라우저에서 열립니다.
- 로그인하지 않은 상태에서는 보호 기능 접근 시 로그인 화면으로 이동합니다.

### 4. 회원가입 또는 로그인

회원가입 화면에서 계정을 생성합니다.

확인 포인트:

- 비밀번호 조건 검증이 동작합니다.
- 필수 약관 동의 후 가입됩니다.
- 로그인 후 `dev-token-{userId}`가 Flutter 인메모리 상태에 저장됩니다.

pgAdmin에서 확인:

```sql
SELECT * FROM users ORDER BY id DESC;
SELECT * FROM terms_agreements ORDER BY agreed_at DESC;
```

### 5. 단체 플로깅 생성

단체 플로깅 화면에서 새 단체 플로깅을 생성합니다.

입력 예시:

- 제목: `수원천 주말 플로깅`
- 지역: `경기 수원시`
- 장소: `수원천 산책로`
- 모집 인원: `5`
- 설명: `주말 오전에 함께 쓰레기를 줍는 활동입니다.`

확인 포인트:

- 로그인 사용자만 생성할 수 있습니다.
- 날짜, 시간, 지역, 인원 데이터가 구조화되어 저장됩니다.
- 모집 마감 시간이 활동 시작 이후가 되지 않도록 검증됩니다.

### 6. `group_events` 확인

pgAdmin에서 생성된 단체 플로깅을 확인합니다.

```sql
SELECT * FROM group_events ORDER BY created_at DESC;
```

확인 포인트:

- `leader_id`가 로그인 사용자 id와 일치합니다.
- `status`가 `RECRUITING`입니다.
- `current_participants`는 MVP 정책에 따라 초기값으로 표시됩니다.

### 7. 단체 플로깅 참여

목록 또는 상세 화면에서 `참여하기`를 누릅니다.

확인 포인트:

- 로그인 사용자만 참여할 수 있습니다.
- 중복 참여는 백엔드에서 막습니다.
- 정원 초과와 모집 마감 상태를 검증합니다.

### 8. `group_participants` 확인

pgAdmin에서 참여 기록을 확인합니다.

```sql
SELECT * FROM group_participants ORDER BY joined_at DESC;
```

확인 포인트:

- `group_event_id`가 방금 생성한 이벤트와 연결됩니다.
- `user_id`가 참여한 사용자와 연결됩니다.
- `status`가 `JOINED`입니다.

### 9. 개인 플로깅 시작 및 종료

앱에서 개인 플로깅 화면으로 이동한 뒤 시작, 일시정지, 재개, 종료 흐름을 시연합니다.

확인 포인트:

- 현재 MVP는 실제 GPS route tracking이 아니라 화면 흐름과 결과 저장 중심입니다.
- 쓰레기 인증은 mock 입력과 mock 이미지 URL로 저장됩니다.

### 10. 활동 결과 저장

플로깅 결과 화면에서 활동 기록을 저장합니다.

확인 포인트:

- 로그인 사용자만 저장할 수 있습니다.
- 저장 성공 후 활동 기록이 마이페이지에서 조회됩니다.
- 저장된 session id를 커뮤니티 공유에 사용할 수 있습니다.

### 11. `plogging_sessions`, `trash_records` 확인

pgAdmin에서 활동 세션과 쓰레기 인증 기록을 확인합니다.

```sql
SELECT * FROM plogging_sessions ORDER BY created_at DESC;
SELECT * FROM trash_records ORDER BY created_at DESC;
```

확인 포인트:

- `plogging_sessions.user_id`가 로그인 사용자와 연결됩니다.
- `status`가 `COMPLETED`입니다.
- `trash_records.session_id`가 저장된 세션 id와 연결됩니다.
- `trash_records.image_url`은 mock 문자열입니다.

### 12. 마이페이지 열기

마이페이지로 이동해 활동 기록과 통계를 확인합니다.

확인 포인트:

- 활동 기록은 백엔드의 내 플로깅 세션 목록에서 조회됩니다.
- 총 플로깅 횟수, 이동 거리, 활동 시간, 쓰레기 인증 수가 표시됩니다.
- 통계 조회 실패 시 기존 MVP fallback이 표시될 수 있습니다.

### 13. `user_activity_summary` 통계 확인

pgAdmin에서 View 결과를 확인합니다.

```sql
SELECT * FROM user_activity_summary ORDER BY user_id;
```

확인 포인트:

- 방금 저장한 완료 세션이 `total_plogging_count`에 반영됩니다.
- `total_distance_meter`, `total_duration_seconds`, `total_trash_certification_count`가 합산됩니다.
- 완료 상태인 세션만 통계에 포함됩니다.

### 14. 커뮤니티 게시글 작성

커뮤니티 화면에서 글쓰기를 누르거나 플로깅 결과 화면에서 `커뮤니티에 공유하기`를 선택합니다.

입력 예시:

- 카테고리: `활동 후기`
- 제목: `오늘 플로깅 완료`
- 내용: `수원천에서 플로깅을 진행했고 쓰레기 인증을 남겼습니다.`
- 지역: `경기 수원시`

확인 포인트:

- 로그인 사용자만 작성할 수 있습니다.
- Flutter의 한국어 카테고리는 백엔드 값으로 변환됩니다.
- 활동 결과에서 공유한 경우 `session_id`가 게시글과 연결될 수 있습니다.

### 15. 댓글 추가

게시글 상세 화면으로 이동해 댓글을 작성합니다.

확인 포인트:

- 댓글 목록이 `GET /api/posts/{postId}/comments`로 조회됩니다.
- 댓글 작성은 `POST /api/posts/{postId}/comments`로 저장됩니다.
- 작성 후 댓글 수가 갱신됩니다.

### 16. 좋아요 토글

게시글 목록 또는 상세 화면에서 좋아요 버튼을 여러 번 누릅니다.

확인 포인트:

- 첫 클릭은 `POST /likes`로 좋아요를 추가합니다.
- 두 번째 클릭은 `DELETE /likes`로 좋아요를 취소합니다.
- 중복 좋아요 에러는 사용자에게 그대로 노출되지 않습니다.
- 현재 좋아요 여부는 MVP 범위에서 Flutter 인메모리 Set으로 관리됩니다.

### 17. 커뮤니티 테이블 확인

pgAdmin에서 게시글, 댓글, 좋아요 데이터를 확인합니다.

```sql
SELECT * FROM community_posts ORDER BY created_at DESC;
SELECT * FROM comments ORDER BY created_at DESC;
SELECT * FROM post_likes ORDER BY created_at DESC;
```

확인 포인트:

- `community_posts.user_id`가 작성자와 연결됩니다.
- `community_posts.session_id`가 공유된 플로깅 세션과 연결될 수 있습니다.
- 댓글 작성 후 `comment_count`가 증가합니다.
- 좋아요 추가/취소에 따라 `post_likes`와 `like_count`가 변경됩니다.

## 4. pgAdmin Verification Queries

데모 중 또는 데모 후 전체 데이터 상태를 빠르게 확인할 때 사용합니다.

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

특정 사용자 기준으로 확인할 때:

```sql
SELECT * FROM user_activity_summary WHERE user_id = 1;
SELECT * FROM plogging_sessions WHERE user_id = 1 ORDER BY created_at DESC;
SELECT * FROM community_posts WHERE user_id = 1 ORDER BY created_at DESC;
```

## 5. Troubleshooting

### 백엔드가 DB에 연결되지 않는 경우

확인할 항목:

- Docker PostgreSQL 컨테이너가 실행 중인지 확인합니다.
- `localhost:5433` 포트가 열려 있는지 확인합니다.
- Docker Compose의 `POSTGRES_PASSWORD`와 `backend/src/main/resources/application.yml`의 DB password가 같은지 확인합니다.

### Flyway 마이그레이션이 적용되지 않는 경우

확인할 항목:

- 백엔드 로그에서 Flyway 실행 여부를 확인합니다.
- 기존 Docker volume에 오래된 DB 상태가 남아 있을 수 있습니다.
- 데모용 초기화가 필요하면 Docker volume 삭제가 필요하지만, 이 작업은 기존 데이터를 제거하므로 신중히 수행합니다.

### Flutter에서 API 호출이 실패하는 경우

확인할 항목:

- Spring Boot 서버가 `http://localhost:8080`에서 실행 중인지 확인합니다.
- Flutter Web/Chrome 기준으로 실행했는지 확인합니다.
- Android Emulator에서 실행할 경우 `localhost` 대신 `10.0.2.2` 설정이 필요할 수 있습니다.

### 로그인이 필요한 기능이 동작하지 않는 경우

확인할 항목:

- 먼저 회원가입 또는 로그인을 완료했는지 확인합니다.
- Flutter 인메모리 인증 상태가 초기화되었을 수 있으므로 새로고침 후 다시 로그인합니다.
- 현재 인증 방식은 운영 JWT가 아니라 MVP용 `dev-token-{userId}`입니다.

### 좋아요 상태가 새로고침 후 달라 보이는 경우

현재 백엔드 게시글 응답에는 `likedByMe`가 없습니다. 따라서 Flutter는 앱 실행 중 인메모리 Set으로 좋아요 여부를 관리합니다. DB의 `post_likes`와 `like_count`는 저장되지만, 새로고침 후 개별 사용자의 좋아요 여부 표시는 MVP 한계가 있습니다.

### pgAdmin에서 PostgreSQL 서버 연결이 안 되는 경우

pgAdmin은 Docker Compose 네트워크 내부에서 실행되므로 Host에 `localhost`가 아니라 `postgres`를 입력해야 합니다.

로컬 PC에서 DBeaver, psql 등으로 접속할 때만 `localhost:5433`을 사용합니다.
