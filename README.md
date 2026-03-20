# Town Square Sim

**A live, rule-driven crowd simulator in Elixir** — dozens of NPC processes chat, roam between areas, and poke at the world around them. No ML, no external APIs: just OTP, personalities, and code you can read.

Open the browser and you get a **real-time 3D town** (Three.js + Phoenix LiveView): four districts on one plane, capsule crowds, benches and props that change state when someone sits or grabs something, plus a scrolling event feed so you can see the drama unfold.

---

## Why this exists

Use it as a **playground** for concurrent agents, a **prototype** for game or social sims, or a **teaching** example of GenServers, supervision, ETS-backed worlds, and PubSub-driven UIs.

---

## What you get

| | |
| --- | --- |
| **NPCs** | One process per character: personality traits, mood, short-term memory, `say` / `hear` / `chat` / `move` / `use_item`. |
| **Dialogue** | Template-style responses by topic (greeting, weather, goodbye, …) weighted by personality — extend in one module. |
| **World** | Areas and items in ETS; `interact_item` with effects (bench occupancy, doors, pick-up, inspect). |
| **Crowd** | Dynamic supervisor; spawn one NPC or hundreds. |
| **Web UI** | LiveView dashboard at **http://localhost:4000** — 3D scene synced over the socket (`scene_init` / `scene_patch`), 2D area grid, live feed. |
| **Events** | PubSub: moves, chat, overheard lines, and **`item_interact`** when the sim actually changes an item. |

---

## Requirements

- [Elixir](https://elixir-lang.org/install.html) **1.19+** (Erlang/OTP from the same install)
- [Node.js](https://nodejs.org/) (for `npm` — pulls **Three.js** into `human_sim/assets`)

---

## Quick start

```bash
git clone https://github.com/Otterdays/Game-Town-Square-Sim.git
cd Game-Town-Square-Sim/human_sim/assets
npm install
cd ..
mix setup    # deps.get, compile, assets.build
mix test
iex -S mix
```

Then visit **http://localhost:4000** and watch the town tick (auto-driven sim + 3D view).

**Windows:** from the repo root, `launch.bat` runs `mix setup` and opens **IEx + web**; `launch_web.bat` is web-only if you prefer.

---

## Try it in IEx

With `iex -S mix`, the application (World, optional sim runner, endpoint) is already up:

```elixir
HumanSim.World.register_area(:square)
HumanSim.World.put_item(%HumanSim.Item{
  id: :bench1,
  type: :bench,
  area_id: :square,
  state: :available,
  metadata: %{}
})

HumanSim.Crowd.spawn_npc(id: "alice", name: "Alice", area_id: :square)
HumanSim.Crowd.spawn_npc(id: "bob", name: "Bob", area_id: :square)

HumanSim.NPC.say("alice", "Hello!")
HumanSim.NPC.chat("bob", :weather)
HumanSim.NPC.use_item("alice", :bench1, :use)

HumanSim.Crowd.spawn_npc_list(20, area_id: :square)
HumanSim.Crowd.count()
```

---

## Project layout

| Path | Description |
| --- | --- |
| `human_sim/` | Mix app: sim core, Phoenix endpoint, LiveView, assets (JS/CSS), tests. |
| `human_sim/assets/` | Front-end bundle; `npm install` here before first `mix assets.build` (or `mix setup`). |
| `DOCS/` | Architecture, summary, SBOM, style guide, changelog, scratchpad. |
| `CONTRIBUTING.md` | Contribution guidelines. |
| `LICENSE` | MIT. |

---

## Documentation

| Doc | What it’s for |
| --- | --- |
| [DOCS/ARCHITECTURE.md](DOCS/ARCHITECTURE.md) | Supervision tree, World/NPC API, **Scene / 3D** payloads and hook name. |
| [DOCS/SUMMARY.md](DOCS/SUMMARY.md) | Short status snapshot and quick links. |
| [DOCS/SBOM.md](DOCS/SBOM.md) | Hex + npm dependencies. |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute. |

---

## License

MIT — see [LICENSE](LICENSE).
