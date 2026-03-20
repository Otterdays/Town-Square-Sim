defmodule HumanSimWeb.TownSquareLive do
  @moduledoc "LiveView dashboard for Town Square Sim. [TRACE: ARCHITECTURE.md]"
  use HumanSimWeb, :live_view

  alias HumanSimWeb.SceneSnapshot
  alias HumanSim.World

  @areas [:square, :shop, :park, :tavern]
  @area_labels %{square: "Square", shop: "Shop", park: "Park", tavern: "Tavern"}
  @max_feed 20

  @impl true
  def mount(_params, _session, socket) do
    HumanSim.Events.subscribe()
    snapshot = HumanSim.SimRunner.get_snapshot()

    npcs_map =
      Map.new(snapshot.npcs, fn n -> {n.id, %{name: n.name, area_id: n.area_id, mood: n.mood}} end)

    scene = SceneSnapshot.build(snapshot.npcs, snapshot.items_by_area)

    socket =
      socket
      |> assign(:npcs, npcs_map)
      |> assign(:npc_count, snapshot.npc_count)
      |> assign(:tick, snapshot.tick)
      |> assign(:items_by_area, snapshot.items_by_area)
      |> assign(:feed, [])
      |> assign(:area_labels, @area_labels)
      |> assign(:areas, @areas)
      |> push_event("scene_init", scene)

    {:ok, socket}
  end

  @impl true
  def handle_info({:sim_event, event}, socket) do
    socket =
      case event do
        %{type: :move, npc_id: id, npc_name: name, to_area: to_area} = ev ->
          socket
          |> update(:npcs, &Map.put(&1, id, %{name: name, area_id: to_area, mood: :neutral}))
          |> add_feed(:move, "#{name} moved to #{@area_labels[to_area] || to_area}")
          |> push_scene_patch_move(ev)

        %{type: :chat, npc_id: _id, npc_name: name, area_id: area_id, response: response} ->
          area = @area_labels[area_id] || area_id
          socket
          |> add_feed(:chat, "#{name} (#{area}): #{response}")

        %{type: :hear, npc_id: _id, npc_name: name, from_id: _from, message: msg} ->
          socket
          |> add_feed(:hear, "#{name} heard: #{msg}")

        %{type: :item_interact} = ev ->
          socket
          |> handle_item_interact(ev)

        _ ->
          socket
      end

    {:noreply, socket}
  end

  defp push_scene_patch_move(socket, %{npc_id: id, npc_name: name, to_area: to_area}) do
    entry = SceneSnapshot.npc_entry(%{id: id, name: name, area_id: to_area, mood: :neutral})
    push_event(socket, "scene_patch", %{"npcs" => [entry]})
  end

  defp handle_item_interact(socket, ev) do
    %{
      npc_id: npc_id,
      npc_name: npc_name,
      area_id: area_id,
      item_id: item_id,
      item_type: item_type,
      effect: effect
    } = ev

    socket =
      case World.get_item(item_id) do
        {:ok, item} ->
          socket
          |> replace_item_in_area(area_id, item)
          |> add_feed(
            :item,
            "#{npc_name} interacted with #{item_type} (#{effect_to_label(effect)})"
          )
          |> push_item_scene_patch(npc_id, item_id, effect, item, area_id)

        _ ->
          add_feed(
            socket,
            :item,
            "#{npc_name} interacted with #{item_type} (#{effect_to_label(effect)})"
          )
      end

    socket
  end

  defp replace_item_in_area(socket, area_id, new_item) do
    update(socket, :items_by_area, fn by ->
      list = Map.get(by, area_id, [])

      new_list =
        Enum.map(list, fn i ->
          if i.id == new_item.id, do: new_item, else: i
        end)

      Map.put(by, area_id, new_list)
    end)
  end

  defp push_item_scene_patch(socket, npc_id, item_id, effect, item, area_id) do
    z = SceneSnapshot.zones()

    patch = %{
      "items" => [SceneSnapshot.item_entry(item, area_id, z)],
      "interact" => %{
        "npcId" => client_id(npc_id),
        "itemId" => client_id(item_id),
        "effect" => effect_string(effect)
      }
    }

    push_event(socket, "scene_patch", patch)
  end

  defp client_id(id) when is_atom(id), do: Atom.to_string(id)
  defp client_id(id) when is_binary(id), do: id
  defp client_id(id), do: inspect(id)

  defp effect_string(e) when is_atom(e), do: Atom.to_string(e)
  defp effect_string(e), do: to_string(e)

  defp effect_to_label(:sat_down), do: "sat down"
  defp effect_to_label(:already_in_use), do: "already in use"
  defp effect_to_label(:picked_up), do: "picked up"
  defp effect_to_label(:opened), do: "opened"
  defp effect_to_label(:closed), do: "closed"
  defp effect_to_label(:no_effect), do: "no effect"
  defp effect_to_label(:description), do: "inspected"
  defp effect_to_label(other), do: inspect(other)

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
