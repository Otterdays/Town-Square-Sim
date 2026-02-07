defmodule HumanSim.NPC do
  @moduledoc """
  One simulated human: GenServer with personality, mood, location, memory.
  [TRACE: ARCHITECTURE.md]
  """
  use GenServer
  alias HumanSim.Personality
  alias HumanSim.Dialogue
  alias HumanSim.World

  defstruct [:id, :name, :personality, :mood, :area_id, :memory, :pid]
  @type mood :: :neutral | :happy | :annoyed | :sad
  @max_memory 10

  # Client
  def start_link(opts \\ []) do
    id = Keyword.get(opts, :id) || make_id()
    name = Keyword.get(opts, :name) || "NPC-#{id}"
    personality = Keyword.get(opts, :personality) || Personality.new()
    area_id = Keyword.get(opts, :area_id) || :square
    GenServer.start_link(__MODULE__, [id: id, name: name, personality: personality, area_id: area_id],
      name: via(id)
    )
  end

  def say(npc_id, message) do
    GenServer.call(via(npc_id), {:say, message})
  end

  def hear(npc_id, from_id, message) do
    GenServer.cast(via(npc_id), {:hear, from_id, message})
  end

  def chat(npc_id, topic) do
    GenServer.call(via(npc_id), {:chat, topic})
  end

  def use_item(npc_id, item_id, action \\ :use) do
    GenServer.call(via(npc_id), {:use_item, item_id, action})
  end

  def move(npc_id, area_id) do
    GenServer.call(via(npc_id), {:move, area_id})
  end

  def get_state(npc_id) do
    GenServer.call(via(npc_id), :get_state)
  end

  defp via(id), do: {:via, Registry, {HumanSim.NPCRegistry, id}}

  # Server
  @impl true
  def init([id: id, name: name, personality: personality, area_id: area_id]) do
    state = %__MODULE__{
      id: id,
      name: name,
      personality: personality,
      mood: :neutral,
      area_id: area_id,
      memory: [],
      pid: self()
    }
    {:ok, state}
  end

  @impl true
  def handle_call({:say, message}, _from, state) do
    topic = infer_topic(message)
    response = Dialogue.respond(topic, state.personality, state.mood)
    memory = add_memory(state.memory, {:said, message, response})
    {:reply, response, %{state | memory: memory}}
  end

  @impl true
  def handle_call({:chat, topic}, _from, state) do
    response = Dialogue.respond(topic, state.personality, state.mood)
    memory = add_memory(state.memory, {:chatted, topic, response})
    {:reply, response, %{state | memory: memory}}
  end

  @impl true
  def handle_call({:use_item, item_id, action}, _from, state) do
    result = World.interact_item(item_id, state.id, action)
    memory =
      case result do
        {:ok, effect, _item} -> add_memory(state.memory, {:used_item, item_id, effect})
        _ -> state.memory
      end
    {:reply, result, %{state | memory: memory}}
  end

  @impl true
  def handle_call({:move, area_id}, _from, state) do
    {:reply, :ok, %{state | area_id: area_id}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:hear, from_id, message}, state) do
    memory = add_memory(state.memory, {:heard, from_id, message})
    {:noreply, %{state | memory: memory}}
  end

  defp infer_topic(msg) when is_binary(msg) do
    s = String.downcase(msg)
    cond do
      String.contains?(s, "hello") or String.contains?(s, "hi") -> :greeting
      String.contains?(s, "weather") or String.contains?(s, "rain") -> :weather
      String.contains?(s, "bye") or String.contains?(s, "goodbye") -> :goodbye
      true -> :general
    end
  end

  defp add_memory(mem, entry) do
    [entry | mem] |> Enum.take(@max_memory)
  end

  defp make_id do
    :erlang.unique_integer([:positive]) |> Integer.to_string(36)
  end
end
