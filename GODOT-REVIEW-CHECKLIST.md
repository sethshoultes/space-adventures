# Godot Code Review Master Checklist

Status legend: [ ] pending  [~] in progress  [x] done

## Service Configuration
- [x] Centralize service URLs via `ServiceManager` with ProjectSettings overrides
- [x] Route client calls through Gateway (`/api/v1/ai/...`) instead of direct ports
- [x] Add runtime fallback to direct AI service when Gateway is unavailable
- [ ] Add ProjectSettings defaults in `project.godot` (optional)

## Networking & Concurrency
- [x] AIService: add GET/DELETE helpers; free ephemeral HTTPRequest nodes
- [x] AIService: create ephemeral request when pool is exhausted (no busy reuse)
- [x] StoryService: switch to ephemeral-per-request pattern; free after use
- [x] Add simple request queue/backoff for burst scenarios
- [ ] Add mock mode for tests (bypass network with canned responses)

## Gameplay Logic
- [x] Seed RNG in `MissionManager` to avoid deterministic rolls
- [x] Harden mission requirement checks (safe access to systems/levels)
- [ ] Add tests for `_resolve_choice` success/failure paths and stage flow

## UI & Data Cohesion
- [x] Deduplicate power cost tables; use `PartRegistry.get_power_cost` with fallback
- [ ] Centralize colors/styles into a Theme resource instead of per-script overrides
- [ ] Avoid full grid rebuilds when possible; update in place for inventory

## Observability & DX
- [ ] Wrap `print()` with a lightweight logger or debug flag
- [ ] Add headless test runner script for Godot CI
- [x] Document URL overrides and local dev setup in `godot/README.md`

## Security & Config
- [ ] Expose service URLs via `ProjectSettings` UI and document profiles
- [ ] Provide example `project_settings.cfg` snippet for contributors

---

Last updated: 2025-11-10
