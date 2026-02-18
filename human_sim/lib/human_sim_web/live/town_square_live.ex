defmodule HumanSimWeb.TownSquareLive do
  @moduledoc "LiveView dashboard for Town Square Sim. [TRACE: ARCHITECTURE.md]"
  use HumanSimWeb, :live_view

  @areas [:square, :shop, :park, :tavern]
  @area_labels %{square: "Square", shop: "Shop", park: "Park", tavern: "Tavern"}
  @max_feed 20

  @impl true
  def mount(_params, _session, socket) do
    HumanSim.Events.subscribe()
    snapshot = HumanSim.SimRunner.get_snapshot()

    npcs_map =
      Map.new(snapshot.npcs, fn n -> {n.id, %{name: n.name, area_id: n.area_id, mood: n.mood}} end)

    socket =
      socket
      |> assign(:npcs, npcs_map)
      |> assign(:npc_count, snapshot.npc_count)
      |> assign(:tick, snapshot.tick)
      |> assign(:items_by_area, snapshot.items_by_area)
      |> assign(:feed, [])
      |> assign(:area_labels, @area_labels)
      |> assign(:areas, @areas)

    {:ok, socket}
  end

  @impl true
  def handle_info({:sim_event, event}, socket) do
    socket =
      case event do
        %{type: :move, npc_id: id, npc_name: name, to_area: to_area} ->
          socket
          |> update(:npcs, &Map.put(&1, id, %{name: name, area_id: to_area, mood: :neutral}))
          |> add_feed(:move, "#{name} moved to #{@area_labels[to_area] || to_area}")

        %{type: :chat, npc_id: _id, npc_name: name, area_id: area_id, response: response} ->
          area = @area_labels[area_id] || area_id
          socket
          |> add_feed(:chat, "#{name} (#{area}): #{response}")

        %{type: :hear, npc_id: _id, npc_name: name, from_id: _from, message: msg} ->
          socket
          |> add_feed(:hear, "#{name} heard: #{msg}")

        _ ->
          socket
      end

    {:noreply, socket}
  end

  defp add_feed(socket, _kind, text) do
    entry = %{text: text, at: DateTime.utc_now()}
    update(socket, :feed, fn f -> [entry | f] |> Enum.take(@max_feed) end)
  end

  defp mood_color(:happy), do: "bg-emerald-500"
  defp mood_color(:annoyed), do: "bg-amber-500"
  defp mood_color(:sad), do: "bg-blue-500"
  defp mood_color(_), do: "bg-slate-400"

  defp initials(name) when is_binary(name) do
    name |> String.split() |> Enum.map(&String.first/1) |> Enum.join() |> String.upcase()
  end

  defp initials(_), do: "?"
end
