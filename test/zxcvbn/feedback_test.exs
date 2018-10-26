defmodule Zxcvbn.FeedbackTest do
  use ExUnit.Case
  alias Zxcvbn.Feedback

  describe "get_dictionary_match_feedback/2" do
    setup do
      %{
        token: "",
        l33t: false,
        reversed: false,
        rank: 0,
        dictionary_name: "",
        guesses_log10: 0
      }
    end

    test "warns when rank is less than 10", match do
      match = %{match | rank: 4, dictionary_name: "passwords"}
      expected = "This is a top-10 common password"
      %{warning: warning} = Feedback.get_dictionary_match_feedback(match, true)

      assert warning == expected
    end

    test "warns when rank is less than 100", match do
      match = %{match | rank: 40, dictionary_name: "passwords"}
      expected = "This is a top-100 common password"
      %{warning: warning} = Feedback.get_dictionary_match_feedback(match, true)

      assert warning == expected
    end

    test "warns it is similar to a common password", match do
      match = %{match | rank: 400, dictionary_name: "passwords"}
      expected = "This is similar to a commonly used password"
      %{warning: warning} = Feedback.get_dictionary_match_feedback(match, true)

      assert warning == expected
    end

    test "warns it is a very common password when not a sole match", match do
      match = %{match | dictionary_name: "passwords"}
      expected = "This is a very common password"
      %{warning: warning} = Feedback.get_dictionary_match_feedback(match, false)

      assert warning == expected
    end

    test "warns it is a very common password when l33t", match do
      match = %{match | dictionary_name: "passwords", l33t: true}
      expected = "This is a very common password"
      %{warning: warning} = Feedback.get_dictionary_match_feedback(match, true)

      assert warning == expected
    end

    test "warns it is a very common password when reversed", match do
      match = %{match | dictionary_name: "passwords", reversed: true}
      expected = "This is a very common password"
      %{warning: warning} = Feedback.get_dictionary_match_feedback(match, true)

      assert warning == expected
    end

    test "warns when a sole match is an english word", match do
      match = %{match | dictionary_name: "english_wikipedia"}
      expected = "A word by itself is easy to guess"
      %{warning: warning} = Feedback.get_dictionary_match_feedback(match, true)

      assert warning == expected
    end

    test "warns when a sole match is a surname", match do
      match = %{match | dictionary_name: "surnames"}
      expected = "Names and surnames by themselves are easy to guess"
      %{warning: warning} = Feedback.get_dictionary_match_feedback(match, true)

      assert warning == expected
    end

    test "warns when a sole match is a male name", match do
      match = %{match | dictionary_name: "male_names"}
      expected = "Names and surnames by themselves are easy to guess"
      %{warning: warning} = Feedback.get_dictionary_match_feedback(match, true)

      assert warning == expected
    end

    test "warns when a sole match is a female name", match do
      match = %{match | dictionary_name: "female_names"}
      expected = "Names and surnames by themselves are easy to guess"
      %{warning: warning} = Feedback.get_dictionary_match_feedback(match, true)

      assert warning == expected
    end

    test "no warnings returns an empty string", match do
      %{warning: warning} = Feedback.get_dictionary_match_feedback(match, true)

      assert warning == ""
    end

    test "adds suggestion for token starting with a capital letter", match do
      match = %{match | token: "Capitalized" }
      %{suggestions: [suggestion]} = Feedback.get_dictionary_match_feedback(match, true)

      assert suggestion == "Capitalization doesn't help very much"
    end

    test "adds suggestion for all caps", match do
      match = %{match | token: "CAPITALIZED" }
      %{suggestions: [suggestion]} = Feedback.get_dictionary_match_feedback(match, true)

      assert suggestion == "All-uppercase is almost as easy to guess as all-lowercase"
    end

    test "adds suggestion if token is a short reversed word", match do
      match = %{match | token: "tab", reversed: true }
      %{suggestions: [suggestion]} = Feedback.get_dictionary_match_feedback(match, true)

      assert suggestion == "Reversed words aren't much harder to guess"
    end

    test "adds suggestion for basic substitutions", match do
      match = %{match | token: "b@asic$substitution", l33t: true }
      %{suggestions: [suggestion]} = Feedback.get_dictionary_match_feedback(match, true)

      assert suggestion == "Predictable substitutions like '@' instead of 'a' don't help very much"
    end

    test "suggestions stack", match do
      match = %{match | token: "Tab", l33t: true, reversed: true }
      %{suggestions: suggestions} = Feedback.get_dictionary_match_feedback(match, true)
      expected = [
        "Predictable substitutions like '@' instead of 'a' don't help very much",
        "Reversed words aren't much harder to guess",
        "Capitalization doesn't help very much"
      ]

      assert suggestions == expected
    end

    test "suggestions is empty array when password is strong", match do
      match = %{match | token: "imaginethiswasagoodpassword"}
      %{suggestions: suggestions} = Feedback.get_dictionary_match_feedback(match, true)

      assert suggestions == []
    end
  end
end
