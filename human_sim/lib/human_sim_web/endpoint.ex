defmodule HumanSimWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :human_sim

  @session_options [
    store: :cookie,
    key: "_human_sim_key",
    signing_salt: "townsquare",
    secure: false,
    max_age: 2 * 60 * 60
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: :human_sim,
    gzip: false,
    only: HumanSimWeb.static_paths()

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug HumanSimWeb.Router
end
