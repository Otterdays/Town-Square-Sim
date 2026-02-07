defmodule HumanSim.Crowd do
  @moduledoc """
  Spawns and supervises NPCs. DynamicSupervisor for big crowds.
  [TRACE: ARCHITECTURE.md]
  """
  def spawn_npc(opts \\ []) do
    DynamicSupervisor.start_child(HumanSim.Crowd.Supervisor, {HumanSim.NPC, opts})
  end

  def spawn_npc_list(count, base_opts \\ []) do
    for i <- 1..count do
      opts =
        base_opts
        |> Keyword.put_new(:id, "npc_#{i}")
        |> Keyword.put_new(:name, "NPC-#{i}")
      spawn_npc(opts)
    end
  end

  def count do
    DynamicSupervisor.count_children(HumanSim.Crowd.Supervisor)
  end
end
