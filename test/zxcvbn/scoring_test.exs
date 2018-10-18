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

  test 'regex guesses alpha_lower' do
    match = %{
      token: "aizocdk",
      regex_name: :alpha_lower,
      regex_match: ['aizocdk']
    }

    msg = "guesses of 26^7 for 7-char lowercase regex"
    assert Scoring.regex_guesses(match) == :math.pow(26, 7), msg
  end

  test 'regex guesses alphanumeric' do
    match = %{
      token: "ag7C8",
      regex_name: :alphanumeric,
      regex_match: ["ag7C8"]
    }

    msg = "guesses of 62^5 for 5-char alphanumeric regex"

    assert Scoring.regex_guesses(match) == :math.pow(2 * 26 + 10, 5), msg
  end

  test 'regex guesses recent_year distant' do
    match = %{
      token: "1972",
      regex_name: :recent_year,
      regex_match: ["1972"]
    }

    msg = "guesses of |year - REFERENCE_YEAR| for distant year matches"
    assert Scoring.regex_guesses(match) == abs(Scoring.reference_year() - 1972), msg
  end

  test 'regex guesses recent_year close' do
    match = %{
      token: "2005",
      regex_name: :recent_year,
      regex_match: ["2005"]
    }

    msg = "guesses of MIN_YEAR_SPACE for a year close to REFERENCE_YEAR"
    result = Scoring.regex_guesses(match)
    expected = Scoring.min_year_space()
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
