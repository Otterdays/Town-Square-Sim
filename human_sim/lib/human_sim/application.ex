defmodule HumanSim.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: HumanSim.NPCRegistry},
      {Phoenix.PubSub, name: HumanSim.PubSub},
      HumanSim.World,
      {DynamicSupervisor, strategy: :one_for_one, name: HumanSim.Crowd.Supervisor},
      HumanSim.SimRunner,
      HumanSimWeb.Endpoint
    ]
    opts = [strategy: :rest_for_one, name: HumanSim.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
