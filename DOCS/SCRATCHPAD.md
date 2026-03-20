# SCRATCHPAD

**Active:** Human Simulator (Town-Square) – 3D town view + item sync.

**Last 5:**
- Canonical repo URL: https://github.com/Otterdays/Game-Town-Square-Sim (README clone path + mix.exs package link).
- README overhaul: 3D UI, npm/Three.js, `item_interact`, tables, doc links; Quick start includes `assets/npm install`.
- SceneSnapshot + push_event scene_init/scene_patch; LiveView hook TownSquare3D (Three.js).
- NPC broadcasts `item_interact` after successful `use_item`; seeded item `metadata.anchor` for prop placement.
- npm `three` in assets; `mix assets.build` bundles ~1.1mb app.js.
- CHANGELOG [Unreleased]: README refresh noted.

**Blockers:** None.

**Next:** Optional server-side NPC positions / proximity; nametags / chat bubbles in 3D (Phase 4 polish).
