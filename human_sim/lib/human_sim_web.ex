defmodule HumanSimWeb do
  @moduledoc "Phoenix web interface for Town Square Sim. [TRACE: ARCHITECTURE.md]"

  def static_paths do
    ~w(assets fonts images favicon.ico robots.txt)
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json]
      import Plug.Conn
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView, layout: {HumanSimWeb.Layouts, :app}
    end
  end

  def router do
    quote do
      use Phoenix.Router, helpers: [HumanSimWeb.Router.Helpers]
    end
  end

  def html do
    quote do
      use Phoenix.Component
      import Phoenix.HTML
      import Phoenix.LiveView.Helpers
    end
  end

  @doc false
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
