# Rufble 🐾

**Feel every ruble saved.**

Personal finance goals tracker. Set savings targets, deposit manually, watch progress fill up. Offline-first, single user, no bank integrations — just you and your goals.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.11x-009688?logo=fastapi)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-4169E1?logo=postgresql)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)

---

## Features

- **Goals** — create savings goals with emoji, color, deadline, and target amount
- **Deposits & withdrawals** — manual entries with optional notes; full transaction history
- **Transfers** — move funds between goals in one tap
- **Multi-currency** — RUB (default), USD, EUR; live conversion via ЦБ РФ (daily)
- **Stats** — streak, velocity, projected completion date, per-goal charts
- **Tags & links** — organize goals and attach reference URLs
- **Archive** — completed and cancelled goals preserved for review
- **Offline-first** — works fully without a network; syncs when online (Phase 2)
- **Reminders** — local push notifications with a configurable daily time
- **Backup / restore** — JSON export and import of all data

## Stack

| Layer | Technology |
|-------|-----------|
| Mobile + Web | Flutter (Android primary, Web PWA) |
| State | Riverpod (`AsyncNotifier` / `Notifier`) |
| Local DB | Drift (SQLite) — offline source of truth |
| Navigation | go_router (path-based, `StatefulShellRoute`) |
| Network | dio + interceptors |
| Backend (Phase 2) | FastAPI + PostgreSQL + SQLAlchemy 2.0 async |
| Infrastructure | Docker Compose, Caddy (HTTPS), VPS Finland |

## Architecture

Monorepo with feature-based Flutter structure and a separate FastAPI backend.

```
rufble/
├── mobile/               # Flutter app
│   └── lib/
│       ├── app/          # CupertinoApp, router, theme
│       ├── core/         # constants, DI, network, theme, utils, shared widgets
│       └── features/
│           ├── goals/
│           ├── goal_detail/
│           ├── deposit/
│           ├── archive/
│           ├── stats/
│           ├── settings/
│           └── auth/
└── backend/              # FastAPI (Phase 2)
```

All money amounts are stored as **integer minor units** (kopecks / cents) — no floats anywhere in the stack.

## License

MIT — see [LICENSE](LICENSE).
