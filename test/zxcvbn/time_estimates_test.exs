defmodule Zxcvbn.TimeEstimatesTest do
  
  use ExUnit.Case
  alias Zxcvbn.TimeEstimates

  test "outliers" do
    assert 0.56 |> TimeEstimates.display_time == "less than a second"
    assert 1.0e10 |> TimeEstimates.display_time == "centuries"
  end

  test "anything between 1 second and several years" do
    assert 35 |> TimeEstimates.display_time == "35 seconds"
    assert 2 * 60 + 35 |> TimeEstimates.display_time == "2 minutes"
    assert 4 * 60 * 60 + 35 |> TimeEstimates.display_time == "4 hours"
    assert 2 * 24 * 60 * 60 + 35 |> TimeEstimates.display_time == "2 days"
    assert 4 * 31 * 24 * 60 * 60 + 35 |> TimeEstimates.display_time == "4 months"
    assert 5 * 365 * 24 * 60 * 60 + 35 |> TimeEstimates.display_time == "5 years"
  end

  test "anything whenever base is 1" do
    assert 1 |> TimeEstimates.display_time == "1 second"
    assert 60 |> TimeEstimates.display_time == "1 minute"
    assert 60 * 60 + 35 |> TimeEstimates.display_time == "1 hour"
    assert 24 * 60 * 60 |> TimeEstimates.display_time == "1 day"
    assert 31 * 24 * 60 * 60 |> TimeEstimates.display_time == "1 month"
    assert 365 * 24 * 60 * 60 |> TimeEstimates.display_time == "1 year"
  end

end
