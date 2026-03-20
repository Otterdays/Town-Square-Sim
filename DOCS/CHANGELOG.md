# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

- Proximity / area→NPC list; more dialogue topics and item types.

### Added

- **3D town view:** `HumanSimWeb.SceneSnapshot`, LiveView `push_event` scene_init/scene_patch, JS hook `TownSquare3D` (Three.js) with zones, NPC meshes, items, move tweens, interact cues.
- **Events:** `item_interact` PubSub broadcast after successful NPC `use_item`; LiveView feed + scene patch for item state.
- **World seed:** Item `metadata.anchor` for bench/counter/fountain/chair placement in 3D.

### Changed

- **README:** Rewritten for clarity; highlights 3D LiveView UI, `npm install` in `human_sim/assets`, PubSub/event surface, and doc map.
- **Repo URL:** Clone instructions and Mix `package/0` link point to [github.com/Otterdays/Game-Town-Square-Sim](https://github.com/Otterdays/Game-Town-Square-Sim).

## [0.2.0] - 2026-02-18

### Added

- **Phoenix LiveView UI:** Town Square dashboard at http://localhost:4000.
- **HumanSim.Events:** PubSub broadcasts for move, chat, hear; LiveView subscribes for real-time updates.
- **HumanSim.SimRunner:** Auto-tick GenServer; seeds 4 areas (square, shop, park, tavern), items, 8 NPCs; drives moves/chats every 2s.
- **HumanSimWeb:** Endpoint, Router, TownSquareLive (4-area grid, NPC avatars by mood, live feed).
- **launch_web.bat:** Web-only launcher; `launch.bat` updated with assets.build and web URL.

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
