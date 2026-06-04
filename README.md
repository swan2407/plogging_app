# 플로깅 환경 활동 플랫폼

> 개인·단체 플로깅 활동을 간편하게 기록하고 공유하며, 위치·인증·커뮤니티·통계 데이터를 연결하기 위한 Flutter 기반 mock MVP입니다.

현재 프로젝트는 **Flutter 사용자 흐름 검증**, **REST API 및 PostgreSQL 스키마 설계**, **Docker 기반 로컬 PostgreSQL 환경 구성**까지 완료한 상태입니다. Spring Boot 백엔드, 실제 지도, 이미지 업로드, API 연동은 향후 구현 예정입니다.

## 1. 프로젝트 소개

플로깅 활동은 걷거나 달리면서 쓰레기를 수거하는 환경 활동입니다. 이 프로젝트는 개인 활동 기록뿐 아니라 단체 플로깅 모집, 쓰레기 사진 인증, 지역 기반 지도 정보, 커뮤니티 공유, 활동 통계까지 하나의 흐름으로 연결하는 것을 목표로 합니다.

단순히 운동 결과를 저장하는 앱이 아니라, 사용자는 활동을 쉽게 기록하고 시스템은 향후 분석 가능한 구조화 데이터를 축적할 수 있도록 설계했습니다.

## 2. 개발 배경과 문제 정의

- 플로깅 활동은 이동 중에 이루어지므로 매번 상세 내용을 기록하고 인증하기가 번거롭습니다.
- 단체 플로깅 모집 정보는 여러 채널에 흩어져 있어 참여자를 찾기 어렵고, 활동 결과를 데이터로 남기기도 어렵습니다.
- 수거된 쓰레기 정보를 지역별로 축적하면 개인 기록을 넘어 환경 활동 통계와 지역 문제 분석으로 확장할 수 있습니다.

이 문제를 해결하기 위해 **사용자 입력 과정은 단순하게 유지하면서도, 날짜·시간·지역·인원·활동 결과는 구조화된 형태로 수집하는 서비스**를 설계했습니다.

## 3. 핵심 설계 방향

- 목록과 상세 조회는 비회원도 이용할 수 있도록 설계했습니다.
- 활동 기록, 단체 참여, 게시글 작성 등 데이터 변경 기능은 로그인이 필요하도록 구분했습니다.
- 쓰레기 등록은 사진 인증을 중심으로 하고, 종류·개수·무게는 선택 입력으로 설계했습니다.
- 단체 플로깅 생성은 자유 입력보다 지역 선택, DatePicker, TimePicker, 인원 counter 등 구조화된 입력을 우선했습니다.
- 지도는 단체 모임, 쓰레기 기록, 분리수거장, 공공 쓰레기통을 레이어 단위로 켜고 끌 수 있도록 설계했습니다.
- 다른 사용자의 실시간 위치와 전체 이동 경로는 공개하지 않는 방향으로 설계했습니다.
- 먼저 mock 데이터로 화면과 사용자 흐름을 검증한 뒤 백엔드와 실제 외부 서비스를 연결하는 **mock-first 방식**을 선택했습니다.

## 4. 주요 기능

아래 기능은 현재 Flutter mock MVP에서 화면과 인메모리 상태 변경 흐름으로 구현되어 있습니다. 실제 서버 저장, GPS, 지도 SDK, 이미지 업로드는 아직 연결되지 않았습니다.

### 현재 구현 완료: Flutter Mock MVP

- 홈 화면과 주요 기능 진입 흐름
- 로그인·회원가입 mock 및 로그인 필요 기능 가드
- 비밀번호 조건 실시간 검증
- 필수 약관 동의, 약관 문서 보기, 만 14세 미만 보호자 동의 입력
- 시/도 및 시/군/구 기반 지역 선택
- 개인 플로깅 시작·일시정지·재개·종료 흐름
- 쓰레기 사진 인증 등록을 가정한 mock 입력 흐름
- 플로깅 종료 결과 요약
- 활동 기록 인메모리 저장 및 마이페이지 기록·통계 mock
- 커뮤니티 글쓰기 및 활동 결과 공유 mock
- 단체 플로깅 목록·상세·참여·생성 mock
- 지도 레이어 토글 및 mock 마커 필터링

### 설계·문서화 완료

- Spring Boot 연동을 위한 REST API 계약 초안
- PostgreSQL 테이블, 관계, 제약조건, 인덱스, View 설계
- 개인정보처리방침, 위치기반 서비스 이용약관, 사진 인증 정책 등 법률 문서 초안
- Docker Compose 기반 로컬 PostgreSQL 실행 환경

### 향후 구현 예정

- Spring Boot 백엔드와 JWT 인증
- Flutter와 실제 REST API 연동
- 실제 GPS·지도 API와 위치 기반 기능
- 이미지 선택·업로드·저장 서버
- PostgreSQL 애플리케이션 스키마 마이그레이션과 데이터 영속화

