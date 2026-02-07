defmodule HumanSim.Personality do
  @moduledoc """
  Trait-based personality for NPCs. Affects dialogue and reactions.
  [TRACE: ARCHITECTURE.md]
  """
  defstruct [:traits]
  @type t :: %__MODULE__{traits: %{required(atom()) => number()}}

  @doc "Build personality from keyword list. Values 0.0–1.0."
  def new(traits \\ []) do
    default = %{friendly: 0.5, curious: 0.5, grumpy: 0.0, shy: 0.0, bold: 0.5}
    merged = Enum.reduce(traits, default, fn {k, v}, acc -> Map.put(acc, k, v) end)
    %__MODULE__{traits: merged}
  end

  @doc "Get trait value; 0.0 if missing."
  def get(%__MODULE__{traits: t}, key), do: Map.get(t, key, 0.0)

  @doc "Mood modifier: positive = happier, negative = grumpier. Affects response tone."
  def apply_mood(personality, mood_delta) when is_number(mood_delta) do
    grumpy = get(personality, :grumpy) + mood_delta * 0.3
    friendly = get(personality, :friendly) - mood_delta * 0.2
    personality
    |> Map.get(:traits)
    |> Map.put(:grumpy, clamp(grumpy))
    |> then(&Map.put(&1, :friendly, clamp(friendly)))
    |> then(&%__MODULE__{traits: &1})
  end

  def apply_mood(personality, _), do: personality

  defp clamp(n) when n < 0, do: 0.0
  defp clamp(n) when n > 1, do: 1.0
  defp clamp(n), do: n
end
