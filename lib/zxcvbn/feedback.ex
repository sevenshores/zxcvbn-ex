defmodule Zxcvbn.Feedback do
  @moduledoc false

  alias Zxcvbn.Scoring

  @default_feedback %{
    warning: '',
    suggestions: [
      "Use a few words, avoid common phrases",
      "No need for symbols, digits, or uppercase letters"
    ]
  }

  def get_feedback(score, sequence) do
    # # starting feedback
    # return @default_feedback if sequence.length == 0

    # # no feedback if score is good or great.
    # return if score > 2
    #   warning: ''
    #   suggestions: []

    # # tie feedback to the longest match for longer sequences
    # longest_match = sequence[0]
    # for match in sequence[1..]
    #   longest_match = match if match.token.length > longest_match.token.length
    # feedback = @get_match_feedback(longest_match, sequence.length == 1)
    # extra_feedback = 'Add another word or two. Uncommon words are better.'
    # if feedback?
    #   feedback.suggestions.unshift extra_feedback
    #   feedback.warning = '' unless feedback.warning?
    # else
    #   feedback =
    #     warning: ''
    #     suggestions: [extra_feedback]
    # feedback
  end

  def get_match_feedback(match, is_sole_match) do
    # switch match.pattern
    #   when 'dictionary'
    #     @get_dictionary_match_feedback match, is_sole_match

    #   when 'spatial'
    #     layout = match.graph.toUpperCase()
    #     warning = if match.turns == 1
    #       'Straight rows of keys are easy to guess'
    #     else
    #       'Short keyboard patterns are easy to guess'
    #     warning: warning
    #     suggestions: [
    #       'Use a longer keyboard pattern with more turns'
    #     ]

    #   when 'repeat'
    #     warning = if match.base_token.length == 1
    #       'Repeats like "aaa" are easy to guess'
    #     else
    #       'Repeats like "abcabcabc" are only slightly harder to guess than "abc"'
    #     warning: warning
    #     suggestions: [
    #       'Avoid repeated words and characters'
    #     ]

    #   when 'sequence'
    #     warning: "Sequences like abc or 6543 are easy to guess"
    #     suggestions: [
    #       'Avoid sequences'
    #     ]

    #   when 'regex'
    #     if match.regex_name == 'recent_year'
    #       warning: "Recent years are easy to guess"
    #       suggestions: [
    #         'Avoid recent years'
    #         'Avoid years that are associated with you'
    #       ]

    #   when 'date'
    #     warning: "Dates are often easy to guess"
    #     suggestions: [
    #       'Avoid dates and years that are associated with you'
    #     ]
  end

  def get_dictionary_match_feedback(match, is_sole_match) do
    %{
      warning: feedback_warning(match, is_sole_match),
      suggestions: feedback_suggestions(match)
    }
  end

  defp feedback_warning(match = %{dictionary_name: "passwords"}, is_sole_match) do
    cond do
      is_sole_match && !(match.l33t || match.reversed) ->
        match_rank_feedback(match.rank)

      match.guesses_log10 <= 4 -> "This is a very common password"
      true -> ""
    end
  end

  defp match_rank_feedback(rank) when rank <= 10 do
    "This is a top-10 common password"
  end

  defp match_rank_feedback(rank) when rank <= 100 do
    "This is a top-100 common password"
  end

  defp match_rank_feedback(_), do: "This is similar to a commonly used password"

  defp feedback_warning(match = %{dictionary_name: "english_wikipedia"}, is_sole_match) do
    if is_sole_match, do: "A word by itself is easy to guess", else: ""
  end

  defp feedback_warning(%{dictionary_name: name}, is_sole_match = true) when name in ["surnames", "male_names", "female_names"] do
    "Names and surnames by themselves are easy to guess"
  end

  defp feedback_warning(%{dictionary_name: name}, is_sole_match = false) when name in ["surnames", "male_names", "female_names"] do
    "Common names and surnames are easy to guess"
  end

  defp feedback_warning(_, _), do: ""

  def feedback_suggestions(%{token: token, reversed: reversed, l33t: l33t}) do
    []
    |> capitalization_suggestions(token)
    |> prepend_if_true(reversed && String.length(token) <= 4, "Reversed words aren't much harder to guess")
    |> prepend_if_true(l33t, "Predictable substitutions like '@' instead of 'a' don't help very much")
  end

  defp capitalization_suggestions(suggestions, token) do
    cond do
      String.match?(token, Scoring.start_upper) ->
        ["Capitalization doesn't help very much" | suggestions]
      String.match?(token, Scoring.all_upper) && String.downcase(token) != token ->
        ["All-uppercase is almost as easy to guess as all-lowercase" | suggestions]
      true -> suggestions
    end
  end

  defp prepend_if_true(list, condition, item) do
    if condition, do: [item | list], else: list
  end
end