## 5. 나만의 개선점과 의사결정

### A. 쓰레기 등록 UX 개선

초기에는 쓰레기 종류와 개수를 필수 입력으로 받을 수 있었지만, 플로깅 중 사용자가 쓰레기를 수거할 때마다 상세 정보를 입력하면 활동 흐름이 자주 끊긴다고 판단했습니다.

그래서 **사진 인증을 중심으로 두고 종류·개수·무게는 선택 입력**으로 변경했습니다. 사용자 부담을 줄이면서도, 향후 사진 데이터를 AI 이미지 분류와 연결해 입력을 자동화할 수 있는 구조를 고려했습니다.

### B. 단체 플로깅 데이터 품질 개선

날짜, 시간, 인원, 지역을 모두 자유 입력으로 받으면 오타와 표현 차이 때문에 검색, 정렬, 필터링, 통계 처리가 어려워질 수 있습니다.

이를 줄이기 위해 지역은 **시/도-시/군/구 선택**, 날짜는 **DatePicker**, 시간은 **TimePicker**, 인원은 **counter 방식**으로 설계했습니다. 결과적으로 사용자 입력 편의성을 유지하면서 백엔드와 데이터베이스가 처리하기 쉬운 데이터를 만들 수 있습니다.

### C. 모집 마감 시간 자동화

모집 마감 시간을 사용자가 직접 입력하면 활동 시작 이후에도 모집이 열려 있는 비정상 데이터가 생길 수 있다고 판단했습니다.

API·DB 설계에서는 MVP 정책으로 **모집 마감 시간을 활동 시작 시간과 동일하게 서버에서 자동 설정**하도록 정의했습니다. 이를 통해 생성 폼을 단순화하고 데이터 정합성을 높이는 방향을 선택했습니다.

### D. 지도 레이어 토글

단체 모임, 쓰레기 기록, 분리수거장, 공공 쓰레기통을 한 지도에 동시에 표시하면 정보가 겹쳐 가독성이 낮아질 수 있습니다.

그래서 사용자가 필요한 정보만 선택할 수 있도록 **지도 레이어 토글 방식**을 적용했습니다. 새로운 위치 데이터가 추가되어도 레이어 단위로 확장할 수 있습니다.

### E. 개인정보·위치정보 보호

플로깅 앱은 위치와 이동 경로를 다루기 때문에 기능 설계 단계부터 공개 범위를 제한했습니다.

다른 사용자의 실시간 위치는 공개하지 않고, 커뮤니티 공유 시에도 정확한 좌표 대신 지역 단위 정보만 사용하는 방향을 잡았습니다. 이를 통해 서비스 확장 시 발생할 수 있는 개인정보와 위치정보 노출 위험을 줄이고자 했습니다.

### F. View 선택 이유

데이터베이스 고급 기능을 보여주기 위해 Trigger나 ROLLUP을 억지로 추가하기보다, 실제 마이페이지 통계 화면에 자연스럽게 필요한 **`user_activity_summary` View**를 설계했습니다.

이 View는 사용자별 총 활동 횟수, 이동 거리, 활동 시간, 쓰레기 인증 수를 조회하는 용도로 정의했습니다. 기술 요소가 실제 서비스 화면과 직접 연결되도록 설계한 선택입니다. 현재는 스키마 문서에 정의된 단계이며 실제 DB에는 아직 적용되지 않았습니다.

### G. Docker 기반 PostgreSQL 환경

개발자마다 PostgreSQL 설치 방식과 버전이 달라지는 문제를 줄이기 위해 Docker Compose로 로컬 데이터베이스 환경을 구성했습니다.

`plogging_db`와 `plogging_user`를 사용해 PostgreSQL 컨테이너 실행과 접속을 확인했습니다. 현재 실제 애플리케이션 스키마 대신 초기 연결 확인용 `health_check` 테이블만 생성되며, 향후 Spring Boot 마이그레이션을 적용할 예정입니다.

## 6. 기술 스택

| 구분 | 기술 | 현재 적용 범위 |
|---|---|---|
| Frontend | Flutter, Dart | mock MVP 구현 완료 |
| Database | PostgreSQL 16 | Docker 로컬 실행 환경 및 스키마 설계 완료 |
| Infrastructure | Docker Compose | PostgreSQL 로컬 환경 구성 완료 |
| Backend | Spring Boot | 향후 구현 예정 |
| Authentication | JWT | API 설계 완료, 구현 예정 |
| Development | VS Code, Codex CLI | 개발 및 문서화 도구 |

## 7. 프로젝트 구조

```text
plogging/
├── frontend/              # Flutter mock MVP
├── backend/               # Spring Boot 백엔드 구현 예정
├── docs/
│   ├── api/               # REST API 계약 초안
│   ├── database/          # PostgreSQL 스키마 및 DDL 초안
│   ├── legal/             # 개인정보·위치정보·사진 인증 관련 법률 문서 초안
│   ├── design/            # 디자인 시스템 자료
│   └── planning/          # 서비스 기획 및 설계 문서
└── infra/                 # PostgreSQL 및 pgAdmin Docker Compose 구성 파일
```

