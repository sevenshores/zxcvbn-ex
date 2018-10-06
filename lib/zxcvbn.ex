defmodule Zxcvbn do
  @moduledoc """
  Documentation for Zxcvbn.
  """

  alias Zxcvbn.Feedback
  alias Zxcvbn.Matching
  alias Zxcvbn.Scoring
  alias Zxcvbn.TimeEstimates

  @doc """
  Checks a password.

  ## Examples

      iex> Zxcvbn.check("password123")
      0

  """
  def check(password, user_inputs \\ []) when is_binary(password) when is_list(user_inputs) do
    0

    # start = (new Date()).getTime()

    # # reset the user inputs matcher on a per-request basis to keep things stateless
    # sanitized_inputs = []

    # for arg in user_inputs
    #   if typeof arg in ["string", "number", "boolean"]
    #     sanitized_inputs.push arg.toString().toLowerCase()

    # matching.set_user_input_dictionary sanitized_inputs
    # matches = matching.omnimatch password
    # result = scoring.most_guessable_match_sequence password, matches
    # result.calc_time = time() - start
    # attack_times = time_estimates.estimate_attack_times result.guesses

    # for prop, val of attack_times
    #   result[prop] = val

    # result.feedback = feedback.get_feedback result.score, result.sequence

    # result
  end
end
