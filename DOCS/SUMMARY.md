# SUMMARY

**Project:** Human Simulator (Town-Square)  
**Stack:** Elixir/OTP. Rule-based NPCs, crowds, environment items, personalities. No ML.

## Status

- **Core:** Complete. World, Item, Personality, Dialogue, NPC, Crowd; supervisor wired; 9 tests pass.
- **UI:** Phoenix LiveView dashboard at http://localhost:4000 — 3D town (Three.js hook), area grid, NPCs, live chat feed. [AMENDED 2026-03-20]: scene + `item_interact` sync.
- **Next:** More dialogue topics and item types; proximity / area-based NPC lists.

## Requirements

- Elixir 1.19+ (and Erlang/OTP from the same install).
- Node/npm for `human_sim/assets` (Three.js); run `npm install` there before first `mix assets.build`. [AMENDED 2026-03-20]
- No external services or DB required for core sim.

## Quick links

| Doc | Purpose |
|-----|---------|
| [ARCHITECTURE](ARCHITECTURE.md) | System structure, API summary, file map, data flow, extension points. |
| [SCRATCHPAD](SCRATCHPAD.md) | Active tasks, blockers, last 5 actions. |
| [CHANGELOG](CHANGELOG.md) | Version history. |
| [SBOM](SBOM.md) | Dependencies; update on every package add/remove. |
| [STYLE_GUIDE](STYLE_GUIDE.md) | Naming, limits, trace, comments, testing. |
| [My_Thoughts](My_Thoughts.md) | Decisions and rationale. |

## Run

```bash
cd human_sim/assets && npm install && cd ..
mix setup
mix test
iex -S mix
```

From repo root (Windows): `launch.bat` (runs `mix setup` then IEx). See **README.md** for full quick start.

## Repo layout

- `human_sim/` — Elixir app (Mix project).
- `DOCS/` — Project docs; `debugs/` for issue logs.
- `README.md` — User-facing overview and usage.
- `CONTRIBUTING.md` — How to contribute.
- `LICENSE` — MIT.
