# Human Simulator – test config

import Config

config :human_sim, HumanSimWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4001],
  secret_key_base: "test_secret_key_base_64_chars_minimum_for_phoenix_crypto",
  server: false

config :human_sim, :start_sim_runner, false
