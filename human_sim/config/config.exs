# Human Simulator – base config
# [TRACE: ARCHITECTURE.md]

import Config

config :human_sim, HumanSimWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: HumanSimWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: HumanSim.PubSub,
  live_view: [signing_salt: "townsquare"]

config :human_sim, :start_sim_runner, true

config :esbuild,
  version: "0.10.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
