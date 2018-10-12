defmodule Zxcvbn.TimeEstimates do
  @moduledoc false

  @delta 5
  @second 1
  @minute 60
  @hour 3600
  @day 86_400
  @month 2_678_400
  @year 31_536_000
  @century 3_153_600_000

  def estimate_attack_times(guesses) do
    crack_times_seconds = %{
      online_throttling_100_per_hour: guesses / 100 / 3600,
      online_no_throttling_10_per_second: guesses / 10,
      offline_slow_hashing_1e4_per_second: guesses / 1.0e4,
      offline_fast_hashing_1e10_per_second: guesses / 1.0e10
    }

    crack_times_display =
      crack_times_seconds
      |> Map.keys()
      |> Enum.reduce(%{}, fn key, acc ->
        Map.update(acc, key, display_time(crack_times_seconds[key]), & &1)
      end)

    %{
      crack_times_seconds: crack_times_seconds,
      crack_times_display: crack_times_display,
      score: guesses_to_score(guesses)
    }
  end

  def guesses_to_score(guesses) do
    cond do
      # risky password: "too guessable"
      guesses < 1.0e3 + @delta -> 0
      # modest protection from throttled online attacks: "very guessable"
      guesses < 1.0e6 + @delta -> 1
      # modest protection from unthrottled online attacks: "somewhat guessable"
      guesses < 1.0e8 + @delta -> 2
      # modest protection from offline attacks: "safely unguessable"
      # assuming a salted, slow hash function like bcrypt, scrypt, PBKDF2, argon, etc
      guesses < 1.0e10 + @delta -> 3
      # strong protection from offline attacks under same scenario: "very unguessable"
      true -> 4
    end
  end

  def display_time(seconds) when is_number(seconds) and seconds < @second,
    do: "less than a second"

  def display_time(seconds) when is_number(seconds) and seconds > @century,
    do: "centuries"

  def display_time(@century), do: "1 century"
  def display_time(3_153_600_000.0), do: "1 century"

  def display_time(seconds) when seconds < @minute,
    do: {trunc(seconds), "second"} |> tuple_to_desc

  def display_time(seconds) when seconds < @hour, do: seconds |> to_desc(@minute, "minute")
  def display_time(seconds) when seconds < @day, do: seconds |> to_desc(@hour, "hour")
  def display_time(seconds) when seconds < @month, do: seconds |> to_desc(@day, "day")
  def display_time(seconds) when seconds < @year, do: seconds |> to_desc(@month, "month")
  def display_time(seconds) when seconds < @century, do: seconds |> to_desc(@year, "year")

  defp to_desc(seconds, divider, desc) do
    base = seconds / divider
    {trunc(base), desc} |> tuple_to_desc
  end

  defp tuple_to_desc({1, desc}), do: "1 #{desc}"
  defp tuple_to_desc({base, desc}), do: "#{base} #{desc}s"
end