## 8. 실행 방법

### Flutter Mock MVP

Flutter SDK와 Chrome 실행 환경이 필요합니다.

```bash
cd frontend
flutter pub get
flutter analyze
flutter run -d chrome
```

### PostgreSQL Docker 환경

Docker와 Docker Compose가 필요합니다.

```bash
cd infra
docker compose up -d
docker ps
docker exec -it plogging-postgres psql -U plogging_user -d plogging_db
docker compose down
```

PostgreSQL 기본 접속 정보:

- Database: `plogging_db`
- User: `plogging_user`
- Password: `plogging_password`
- Local host: `localhost`
- Local host port: `5433`

Docker PostgreSQL은 네이티브 PostgreSQL의 기본 포트 `5432`와 충돌하지 않도록 로컬 PC의 `localhost:5433`에 노출됩니다. Docker Compose 네트워크 내부에서는 PostgreSQL 서비스가 계속 `postgres:5432`를 사용합니다.

### pgAdmin 접속 및 PostgreSQL 서버 등록

Docker Compose 실행 후 브라우저에서 pgAdmin에 접속할 수 있습니다.

- URL: [http://localhost:5050](http://localhost:5050)
- Email: `admin@example.com`
- Password: `admin1234`

pgAdmin에서 PostgreSQL 서버를 등록할 때 다음 정보를 사용합니다.

- Host: `postgres`
- Port: `5432`
- Database: `plogging_db`
- Username: `plogging_user`
- Password: `plogging_password`

> Docker Compose로 실행한 pgAdmin에서는 PostgreSQL 호스트와 포트로 `postgres:5432`를 사용해야 합니다. 로컬 PC에서 별도로 실행하는 pgAdmin, DBeaver, `psql` 등에서는 `localhost:5433`을 사용합니다.

## 9. 현재 구현 상태

| 항목 | 상태 | 비고 |
|---|---|---|
| Flutter mock MVP | 완료 | 주요 사용자 흐름과 인메모리 상태 변경 구현 |
| API 명세 | 완료 | Spring Boot 구현을 위한 REST API 계약 초안 |
| DB schema 문서 | 완료 | 테이블, 관계, 제약조건, 인덱스, View 및 DDL 초안 |
| PostgreSQL Docker 환경 | 완료 | 컨테이너 실행·접속 확인, `health_check` 테이블 적용 |
| Spring Boot backend | 예정 | `backend/` 구현 전 |
| 실제 API 연동 | 예정 | Flutter는 현재 mock 데이터 사용 |
| 실제 지도 API 연동 | 예정 | 현재 레이어와 마커는 mock UI |
| 이미지 업로드 서버 연동 | 예정 | 현재 실제 이미지 선택·업로드 미지원 |

## 10. 향후 개발 계획

1. Spring Boot 백엔드 프로젝트 생성
2. PostgreSQL 연결 및 Flyway 또는 Liquibase 마이그레이션 구성
3. 회원가입·로그인·JWT 인증 API 구현
4. 개인 플로깅 세션 및 활동 기록 API 구현
5. 쓰레기 사진 업로드 및 인증 API 구현
6. 단체 플로깅 생성·조회·참여 API 구현
7. 커뮤니티 게시글·댓글·좋아요 API 구현
8. Flutter mock 데이터를 실제 API 응답으로 교체
9. 실제 지도 API와 GPS 기능 연동
10. 마이페이지 및 지역별 통계 화면 고도화

## 11. 포트폴리오 관점에서 배운 점

이 프로젝트를 진행하면서 단순히 화면을 만드는 것보다 **어떤 데이터가 어떤 구조로 쌓여야 실제 서비스로 확장할 수 있는지**를 먼저 고민했습니다.

사용자에게 많은 정보를 요구하면 데이터 품질은 높아질 수 있지만 사용성이 낮아질 수 있습니다. 반대로 입력을 지나치게 단순화하면 검색과 통계에 활용하기 어렵습니다. 사진 중심 쓰레기 인증과 구조화된 단체 플로깅 입력을 설계하며 이 균형을 구체적으로 다뤘습니다.

또한 위치 기반 서비스라는 특성을 고려해 개인정보와 위치정보 보호 원칙을 초기 설계부터 반영했습니다. mock-first 방식으로 핵심 사용자 흐름을 빠르게 검증하고, API·DB 계약을 별도로 문서화해 이후 백엔드 연결로 확장할 수 있는 기반을 마련했습니다.

---

이 저장소의 현재 범위는 **동작 가능한 Flutter mock MVP, 백엔드·데이터베이스 설계 문서, 로컬 PostgreSQL 실행 환경**입니다. 실제 운영 서비스 수준의 백엔드, 외부 API 연동, 보안 검증, 법률 검토는 향후 작업 범위입니다.
