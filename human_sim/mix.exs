defmodule HumanSim.MixProject do
  use Mix.Project

  def project do
    [
      app: :human_sim,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      description: "Rule-based human simulator: chatting NPCs, crowds, items, personalities (Elixir/OTP).",
      package: package(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "compile", "assets.build"],
      "assets.build": ["esbuild default"],
      "assets.watch": ["esbuild default --watch"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {HumanSim.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 0.20"},
      {:bandit, "~> 1.5"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:jason, "~> 1.4"}
    ]
  end
end
