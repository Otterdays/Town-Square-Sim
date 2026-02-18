defmodule HumanSim.SimRunner do
  @moduledoc """
  Auto-tick GenServer: spawns NPCs, registers areas/items, drives sim activity.
  [TRACE: ARCHITECTURE.md]
  """
  use GenServer
  alias HumanSim.World
  alias HumanSim.Crowd
  alias HumanSim.NPC
  alias HumanSim.Item
  alias HumanSim.Personality
  alias HumanSim.Events

  @areas [:square, :shop, :park, :tavern]
  @topics [:greeting, :weather, :goodbye, :general]
  @tick_ms 2_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_snapshot do
    GenServer.call(__MODULE__, :get_snapshot)
  end

  @impl true
  def init(_opts) do
    if Application.get_env(:human_sim, :start_sim_runner, true) do
      npc_ids = seed_world()
      {:ok, %{tick: 0, npc_ids: npc_ids}, {:continue, :schedule_tick}}
    else
      {:ok, %{tick: 0, npc_ids: []}}
    end
  end

  @impl true
  def handle_continue(:schedule_tick, state) do
    Process.send_after(self(), :tick, @tick_ms)
    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, state) do
    Process.send_after(self(), :tick, @tick_ms)
    new_state = run_tick(state)
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_snapshot, _from, state) do
    npcs =
      Enum.map(state.npc_ids, fn id ->
        case NPC.get_state(id) do
          nil -> nil
          s -> %{id: s.id, name: s.name, area_id: s.area_id, mood: s.mood}
        end
      end)
      |> Enum.reject(&is_nil/1)

    items_by_area =
      @areas
      |> Enum.map(fn area_id -> {area_id, World.list_items_in_area(area_id)} end)
      |> Map.new()

    {:reply,
     %{
       npcs: npcs,
       npc_count: length(npcs),
       tick: state.tick,
       items_by_area: items_by_area
     }, state}
  end

  defp seed_world do
    Enum.each(@areas, &World.register_area/1)

    World.put_item(%Item{
      id: :bench_square,
      type: :bench,
      area_id: :square,
      state: :available,
      metadata: %{}
    })
    World.put_item(%Item{
      id: :counter_shop,
      type: :object,
      area_id: :shop,
      state: :available,
      metadata: %{}
    })
    World.put_item(%Item{
      id: :fountain_park,
      type: :object,
      area_id: :park,
      state: :available,
      metadata: %{}
    })
    World.put_item(%Item{
      id: :chair_tavern,
      type: :bench,
      area_id: :tavern,
      state: :available,
      metadata: %{}
    })

    npc_opts = [
      [id: "alice", name: "Alice", area_id: :square, personality: Personality.new(friendly: 0.9)],
      [id: "bob", name: "Bob", area_id: :square, personality: Personality.new(grumpy: 0.6)],
      [id: "carol", name: "Carol", area_id: :shop, personality: Personality.new(curious: 0.9)],
      [id: "dave", name: "Dave", area_id: :shop, personality: Personality.new(bold: 0.8)],
      [id: "eve", name: "Eve", area_id: :park, personality: Personality.new(shy: 0.7)],
      [id: "frank", name: "Frank", area_id: :park, personality: Personality.new(friendly: 0.7)],
      [id: "grace", name: "Grace", area_id: :tavern, personality: Personality.new(grumpy: 0.4)],
      [id: "henry", name: "Henry", area_id: :tavern, personality: Personality.new(curious: 0.6)]
    ]

    npc_ids =
      for opts <- npc_opts do
        {:ok, _} = Crowd.spawn_npc(opts)
        Keyword.get(opts, :id)
      end

    Events.broadcast(%{type: :init, npc_count: length(npc_ids)})
    npc_ids
  end


  defp run_tick(state) do
    npc_ids = state.npc_ids
    tick = state.tick + 1

    if length(npc_ids) > 0 do
      move_count = min(3, max(1, div(length(npc_ids), 2)))
      chat_count = min(4, length(npc_ids))

      Enum.take_random(npc_ids, move_count)
      |> Enum.each(fn id ->
        to_area = Enum.random(@areas)
        NPC.move(id, to_area)
      end)

      Enum.take_random(npc_ids, chat_count)
      |> Enum.each(fn id ->
        topic = Enum.random(@topics)
        NPC.chat(id, topic)
      end)

      if :rand.uniform() < 0.3 do
        id = Enum.random(npc_ids)
        case NPC.get_state(id) do
          nil -> :ok
          s ->
            items = World.list_items_in_area(s.area_id)
            if length(items) > 0 do
              item = Enum.random(items)
              NPC.use_item(id, item.id, :use)
            end
        end
      end
    end

    %{state | tick: tick}
  end
end
