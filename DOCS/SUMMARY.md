# SUMMARY

**Project:** Human Simulator (Town-Square)  
**Stack:** Elixir/OTP. Rule-based NPCs, crowds, environment items, personalities. No ML.

## Status

- **Core:** Complete. World, Item, Personality, Dialogue, NPC, Crowd; supervisor wired; 8 tests pass.
- **Next:** Optional Phoenix/LiveView UI; more dialogue topics and item types; proximity / area-based NPC lists.

## Requirements

- Elixir 1.19+ (and Erlang/OTP from the same install).
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
cd human_sim && mix deps.get && mix compile
mix test
iex -S mix
```

From repo root (Windows): `launch.bat`.

## Repo layout

- `human_sim/` — Elixir app (Mix project).
- `DOCS/` — Project docs; `debugs/` for issue logs.
- `README.md` — User-facing overview and usage.
- `CONTRIBUTING.md` — How to contribute.
- `LICENSE` — MIT.
