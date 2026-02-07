# HumanSim (Elixir package)

This directory is the Elixir Mix application for **Human Simulator (Town-Square)**.

- **Repo overview and usage:** See the [root README](../README.md).
- **Architecture and API:** See [DOCS/ARCHITECTURE.md](../DOCS/ARCHITECTURE.md).

## Commands

```bash
mix deps.get    # Fetch dependencies
mix compile     # Compile
mix test        # Run tests
iex -S mix      # Interactive shell with app started
```

## As a dependency

If you publish to Hex or use as a Git dependency:

```elixir
def deps do
  [
    {:human_sim, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) and published on [HexDocs](https://hexdocs.pm).
