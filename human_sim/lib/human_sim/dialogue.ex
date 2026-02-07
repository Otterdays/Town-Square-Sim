defmodule HumanSim.Dialogue do
  @moduledoc """
  Rule-based responses: topic + personality + mood → text. No ML.
  [TRACE: ARCHITECTURE.md]
  """
  alias HumanSim.Personality

  @doc "Return a response string for given topic and speaker state."
  def respond(topic, personality, mood \\ :neutral) do
    grumpy = Personality.get(personality, :grumpy)
    friendly = Personality.get(personality, :friendly)
    curious = Personality.get(personality, :curious)
    responses = responses_for(topic, grumpy, friendly, curious, mood)
    pick_weighted(responses)
  end

  defp responses_for(:greeting, grumpy, friendly, _curious, _mood) do
    [
      {1.0 - grumpy, "Hello there!"},
      {friendly, "Hi! Nice to see you."},
      {grumpy, "What do you want?"},
      {0.3, "Hey."}
    ]
  end

  defp responses_for(:weather, grumpy, _friendly, curious, _mood) do
    [
      {1.0 - grumpy, "Could be better, could be worse."},
      {curious, "I wonder if it'll rain later."},
      {grumpy, "Don't care about the weather."},
      {0.5, "Nice day, isn't it?"}
    ]
  end

  defp responses_for(:goodbye, grumpy, friendly, _curious, _mood) do
    [
      {friendly, "Take care! See you around."},
      {1.0 - grumpy, "Bye."},
      {grumpy, "Finally. Bye."}
    ]
  end

  defp responses_for(_topic, grumpy, friendly, _curious, _mood) do
    [
      {friendly, "I'm not sure what to say about that."},
      {1.0 - grumpy, "Hmm."},
      {0.2, "Okay."}
    ]
  end

  defp pick_weighted(weighted_list) when length(weighted_list) == 0, do: "..."
  defp pick_weighted(weighted_list) do
    total = Enum.reduce(weighted_list, 0, fn {w, _}, acc -> acc + w end)
    r = :rand.uniform() * max(total, 0.001)
    last = List.last(weighted_list) |> elem(1)
    case Enum.reduce_while(weighted_list, 0, fn {w, text}, acc ->
           if acc + w >= r, do: {:halt, text}, else: {:cont, acc + w}
         end) do
      text when is_binary(text) -> text
      _ -> last
    end
  end
end
