# STYLE_GUIDE

Project-specific conventions for Human Simulator (Town-Square).

## Naming

- **Elixir:** snake_case for modules, functions, variables; PascalCase for module names only.
- **Files:** match module name (e.g. `world.ex` → `HumanSim.World`).

## Limits

- **Line length:** 100 characters.
- **Function length:** 50 lines.
- **File length:** 400 lines (split module or extract submodules if larger).

## Trace

- Link code to docs with: `# [TRACE: filename.md]` (e.g. in moduledoc or above a section).
- Use doc filenames under `DOCS/` (e.g. `ARCHITECTURE.md`).

## Comments

- **WHY** only; avoid restating what the code does.
- Prefixes: `# TODO:`, `# FIXME:`, `# NOTE:`.

## Types over comments

- Prefer `@spec` and structs/types to document contracts; use comments for rationale or non-obvious constraints.

## Secrets

- Never commit secrets. Use `.env` (or env vars) and keep `.env` in `.gitignore`. No API keys or credentials in code.

## Testing

- Unit tests for pure modules (Item, Personality, Dialogue); integration-style for World and NPC (app started).
- Run before PR: `cd human_sim && mix test`.

## Docs

- Update SCRATCHPAD during work; update ARCHITECTURE when adding modules or public APIs; update SBOM on dependency change; add CHANGELOG entries for notable changes.
