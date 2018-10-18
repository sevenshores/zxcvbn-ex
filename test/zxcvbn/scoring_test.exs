defmodule Zxcvbn.ScoringTest do
  use ExUnit.Case

  alias Zxcvbn.Scoring, as: Scoring

  test "nCk" do
    test_sets = [
      [0, 0, 1],
      [1, 0, 1],
      [5, 0, 1],
      [0, 1, 0],
      [0, 5, 0],
      [2, 1, 2],
      [4, 2, 6],
      [33, 7, 4_272_048]
    ]

    Enum.each(test_sets, fn [n, k, result] ->
      assert Scoring.nCk(n, k) == result, "nCk(#{n}, #{k}) == #{result}"
    end)

    [n, k] = [49, 12]
    assert Scoring.nCk(n, k) == Scoring.nCk(n, n - k), "mirror identity"

    assert Scoring.nCk(n, k) == Scoring.nCk(n - 1, k - 1) + Scoring.nCk(n - 1, k),
           "pascal's triangle identity"
  end

  test 'date guesses' do
    match = %{
      token: "1123",
      separator: "",
      has_full_year: false,
      year: 1923,
      month: 1,
      day: 1
    }

    result = Scoring.date_guesses(match)
    expected = 365 * abs(Scoring.reference_year() - match[:year])
    msg = "Expected guesses for dates to be #{expected}, but got: #{result}"
    assert expected == result, msg
  end

  test 'date with separator' do
    match = %{
      token: "1/1/2010",
      separator: "/",
      has_full_year: true,
      year: 2010,
      month: 1,
      day: 1
    }

    result = Scoring.date_guesses(match)
    expected = 365 * Scoring.min_year_space() * 4
    msg = "Recent years assume MIN_YEAR_SPACE. Extra guesses are added for separators."
    assert expected == result, msg
  end

  test "uppercase variants" do
    test_sets = [
      ["", 1],
      ["a", 1],
      ["A", 2],
      ["abcdef", 1],
      ["Abcdef", 2],
      ["abcdeF", 2],
      ["ABCDEF", 2],
      ["aBcdef", Scoring.nCk(6, 1)],
      ["aBcDef", Scoring.nCk(6, 1) + Scoring.nCk(6, 2)],
      ["ABCDEf", Scoring.nCk(6, 1)],
      ["aBCDEf", Scoring.nCk(6, 1) + Scoring.nCk(6, 2)],
      ["ABCdef", Scoring.nCk(6, 1) + Scoring.nCk(6, 2) + Scoring.nCk(6, 3)]
    ]

    Enum.each(
      test_sets,
      fn [word, expected] ->
        actual = Scoring.uppercase_variations(%{token: word})

        assert expected == actual,
               "expected guess multiplier of #{word} is #{expected}, actual: #{actual} "
      end
    )
  end
end
