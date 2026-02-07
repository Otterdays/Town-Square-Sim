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
  end
end
