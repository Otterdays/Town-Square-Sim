defmodule HumanSim.World do
  @moduledoc """
  Environment: areas and items. GenServer + ETS for fast lookup.
  [TRACE: ARCHITECTURE.md]
  """
  use GenServer
  alias HumanSim.Item

  @table :human_sim_world_items
  @areas_table :human_sim_world_areas

  # Client
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def put_item(item = %Item{}) do
    GenServer.call(__MODULE__, {:put_item, item})
  end

  def get_item(item_id) do
    GenServer.call(__MODULE__, {:get_item, item_id})
  end

  def list_items_in_area(area_id) do
    GenServer.call(__MODULE__, {:list_items_in_area, area_id})
  end

  def interact_item(item_id, actor_id, action \\ :use) do
    GenServer.call(__MODULE__, {:interact_item, item_id, actor_id, action})
  end

  def register_area(area_id) do
    GenServer.call(__MODULE__, {:register_area, area_id})
  end

  def list_areas do
    GenServer.call(__MODULE__, :list_areas)
  end

  # Server
  @impl true
  def init(_opts) do
    :ets.new(@table, [:set, :public, :named_table, read_concurrency: true])
    :ets.new(@areas_table, [:set, :public, :named_table, read_concurrency: true])
    {:ok, %{}}
  end

  @impl true
  def handle_call({:put_item, item}, _from, state) do
    :ets.insert(@table, {item.id, item})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get_item, item_id}, _from, state) do
    result =
      case :ets.lookup(@table, item_id) do
        [{^item_id, item}] -> {:ok, item}
        [] -> {:error, :not_found}
      end
    {:reply, result, state}
  end

  @impl true
  def handle_call({:list_items_in_area, area_id}, _from, state) do
    items =
      @table
      |> :ets.tab2list()
      |> Enum.filter(fn {_id, item} -> item.area_id == area_id end)
      |> Enum.map(fn {_id, item} -> item end)
    {:reply, items, state}
  end

  @impl true
  def handle_call({:interact_item, item_id, _actor_id, action}, _from, state) do
    result =
      case :ets.lookup(@table, item_id) do
        [{^item_id, item}] ->
          {effect, updated} = Item.interact(item, action)
          :ets.insert(@table, {item_id, updated})
          {:ok, effect, updated}

        [] ->
          {:error, :not_found}
      end
    {:reply, result, state}
  end

  @impl true
  def handle_call({:register_area, area_id}, _from, state) do
    :ets.insert(@areas_table, {area_id, true})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:list_areas, _from, state) do
    areas = @areas_table |> :ets.tab2list() |> Enum.map(fn {id, _} -> id end)
    {:reply, areas, state}
  end
end
