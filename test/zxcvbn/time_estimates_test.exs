defmodule Zxcvbn.TimeEstimatesTest do
  use ExUnit.Case

  alias Zxcvbn.TimeEstimates

  describe "estimate_attack_times/1" do
    test "returns exptected" do
      expected = %{
        crack_times_seconds: %{
          online_throttling_100_per_hour: 18.175583333333332,
          online_no_throttling_10_per_second: 654_321.0,
          offline_slow_hashing_1e4_per_second: 654.321,
          offline_fast_hashing_1e10_per_second: 6.54321e-4
        },
        crack_times_display: %{
          online_throttling_100_per_hour: "18 seconds",
          online_no_throttling_10_per_second: "7 days",
          offline_slow_hashing_1e4_per_second: "10 minutes",
          offline_fast_hashing_1e10_per_second: "less than a second"
        },
        score: 2
      }

      assert TimeEstimates.estimate_attack_times(6_543_210) == expected
    end
  end

  describe "display_time/1" do
    test "handles outliers" do
      assert TimeEstimates.display_time(0.56) == "less than a second"
      assert TimeEstimates.display_time(3_153_600_001) == "centuries"
    end

    test "handles anything between 1 second and several years" do
      two_mins = 2 * 60 + 35
      four_hours = 4 * 60 * 60 + 35
      two_days = 2 * 24 * 60 * 60 + 35
      four_months = 4 * 31 * 24 * 60 * 60 + 35
      five_years = 5 * 365 * 24 * 60 * 60 + 35

      assert TimeEstimates.display_time(35) == "35 seconds"
      assert TimeEstimates.display_time(two_mins) == "2 minutes"
      assert TimeEstimates.display_time(four_hours) == "4 hours"
      assert TimeEstimates.display_time(two_days) == "2 days"
      assert TimeEstimates.display_time(four_months) == "4 months"
      assert TimeEstimates.display_time(five_years) == "5 years"
    end

    test "handles anything whenever base is 1" do
      minute = 60
      hour = 60 * 60
      day = 24 * 60 * 60
      month = 31 * 24 * 60 * 60
      year = 365 * 24 * 60 * 60
      century = 100 * 365 * 24 * 60 * 60

      assert TimeEstimates.display_time(1) == "1 second"
      assert TimeEstimates.display_time(minute) == "1 minute"
      assert TimeEstimates.display_time(hour) == "1 hour"
      assert TimeEstimates.display_time(day) == "1 day"
      assert TimeEstimates.display_time(month) == "1 month"
      assert TimeEstimates.display_time(year) == "1 year"
      assert TimeEstimates.display_time(century) == "1 century"
    end

    test "handles float input" do
      assert TimeEstimates.display_time(0.45) == "less than a second"
      assert TimeEstimates.display_time(60.0) == "1 minute"
      assert TimeEstimates.display_time(3_153_600_000.0) == "1 century"
    end
  end
end
