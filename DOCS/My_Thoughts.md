# My_Thoughts

Decisions and rationale for Human Simulator (Town-Square).

## Why Elixir/OTP

- One process per NPC fits “many humans” and keeps state isolated; DynamicSupervisor scales to large crowds.
- World as a single GenServer + ETS keeps item/area lookups simple and fast without a DB for the core sim.
- Rule-based dialogue (no ML) keeps the stack small and behavior predictable and auditable.

## Why Registry for NPCs

- NPCs need a stable name (id) so callers can `say(id, msg)` without holding a pid. Registry gives global name → process without a single bottleneck process.

## Why rest_for_one for the app supervisor

- Registry must be up before NPCs; World before any use_item. If World crashes, restarting it and then Crowd is acceptable; we don’t need to restart Registry when Crowd restarts.

## Why ETS in World

- In-memory, fast, and good enough for areas and items. If we add persistence later, we can add a separate layer (e.g. Ecto) and keep ETS as cache or drop it.

## Prep for GitHub

- Root README for users; DOCS/ for contributors; CONTRIBUTING.md and LICENSE (MIT) for clarity and reuse. Single Elixir app in `human_sim/` keeps the repo easy to clone and run.
