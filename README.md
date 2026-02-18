# Human Simulator (Town-Square)

Rule-based simulation of chatting NPCs, crowds, environment items, and personalities—built in **Elixir/OTP**, no ML.

Use it for: game-like NPCs, agent-based crowds, interactive environments, or as a base for a small social sim.

## Features

- **Chatting NPCs** — Each NPC is a process with personality, mood, and short-term memory. Say things and get rule-based replies; chat by topic (greeting, weather, goodbye, etc.).
- **Personalities** — Traits (friendly, grumpy, curious, shy, bold) drive dialogue and are easy to extend for reactions.
- **Crowds** — Spawn many NPCs under a supervisor; scale to hundreds or more.
- **Environment & items** — World holds areas and items; NPCs (or your code) can use, pick up, or inspect items. Bench, door, and generic object behaviors included; add more in one place.

## Requirements

- [Elixir](https://elixir-lang.org/install.html) 1.19+ (and Erlang/OTP from the same install)

## Quick start

```bash
git clone https://github.com/Otterdays/Town-Square-Sim.git
cd Town-Square-Sim/human_sim
mix deps.get
mix compile
mix test
mix assets.build
iex -S mix
```

**Web UI:** Open http://localhost:4000 for the live Town Square dashboard (NPCs, areas, chat feed).

**Windows:** From repo root, run `launch.bat` (IEx + web) or `launch_web.bat` (web only).

## Try it in IEx

Once in `iex -S mix`, the app and World are already running:

```elixir
HumanSim.World.register_area(:square)
HumanSim.World.put_item(%HumanSim.Item{id: :bench1, type: :bench, area_id: :square, state: :available, metadata: %{}})

HumanSim.Crowd.spawn_npc(id: "alice", name: "Alice", area_id: :square)
HumanSim.Crowd.spawn_npc(id: "bob", name: "Bob", area_id: :square)

HumanSim.NPC.say("alice", "Hello!")
HumanSim.NPC.chat("bob", :weather)
HumanSim.NPC.use_item("alice", :bench1, :use)

HumanSim.Crowd.spawn_npc_list(20, area_id: :square)
HumanSim.Crowd.count()
```

## Project layout

| Path | Description |
|------|-------------|
| `human_sim/` | Elixir Mix application (all runtime code and tests). |
| `DOCS/` | Project docs: architecture, summary, style guide, changelog, etc. |
| `CONTRIBUTING.md` | How to contribute. |
| `LICENSE` | MIT. |

## Documentation

- **Overview & run:** This README.
- **Architecture, API, extension points:** [DOCS/ARCHITECTURE.md](DOCS/ARCHITECTURE.md).
- **Status and quick links:** [DOCS/SUMMARY.md](DOCS/SUMMARY.md).
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
