# 플로깅 앱

## 프로젝트 소개

플로깅 활동을 기록하고 주변 사람들과 함께 공유할 수 있는 위치 기반 환경 활동 앱입니다.

개인 플로깅, 단체 플로깅, 지도, 커뮤니티, 활동 기록을 중심으로 구성되어 있습니다.

## 기술 스택

- **Frontend:** Flutter
- **Backend:** Spring Boot 예정
- **Database:** PostgreSQL 예정
- **Development:** VS Code, Codex CLI
- **Current status:** Flutter mock MVP

## 현재 구현된 기능

- 홈 화면
- 로그인 및 회원가입 mock
- 회원가입 약관 동의
- 지역 선택
- 개인 플로깅 로그인 가드
- 쓰레기 사진 인증 mock
- 플로깅 종료 결과 요약
- 마이페이지 활동 기록 mock
- 커뮤니티 게시글 mock 작성 및 공유
- 단체 플로깅 목록, 상세, 생성 mock
- 지도 레이어 토글 mock

## 프로젝트 구조

```text
plogging/
├── frontend/        # Flutter 앱
├── backend/         # Spring Boot 백엔드 예정
├── docs/            # 프로젝트 문서
│   ├── legal/       # 약관 및 개인정보·위치정보 관련 문서
│   ├── api/         # API 명세 문서 작성 예정
│   └── planning/    # 서비스 기획 및 설계 문서
└── infra/           # Docker 및 배포 인프라 구성 예정
```

## Flutter 실행 방법

Flutter SDK와 Chrome 실행 환경이 필요합니다.

```bash
cd frontend
flutter pub get
flutter analyze
flutter run -d chrome
```

## 개발 원칙

- 조회 기능은 비회원도 이용할 수 있도록 구성합니다.
- 기록, 참여, 작성 기능은 로그인이 필요합니다.
- 실제 지도, API, 백엔드는 아직 연결하지 않았습니다.
- 초기에는 mock data로 기능과 사용자 흐름을 검증하고 이후 백엔드를 연동합니다.
- 개인정보와 위치정보는 서비스 제공에 필요한 범위에서 최소한으로 수집합니다.

## 다음 개발 예정

- API 명세 확정
- Spring Boot 백엔드 생성
- PostgreSQL Docker 구성
- 인증 API 구현
- Flutter API 연동
- 실제 지도 API 연결
- 이미지 업로드 연결
