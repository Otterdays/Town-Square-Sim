defmodule HumanSim.Item do
  @moduledoc """
  Interactable environment item. Struct + pure behavior; no process.
  [TRACE: ARCHITECTURE.md]
  """
  defstruct [:id, :type, :area_id, :state, :metadata]
  @type t :: %__MODULE__{
          id: term(),
          type: atom(),
          area_id: term(),
          state: atom(),
          metadata: map()
        }

  @doc "Interact with item (e.g. use, pick_up). Returns {effect, updated_item}."
  def interact(item, action) when action in [:use, :pick_up, :inspect] do
    case {item.type, action, item.state} do
      {:bench, :use, :available} ->
        {:sat_down, %{item | state: :in_use}}

      {:bench, :use, :in_use} ->
        {:already_in_use, item}

      {:bench, :inspect, _} ->
        {:description, "A wooden bench.", item}

      {:door, :use, :closed} ->
        {:opened, %{item | state: :open}}

      {:door, :use, :open} ->
        {:closed, %{item | state: :closed}}

      {:object, :pick_up, :available} ->
        {:picked_up, %{item | state: :taken}}

      {_, :inspect, _} ->
        {:description, "Something you can interact with.", item}

      _ ->
        {:no_effect, item}
    end
  end
end
