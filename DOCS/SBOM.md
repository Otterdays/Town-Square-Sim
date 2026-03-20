# SBOM

**Human Simulator** – dependency list. Audit before adding; update on every install/remove.

| Package | Version | Purpose |
|---------|---------|---------|
| phoenix | ~> 1.7 | Web framework, LiveView, Endpoint. |
| phoenix_html | ~> 4.1 | HTML helpers. |
| phoenix_live_view | ~> 0.20 | Real-time UI over WebSocket. |
| bandit | ~> 1.5 | HTTP server. |
| esbuild | ~> 0.8 | JS bundling (dev). |
| jason | ~> 1.4 | JSON library. |

### npm (human_sim/assets)

| Package | Version | Purpose |
|---------|---------|---------|
| three | ^0.170.0 | WebGL scene for TownSquare3D LiveView hook (bundled by esbuild). |

[AMENDED 2026-03-20]: Added `three` for 3D town view.
