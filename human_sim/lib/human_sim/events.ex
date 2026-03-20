defmodule HumanSim.Events do
  @moduledoc """
  PubSub broadcasts for sim events (move, chat, hear, item_interact). LiveView subscribes for real-time updates.
  [TRACE: ARCHITECTURE.md]
  """
  @topic "sim:events"

  def subscribe do
    Phoenix.PubSub.subscribe(HumanSim.PubSub, @topic)
  end

  def broadcast(event) when is_map(event) do
    Phoenix.PubSub.broadcast(HumanSim.PubSub, @topic, {:sim_event, event})
  end
end
