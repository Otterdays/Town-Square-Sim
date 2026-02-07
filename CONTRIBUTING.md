# Contributing

Thanks for considering contributing to Human Simulator (Town-Square).

## Before you start

- Read [DOCS/SUMMARY.md](DOCS/SUMMARY.md) and [DOCS/ARCHITECTURE.md](DOCS/ARCHITECTURE.md).
- Follow [DOCS/STYLE_GUIDE.md](DOCS/STYLE_GUIDE.md) (naming, limits, trace tags, comments).

## Setup

1. Clone the repo.
2. Ensure Elixir 1.19+ is installed: `elixir --version`.
3. From repo root: `cd human_sim && mix deps.get && mix compile`.

## Running tests

```bash
cd human_sim && mix test
```

Keep tests passing; add tests for new behavior when possible.

## Submitting changes

1. Make your change in a branch (optional but helpful).
2. Run `mix format` and `mix test` in `human_sim/`.
3. Update DOCS as needed (SCRATCHPAD, CHANGELOG, ARCHITECTURE if you add modules).
4. Open a pull request with a short description of what changed and why.

## Doc updates

- **New module or API:** Update ARCHITECTURE (components table, data flow).
- **New dependency:** Update DOCS/SBOM.md.
- **Notable change:** Add an entry under [Unreleased] in DOCS/CHANGELOG.md.

## Questions

Open an issue for bugs or feature ideas.
