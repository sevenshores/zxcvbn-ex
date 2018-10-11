defmodule Zxcvbn.TimeEstimatesTest do
  use ExUnit.Case
  alias Zxcvbn.TimeEstimates

  test "attack times" do
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

    assert 6_543_210 |> TimeEstimates.estimate_attack_times() == expected
  end

  test "display_time: outliers" do
    assert 0.56 |> TimeEstimates.display_time() == "less than a second"
    assert 3_153_600_001 |> TimeEstimates.display_time() == "centuries"
  end

  test "display_time: anything between 1 second and several years" do
    assert 35 |> TimeEstimates.display_time() == "35 seconds"

    two_mins = 2 * 60 + 35
    assert two_mins |> TimeEstimates.display_time() == "2 minutes"

    four_hours = 4 * 60 * 60 + 35
    assert four_hours |> TimeEstimates.display_time() == "4 hours"

    two_days = 2 * 24 * 60 * 60 + 35
    assert two_days |> TimeEstimates.display_time() == "2 days"

    four_months = 4 * 31 * 24 * 60 * 60 + 35
    assert four_months |> TimeEstimates.display_time() == "4 months"

    five_years = 5 * 365 * 24 * 60 * 60 + 35
    assert five_years |> TimeEstimates.display_time() == "5 years"
  end

  test "display_time: anything whenever base is 1" do
    assert 1 |> TimeEstimates.display_time() == "1 second"
    assert 60 |> TimeEstimates.display_time() == "1 minute"

    hour = 60 * 60
    assert hour |> TimeEstimates.display_time() == "1 hour"

    day = 24 * 60 * 60
    assert day |> TimeEstimates.display_time() == "1 day"

    month = 31 * 24 * 60 * 60
    assert month |> TimeEstimates.display_time() == "1 month"

    year = 365 * 24 * 60 * 60
    assert year |> TimeEstimates.display_time() == "1 year"

    century = 100 * 365 * 24 * 60 * 60
    assert century |> TimeEstimates.display_time() == "1 century"
  end

  test "float input is allowed" do
    assert 0.45 |> TimeEstimates.display_time() == "less than a second"
    assert 3_153_600_000.0 |> TimeEstimates.display_time() == "1 century"
    assert 60.0 |> TimeEstimates.display_time() == "1 minute"
  end
end
