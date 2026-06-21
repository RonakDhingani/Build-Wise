# BuildWise — Project Vision

**Tagline:** Smart Construction Budget & Project Manager

---

## 1. Problem Statement

Construction projects in India (and globally) face:
- Budget overruns due to poor expense tracking
- No centralized material usage monitoring
- No progress visibility for owners
- Manual, error-prone cost tracking (spreadsheets, paper)
- No professional reports for stakeholders

## 2. Vision

BuildWise empowers house owners, contractors, site engineers, builders, and interior designers to manage construction projects with clarity, precision, and confidence — all offline, on their mobile device.

Every project tracked in BuildWise should feel like it has a professional project manager on-site.

## 3. Target Users

| User | Primary Need |
|------|-------------|
| House Owner | Budget visibility, progress updates, vendor accountability |
| Contractor | Stage tracking, expense records, client-ready reports |
| Site Engineer | Material usage, stage management, daily logs |
| Builder | Multi-project overview, cost control |
| Interior Designer | Material tracking, vendor management, cost breakdown |

## 4. Core Value Propositions

1. **Budget Clarity** — Know exactly what's spent, what remains, and where money went
2. **Stage Tracking** — Monitor construction progress stage by stage
3. **Material Control** — Track every bag of cement, every rod of steel
4. **Instant Reports** — Professional PDF reports in seconds
5. **Offline First** — Works without internet, always
6. **Speed** — Project created in 60s, expense logged in 10s

## 5. Success Metrics (V1)

- Project creation: < 60 seconds
- Expense entry: < 10 seconds
- Report generation: < 15 seconds
- App launch to dashboard: < 2 seconds
- Zero crashes on core flows

## 6. V1 Scope Boundary

**IN:** Offline, local-only, single-user, project management, expense tracking, material tracking, stages, photos, PDF reports

**OUT:** Login, cloud sync, team collaboration, AI, payments, subscriptions

## 7. V2 Vision (Cloud-Ready Architecture)

V1 architecture must support:
- Cloud sync via Isar → API bridge (Repository Pattern abstraction)
- Multi-device access
- Team collaboration
- Real-time updates

No V2 features in V1 code. Architecture must accommodate without refactoring.

## 8. Brand Identity

- **Name:** BuildWise
- **Tone:** Professional, trustworthy, minimal, modern
- **Inspiration:** Notion (clarity), Google Pay (speed), Linear (precision), Zerodha (finance confidence)
- **Color:** Deep Navy + Construction Gold
- **Font:** Inter
- **Feel:** Premium construction management, not a basic tracker

## 9. Platform Priority

1. Android (primary)
2. iOS (architecture-compatible, V1.1)

## 10. Technology Principles

- Flutter (cross-platform)
- Riverpod (state management)
- Isar (local DB)
- go_router (navigation)
- Clean Architecture (3 layers)
- 100% offline
