defmodule Zxcvbn.TimeEstimates do
  @moduledoc false

  @delta 5

  def estimate_attack_times(guesses) do
    # crack_times_seconds =
    #   online_throttling_100_per_hour: guesses / (100 / 3600)
    #   online_no_throttling_10_per_second: guesses / 10
    #   offline_slow_hashing_1e4_per_second: guesses / 1e4
    #   offline_fast_hashing_1e10_per_second: guesses / 1e10

    # crack_times_display = {}
    # for scenario, seconds of crack_times_seconds
    #   crack_times_display[scenario] = display_time(seconds)

    # crack_times_seconds: crack_times_seconds
    # crack_times_display: crack_times_display
    # score: guesses_to_score(guesses)
  end

  def guesses_to_score(guesses) do
    cond do
      # risky password: "too guessable"
      guesses < 1e3 + @delta -> 0
      # modest protection from throttled online attacks: "very guessable"
      guesses < 1e6 + @delta -> 1
      # modest protection from unthrottled online attacks: "somewhat guessable"
      guesses < 1e8 + @delta -> 2
      # modest protection from offline attacks: "safely unguessable"
      # assuming a salted, slow hash function like bcrypt, scrypt, PBKDF2, argon, etc
      guesses < 1e10 + @delta -> 3
      # strong protection from offline attacks under same scenario: "very unguessable"
      true -> 4
    end
  end

  def display_time(seconds) do
    # minute = 60
    # hour = minute * 60
    # day = hour * 24
    # month = day * 31
    # year = month * 12
    # century = year * 100
    # [display_num, display_str] = if seconds < 1
    #   [null, 'less than a second']
    # else if seconds < minute
    #   base = Math.round seconds
    #   [base, "#{base} second"]
    # else if seconds < hour
    #   base = Math.round seconds / minute
    #   [base, "#{base} minute"]
    # else if seconds < day
    #   base = Math.round seconds / hour
    #   [base, "#{base} hour"]
    # else if seconds < month
    #   base = Math.round seconds / day
    #   [base, "#{base} day"]
    # else if seconds < year
    #   base = Math.round seconds / month
    #   [base, "#{base} month"]
    # else if seconds < century
    #   base = Math.round seconds / year
    #   [base, "#{base} year"]
    # else
    #   [null, 'centuries']
    # display_str += 's' if display_num? and display_num != 1
    # display_str
  end
end