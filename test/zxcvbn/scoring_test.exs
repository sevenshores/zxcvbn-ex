defmodule Zxcvbn.ScoringTest do
  use ExUnit.Case

  alias Zxcvbn.Scoring, as: Scoring

  test "nCk" do
    testSets = [
      [0,  0, 1],
      [1,  0, 1],
      [5,  0, 1],
      [0,  1, 0],
      [0,  5, 0],
      [2,  1, 2],
      [4,  2, 6],
      [33, 7, 4_272_048]
    ]
    Enum.each(testSets, fn [n, k, result] -> assert Scoring.nCk(n, k) == result, "nCk(#{n}, #{k}) == #{result}" end)

    [n, k] = [49, 12]
    assert Scoring.nCk(n, k) == Scoring.nCk(n, n-k), "mirror identity"
    assert Scoring.nCk(n, k) == Scoring.nCk(n-1, k-1) + Scoring.nCk(n-1, k), "pascal's triangle identity"
  end
end
