defmodule HumanSimWeb.SceneSnapshot do
  @moduledoc """
  Jason-safe scene payload for the Town Square 3D hook. [TRACE: ARCHITECTURE.md]
  """
  alias HumanSim.Item

  @areas [:square, :shop, :park, :tavern]

  @doc "Zone layout on the XZ plane (shared by server hints and client)."
  def zones do
    %{
      square: %{origin: %{x: -5.0, z: -5.0}, size: 9.0},
      shop: %{origin: %{x: 4.0, z: -5.0}, size: 9.0},
      park: %{origin: %{x: -5.0, z: 4.0}, size: 9.0},
      tavern: %{origin: %{x: 4.0, z: 4.0}, size: 9.0}
    }
  end

  @doc "Full scene for scene_init."
  def build(npcs, items_by_area) when is_list(npcs) and is_map(items_by_area) do
    z = zones()

    %{
      "version" => 1,
      "zones" => zones_json(z),
      "npcs" => Enum.map(npcs, &npc_entry(&1, z)),
      "items" =>
        items_by_area
        |> Enum.sort_by(fn {k, _} -> Enum.find_index(@areas, &(&1 == k)) || 99 end)
        |> Enum.flat_map(fn {area_id, items} ->
          Enum.map(items, &item_entry(&1, area_id, z))
        end)
    }
  end

  @doc "Single NPC entry for scene_patch (e.g. after move)."
  def npc_entry(%{id: id, name: name, area_id: area_id, mood: mood}, zones_map \\ nil) do
    z = zones_map || zones()
    pos = npc_slot_position(id, area_id, z)

    %{
      "id" => id_string(id),
      "name" => name,
      "areaId" => to_string(area_id),
      "mood" => to_string(mood),
      "x" => pos.x,
      "y" => pos.y,
      "z" => pos.z
    }
  end

  @doc "Single item entry for scene_patch."
  def item_entry(%Item{} = item, area_id, zones_map \\ nil) do
    z = zones_map || zones()
    zone = Map.get(z, area_id) || Map.get(z, :square)
    anchor = Map.get(item.metadata || %{}, :anchor) || %{x: 0.0, z: 0.0}
    ax = Map.get(anchor, :x, 0.0)
    az = Map.get(anchor, :z, 0.0)

    %{
      "id" => id_string(item.id),
      "type" => to_string(item.type),
      "areaId" => to_string(area_id),
      "state" => to_string(item.state),
      "x" => zone.origin.x + ax,
      "y" => 0.0,
      "z" => zone.origin.z + az
    }
  end

  defp zones_json(zones_map) do
    Enum.map(@areas, fn area_id ->
      z = Map.get(zones_map, area_id)

      %{
        "id" => to_string(area_id),
        "origin" => %{"x" => z.origin.x, "z" => z.origin.z},
        "size" => z.size
      }
    end)
  end

  defp npc_slot_position(npc_id, area_id, zones_map) do
    zone = Map.get(zones_map, area_id) || Map.get(zones_map, :square)
    slots = 8
    h = :erlang.phash2({npc_id, area_id})
    slot = rem(abs(h), slots)
    grid_x = rem(slot, 4)
    grid_z = div(slot, 4)
    cell = zone.size / 5.0
    ox = zone.origin.x + (grid_x - 1.5) * cell
    oz = zone.origin.z + (grid_z - 1.0) * cell
    %{x: ox, y: 0.9, z: oz}
  end

  defp id_string(id) when is_atom(id), do: Atom.to_string(id)
  defp id_string(id) when is_binary(id), do: id
  defp id_string(id), do: inspect(id)

end
