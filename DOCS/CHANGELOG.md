# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

- Proximity / area→NPC list; more dialogue topics and item types; optional Phoenix UI.

## [0.1.0] - 2025-01-31

### Added

- Elixir project `human_sim` with supervisor (Registry, World, Crowd DynamicSupervisor).
- **World:** GenServer + ETS for areas and items; `put_item`, `get_item`, `list_items_in_area`, `interact_item`.
- **Item:** Struct + `interact/2` (bench, door, object; use/pick_up/inspect).
- **Personality:** Trait map (friendly, grumpy, curious, shy, bold); `new/1`, `get/2`, `apply_mood/2`.
- **Dialogue:** Rule-based responses by topic + personality + mood; weighted pick.
- **NPC:** GenServer per human; `say`, `hear`, `chat`, `use_item`, `move`; memory (last N events); Registry-based name.
- **Crowd:** DynamicSupervisor; `spawn_npc/1`, `spawn_npc_list/2`, `count/0`.
- DOCS: SCRATCHPAD, SUMMARY, ARCHITECTURE, SBOM, STYLE_GUIDE, CHANGELOG, My_Thoughts; DOCS/debugs/.
- Tests for Item, Personality, Dialogue, World, NPC (8 tests).
- `launch.bat`; root and package READMEs.
- GitHub prep: root .gitignore, LICENSE (MIT), CONTRIBUTING.md; mix.exs description and package metadata.
