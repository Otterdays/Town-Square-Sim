defmodule HumanSimTest do
  use ExUnit.Case, async: false

  describe "Item" do
    test "interact bench use when available" do
      item = %HumanSim.Item{id: :b1, type: :bench, area_id: :sq, state: :available, metadata: %{}}
      {effect, updated} = HumanSim.Item.interact(item, :use)
      assert effect == :sat_down
      assert updated.state == :in_use
    end

    test "interact bench use when in_use returns no change" do
      item = %HumanSim.Item{id: :b1, type: :bench, area_id: :sq, state: :in_use, metadata: %{}}
      {effect, updated} = HumanSim.Item.interact(item, :use)
      assert effect == :already_in_use
      assert updated.state == :in_use
    end
  end

  describe "Personality" do
    test "new/1 merges defaults" do
      p = HumanSim.Personality.new([])
      assert HumanSim.Personality.get(p, :friendly) == 0.5
      assert HumanSim.Personality.get(p, :grumpy) == 0.0
    end

    test "new/1 accepts overrides" do
      p = HumanSim.Personality.new(grumpy: 0.8)
      assert HumanSim.Personality.get(p, :grumpy) == 0.8
    end
  end

  describe "Dialogue" do
    test "respond returns a string" do
      p = HumanSim.Personality.new([])
      resp = HumanSim.Dialogue.respond(:greeting, p)
      assert is_binary(resp)
      assert String.length(resp) > 0
    end
  end

  describe "World" do
    test "put_item and get_item" do
      item = %HumanSim.Item{id: :test_item_1, type: :object, area_id: :test, state: :available, metadata: %{}}
      assert :ok == HumanSim.World.put_item(item)
      assert {:ok, ^item} = HumanSim.World.get_item(:test_item_1)
    end

    test "list_items_in_area" do
      HumanSim.World.put_item(%HumanSim.Item{id: :area_a_1, type: :bench, area_id: :area_a, state: :available, metadata: %{}})
      items = HumanSim.World.list_items_in_area(:area_a)
      assert length(items) >= 1
      assert Enum.any?(items, &(&1.id == :area_a_1))
    end
  end

  describe "NPC" do
    test "spawn and chat" do
      id = "test_npc_#{System.unique_integer([:positive])}"
      assert {:ok, _pid} = HumanSim.Crowd.spawn_npc(id: id, name: "Test", area_id: :square)
      resp = HumanSim.NPC.say(id, "Hello")
      assert is_binary(resp)
      HumanSim.NPC.chat(id, :weather)
    end

    test "broadcasts item_interact on successful use_item" do
      Phoenix.PubSub.subscribe(HumanSim.PubSub, "sim:events")
      area = :item_broadcast_area
      bench_id = "bench_bc_#{System.unique_integer([:positive])}"
      npc_id = "npc_bc_#{System.unique_integer([:positive])}"

      :ok = HumanSim.World.register_area(area)

      HumanSim.World.put_item(%HumanSim.Item{
        id: bench_id,
        type: :bench,
        area_id: area,
        state: :available,
        metadata: %{}
      })

      assert {:ok, _pid} =
               HumanSim.Crowd.spawn_npc(id: npc_id, name: "ItemBroadcast", area_id: area)

      assert {:ok, :sat_down, _} = HumanSim.NPC.use_item(npc_id, bench_id, :use)

      assert_receive {:sim_event,
                      %{
                        type: :item_interact,
                        effect: :sat_down,
                        item_id: ^bench_id,
                        npc_id: ^npc_id,
                        item_type: :bench
                      }},
                     500
    end
  end
end
