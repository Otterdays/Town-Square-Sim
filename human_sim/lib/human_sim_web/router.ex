defmodule HumanSimWeb.Router do
  use HumanSimWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, html: {HumanSimWeb.Layouts, :root}
  end

  scope "/", HumanSimWeb do
    pipe_through :browser
    live "/", TownSquareLive
  end
end
