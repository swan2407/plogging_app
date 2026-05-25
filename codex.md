# CODEX.md

## Project
This is a plogging mobile app.

## Main spec
Read `docs/plogging_app_planning_design_doc.md` before making changes.

## Architecture
- Frontend: Flutter
- Backend: Spring Boot
- Database: PostgreSQL
- Do not mix frontend and backend code.
- Work only in the requested directory.

## Current priority
Implement MVP first:
1. Flutter project structure
2. Home screen
3. Bottom navigation
4. Login-required navigation guard
5. Personal plogging screen mock
6. Trash registration screen mock
7. My activity record screen mock

## Coding rules
- Make small changes.
- Explain changed files after editing.
- Do not implement all features at once.
- Do not delete existing files unless explicitly asked.
- Prefer clean architecture-style folders in Flutter:
  - core
  - data
  - domain
  - presentation
- Use mock data first if backend is not ready.

structure
frontend/lib/
├─ main.dart
├─ app.dart
├─ core/
│  ├─ constants/
│  ├─ theme/
│  ├─ router/
│  └─ utils/
│
├─ features/
│  ├─ auth/
│  │  └─ presentation/
│  ├─ home/
│  │  └─ presentation/
│  ├─ plogging/
│  │  └─ presentation/
│  ├─ group_plogging/
│  │  └─ presentation/
│  ├─ map/
│  │  └─ presentation/
│  ├─ community/
│  │  └─ presentation/
│  └─ my_page/
│     └─ presentation/