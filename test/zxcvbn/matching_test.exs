defmodule Zxcvbn.MatchingTest do
  use ExUnit.Case

  alias Zxcvbn.Matching

  describe "dictionary_match/2" do
    # @tag :pending
    test "empty passwords has no matches" do
      dicts = [%{name: "d1", words: %{"motherboard" => 1}}]

      matches = Matching.dictionary_match("", dicts)
      assert Enum.empty?(matches)
    end

    # @tag :pending
    test "empty dictionary has no matches" do
      matches = Matching.dictionary_match("password", [])
      assert Enum.empty?(matches)
    end

    # @tag :pending
    test "matches words that contain other words" do
      matches = Matching.dictionary_match("motherboard", dictionaries())
      assert Enum.count(matches) == 3

      {match, matches} = List.pop_at(matches, 0)

      expected = %{
        dict_match()
        | i: 0,
          j: 5,
          rank: 2,
          token: "mother",
          matched_word: "mother",
          dictionary_name: "d1"
      }

      assert match == expected

      {match, matches} = List.pop_at(matches, 0)

      expected = %{
        expected
        | i: 0,
          j: 10,
          rank: 1,
          token: "motherboard",
          matched_word: "motherboard"
      }

      assert match == expected

      {match, _} = List.pop_at(matches, 0)
      expected = %{expected | i: 6, j: 10, rank: 3, token: "board", matched_word: "board"}
      assert match == expected
    end

    # @tag :pending
    test "matches multiple words when they overlap" do
      matches = Matching.dictionary_match("abcdef", dictionaries())
      assert Enum.count(matches) == 2

      {match, matches} = List.pop_at(matches, 0)

      expected = %{
        dict_match()
        | i: 0,
          j: 3,
          rank: 4,
          token: "abcd",
          matched_word: "abcd",
          dictionary_name: "d1"
      }

      assert match == expected

      {match, _} = List.pop_at(matches, 0)
      expected = %{expected | i: 2, j: 5, rank: 5, token: "cdef", matched_word: "cdef"}
      assert match == expected
    end

    # @tag :pending
    test "ignores uppercasing" do
      matches = Matching.dictionary_match("BoaRdZ", dictionaries())
      assert Enum.count(matches) == 2

      {match, matches} = List.pop_at(matches, 0)

      expected = %{
        dict_match()
        | i: 0,
          j: 4,
          rank: 3,
          token: "BoaRd",
          matched_word: "board",
          dictionary_name: "d1"
      }

      assert match == expected

      {match, _} = List.pop_at(matches, 0)

      expected = %{
        expected
        | i: 5,
          j: 5,
          rank: 1,
          token: "Z",
          matched_word: "z",
          dictionary_name: "d2"
      }

      assert match == expected
    end

    # @tag :pending
    test "identifies words surrounded by non-words" do
      word = "asdf1234&*"

      matches = Matching.dictionary_match("q" <> word, dictionaries())
      {match, _} = List.pop_at(matches, 0)

      expected = %{
        dict_match()
        | i: 1,
          j: 10,
          rank: 5,
          token: "asdf1234&*",
          matched_word: "asdf1234&*",
          dictionary_name: "d2"
      }

      assert match == expected

      matches = Matching.dictionary_match("%" <> word, dictionaries())
      {match, _} = List.pop_at(matches, 0)
      assert match == expected

      matches = Matching.dictionary_match("q" <> word <> "%%", dictionaries())
      {match, _} = List.pop_at(matches, 0)
      assert match == expected

      matches = Matching.dictionary_match("%" <> word <> "pp", dictionaries())
      {match, _} = List.pop_at(matches, 0)
      assert match == expected

      matches = Matching.dictionary_match(word <> "%%", dictionaries())
      {match, _} = List.pop_at(matches, 0)

      expected = %{
        dict_match()
        | i: 0,
          j: 9,
          rank: 5,
          token: "asdf1234&*",
          matched_word: "asdf1234&*",
          dictionary_name: "d2"
      }

      assert match == expected

      matches = Matching.dictionary_match(word <> "qq", dictionaries())
      {match, _} = List.pop_at(matches, 0)
      assert match == expected
    end
  end

  describe "reverse_dictionary_match/2" do
    # @tag :pending
    test "matches against reversed words" do
      dicts = [
        %{
          name: "d1",
          words: %{
            "123" => 1,
            "321" => 2,
            "456" => 3,
            "654" => 4
          }
        }
      ]

      matches = Matching.reverse_dictionary_match("0123456789", dicts)

      expected = %{
        dict_match()
        | i: 4,
          j: 6,
          rank: 4,
          token: "456",
          matched_word: "654",
          dictionary_name: "d1",
          reversed: true
      }

      {match, matches} = List.pop_at(matches, 0)
      assert match == expected

      expected = %{
        expected
        | i: 1,
          j: 3,
          rank: 2,
          token: "123",
          matched_word: "321",
          dictionary_name: "d1",
          reversed: true
      }

      {match, _} = List.pop_at(matches, 0)
      assert match == expected
    end
  end

  defp dictionaries() do
    [
      %{
        name: "d1",
        words: %{
          "motherboard" => 1,
          "mother" => 2,
          "board" => 3,
          "abcd" => 4,
          "cdef" => 5
        }
      },
      %{
        name: "d2",
        words: %{
          "z" => 1,
          "8" => 2,
          "99" => 3,
          "$" => 4,
          "asdf1234&*" => 5
        }
      }
    ]
  end

  defp dict_match() do
    %{
      pattern: "dictionary",
      i: 0,
      j: 0,
      token: "",
      matched_word: "",
      rank: 0,
      dictionary_name: "",
      reversed: false,
      l33t: false
    }
  end
end
