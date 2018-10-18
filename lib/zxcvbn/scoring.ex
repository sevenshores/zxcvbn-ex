defmodule Zxcvbn.Scoring do
  @moduledoc false

  @bruteforce_cardinality 10
  @min_guesses_before_growing_sequence 10_000
  @min_submatch_guesses_single_char 10
  @min_submatch_guesses_multi_char 50

  # Used in regex and date guesses
  @min_year_space 20
  def min_year_space, do: @min_year_space

  @reference_year Date.utc_today().year
  def reference_year, do: @reference_year

  # Used in variations
  @start_upper ~r/^[A-Z][^A-Z]+$/
  @end_upper ~r/^[^A-Z]+[A-Z]$/
  @all_upper ~r/^[^a-z]+$/
  @all_lower ~r/^[^A-Z]+$/

  @doc """
  Search most guessable match sequence

  Takes a sequence of overlapping matches, returns the non-overlapping sequence
  with minimum guesses. the following is a `O(l_max * (n + m))` dynamic
  programming algorithm for a `length - n` password with `m` candidate matches.
  `l_max` is the maximum optimal sequence length spanning each prefix of the
  password. In practice it rarely exceeds `5` and the search terminates rapidly.

  The optimal "minimum guesses" sequence is here defined to be the sequence that
  minimizes the following function:

      g = l! * Product(m.guesses for m in sequence) + D^(l - 1)

  where `l` is the length of the sequence.

  The factorial term is the number of ways to order `l` patterns.

  The `D^(l-1)` term is another length penalty, roughly capturing the idea that
  an attacker will try lower-length sequences first before trying `length - l`
  sequences.

  For example, consider a sequence that is date-repeat-dictionary.

   - an attacker would need to try other date-repeat-dictionary combinations,
     hence the product term.
   - an attacker would need to try repeat-date-dictionary, dictionary-repeat-date,
     ..., hence the factorial term.
   - an attacker would also likely try length-1 (dictionary) and length-2 (dictionary-date)
     sequences before length-3. assuming at minimum D guesses per pattern type,
     D^(l-1) approximates Sum(D^i for i in [1..l-1])

  """
  def most_guessable_match_sequence(password, matches, exclude_additive \\ false) do
    # n = password.length

    # # partition matches into sublists according to ending index j
    # matches_by_j = ([] for _ in [0...n])
    # for m in matches
    #   matches_by_j[m.j].push m
    # # small detail: for deterministic output, sort each sublist by i.
    # for lst in matches_by_j
    #   lst.sort (m1, m2) -> m1.i - m2.i

    # optimal =
    #   # optimal.m[k][l] holds final match in the best length-l match sequence covering the
    #   # password prefix up to k, inclusive.
    #   # if there is no length-l sequence that scores better (fewer guesses) than
    #   # a shorter match sequence spanning the same prefix, optimal.m[k][l] is undefined.
    #   m:  ({} for _ in [0...n])

    #   # same structure as optimal.m -- holds the product term Prod(m.guesses for m in sequence).
    #   # optimal.pi allows for fast (non-looping) updates to the minimization function.
    #   pi: ({} for _ in [0...n])

    #   # same structure as optimal.m -- holds the overall metric.
    #   g:  ({} for _ in [0...n])

    # # helper: considers whether a length-l sequence ending at match m is better (fewer guesses)
    # # than previously encountered sequences, updating state if so.
    # update = (m, l) =>
    #   k = m.j
    #   pi = @estimate_guesses m, password
    #   if l > 1
    #     # we're considering a length-l sequence ending with match m:
    #     # obtain the product term in the minimization function by multiplying m's guesses
    #     # by the product of the length-(l-1) sequence ending just before m, at m.i - 1.
    #     pi *= optimal.pi[m.i - 1][l - 1]
    #   # calculate the minimization func
    #   g = @factorial(l) * pi
    #   unless _exclude_additive
    #     g += Math.pow(MIN_GUESSES_BEFORE_GROWING_SEQUENCE, l - 1)
    #   # update state if new best.
    #   # first see if any competing sequences covering this prefix, with l or fewer matches,
    #   # fare better than this sequence. if so, skip it and return.
    #   for competing_l, competing_g of optimal.g[k]
    #     continue if competing_l > l
    #     return if competing_g <= g
    #   # this sequence might be part of the final optimal sequence.
    #   optimal.g[k][l] = g
    #   optimal.m[k][l] = m
    #   optimal.pi[k][l] = pi

    # # helper: evaluate bruteforce matches ending at k.
    # bruteforce_update = (k) =>
    #   # see if a single bruteforce match spanning the k-prefix is optimal.
    #   m = make_bruteforce_match(0, k)
    #   update(m, 1)
    #   for i in [1..k]
    #     # generate k bruteforce matches, spanning from (i=1, j=k) up to (i=k, j=k).
    #     # see if adding these new matches to any of the sequences in optimal[i-1]
    #     # leads to new bests.
    #     m = make_bruteforce_match(i, k)
    #     for l, last_m of optimal.m[i-1]
    #       l = parseInt(l)
    #       # corner: an optimal sequence will never have two adjacent bruteforce matches.
    #       # it is strictly better to have a single bruteforce match spanning the same region:
    #       # same contribution to the guess product with a lower length.
    #       # --> safe to skip those cases.
    #       continue if last_m.pattern == 'bruteforce'
    #       # try adding m to this length-l sequence.
    #       update(m, l + 1)

    # # helper: make bruteforce match objects spanning i to j, inclusive.
    # make_bruteforce_match = (i, j) =>
    #   pattern: 'bruteforce'
    #   token: password[i..j]
    #   i: i
    #   j: j

    # # helper: step backwards through optimal.m starting at the end,
    # # constructing the final optimal match sequence.
    # unwind = (n) =>
    #   optimal_match_sequence = []
    #   k = n - 1
    #   # find the final best sequence length and score
    #   l = undefined
    #   g = Infinity
    #   for candidate_l, candidate_g of optimal.g[k]
    #     if candidate_g < g
    #       l = candidate_l
    #       g = candidate_g

    #   while k >= 0
    #     m = optimal.m[k][l]
    #     optimal_match_sequence.unshift m
    #     k = m.i - 1
    #     l--
    #   optimal_match_sequence

    # for k in [0...n]
    #   for m in matches_by_j[k]
    #     if m.i > 0
    #       for l of optimal.m[m.i - 1]
    #         l = parseInt(l)
    #         update(m, l + 1)
    #     else
    #       update(m, 1)
    #   bruteforce_update(k)
    # optimal_match_sequence = unwind(n)
    # optimal_l = optimal_match_sequence.length

    # # corner: empty password
    # if password.length == 0
    #   guesses = 1
    # else
    #   guesses = optimal.g[n - 1][optimal_l]

    # # final result object
    # password: password
    # guesses: guesses
    # guesses_log10: @log10 guesses
    # sequence: optimal_match_sequence
  end

  @doc """
  Guess estimation -- one function per match pattern.
  """
  def estimate_guesses(match, password) do
    # return match.guesses if match.guesses? # a match's guess estimate doesn't change. cache it.
    # min_guesses = 1
    # if match.token.length < password.length
    #   min_guesses = if match.token.length == 1
    #     MIN_SUBMATCH_GUESSES_SINGLE_CHAR
    #   else
    #     MIN_SUBMATCH_GUESSES_MULTI_CHAR
    # estimation_functions =
    #   bruteforce: @bruteforce_guesses
    #   dictionary: @dictionary_guesses
    #   spatial:    @spatial_guesses
    #   repeat:     @repeat_guesses
    #   sequence:   @sequence_guesses
    #   regex:      @regex_guesses
    #   date:       @date_guesses
    # guesses = estimation_functions[match.pattern].call this, match
    # match.guesses = Math.max guesses, min_guesses
    # match.guesses_log10 = @log10 match.guesses
    # match.guesses
  end

  ## Guesses

  def bruteforce_guesses(match) do
    # guesses = Math.pow BRUTEFORCE_CARDINALITY, match.token.length
    # if guesses == Number.POSITIVE_INFINITY
    #     guesses = Number.MAX_VALUE;
    # # small detail: make bruteforce matches at minimum one guess bigger than smallest allowed
    # # submatch guesses, such that non-bruteforce submatches over the same [i..j] take precedence.
    # min_guesses = if match.token.length == 1
    #   MIN_SUBMATCH_GUESSES_SINGLE_CHAR + 1
    # else
    #   MIN_SUBMATCH_GUESSES_MULTI_CHAR + 1
    # Math.max guesses, min_guesses
  end

  def repeat_guesses(match) do
    # match.base_guesses * match.repeat_count
  end

  def sequence_guesses(match) do
    # first_chr = match.token.charAt(0)
    # # lower guesses for obvious starting points
    # if first_chr in ['a', 'A', 'z', 'Z', '0', '1', '9']
    #   base_guesses = 4
    # else
    #   if first_chr.match /\d/
    #     base_guesses = 10 # digits
    #   else
    #     # could give a higher base for uppercase,
    #     # assigning 26 to both upper and lower sequences is more conservative.
    #     base_guesses = 26
    # if not match.ascending
    #   # need to try a descending sequence in addition to every ascending sequence ->
    #   # 2x guesses
    #   base_guesses *= 2
    # base_guesses * match.token.length
  end

  def regex_guesses(%{regex_name: regex_name, token: token, regex_match: regex_match})
      when regex_name == :recent_year do
    # conservative estimate of year space: num years from REFERENCE_YEAR.
    # if year is close to REFERENCE_YEAR, estimate a year space of MIN_YEAR_SPACE.
    {parsed_input, _} = Integer.parse(List.first(regex_match))
    max(abs(parsed_input - @reference_year), @min_year_space)
  end

  def regex_guesses(%{regex_name: regex_name, token: token, regex_match: regex_match}) do
    char_class_bases = %{
      alpha_lower: 26,
      alpha_upper: 26,
      alpha: 52,
      alphanumeric: 62,
      digits: 10,
      symbols: 33
    }

    if Map.has_key?(char_class_bases, regex_name) do
      :math.pow(char_class_bases[regex_name], String.length(token))
    end
  end

  def date_guesses(match) do
    # # base guesses: (year distance from REFERENCE_YEAR) * num_days * num_years
    # year_space = Math.max(Math.abs(match.year - @REFERENCE_YEAR), @MIN_YEAR_SPACE)
    # guesses = year_space * 365
    # # add factor of 4 for separator selection (one of ~4 choices)
    # guesses *= 4 if match.separator
    # guesses
  end

  def spatial_guesses(match) do
    # if match.graph in ['qwerty', 'dvorak']
    #   s = @KEYBOARD_STARTING_POSITIONS
    #   d = @KEYBOARD_AVERAGE_DEGREE
    # else
    #   s = keypad_starting_positions()
    #   d = keypad_average_degree()
    # guesses = 0
    # L = match.token.length
    # t = match.turns
    # # estimate the number of possible patterns w/ length L or less with t turns or less.
    # for i in [2..L]
    #   possible_turns = Math.min(t, i - 1)
    #   for j in [1..possible_turns]
    #     guesses += @nCk(i - 1, j - 1) * s * Math.pow(d, j)
    # # add extra guesses for shifted keys. (% instead of 5, A instead of a.)
    # # math is similar to extra guesses of l33t substitutions in dictionary matches.
    # if match.shifted_count
    #   S = match.shifted_count
    #   U = match.token.length - match.shifted_count # unshifted count
    #   if S == 0 or U == 0
    #     guesses *= 2
    #   else
    #     shifted_variations = 0
    #     shifted_variations += @nCk(S + U, i) for i in [1..Math.min(S, U)]
    #     guesses *= shifted_variations
    # guesses
  end

  def dictionary_guesses(match) do
    # match.base_guesses = match.rank # keep these as properties for display purposes
    # match.uppercase_variations = @uppercase_variations match
    # match.l33t_variations = @l33t_variations match
    # reversed_variations = match.reversed and 2 or 1
    # match.base_guesses * match.uppercase_variations * match.l33t_variations * reversed_variations
  end

  ## Variations

  def uppercase_variations(%{token: word}) do
    start_upper = ~r/^[A-Z][^A-Z]+$/
    end_upper = ~r/^[^A-Z]+[A-Z]$/
    all_upper = ~r/^[^a-z]+$/
    all_lower = ~r/^[^A-Z]+$/

    cond do
      word =~ all_lower or String.downcase(word) == word ->
        1

      # a capitalized word is the most common capitalization scheme,
      # so it only doubles the search space (uncapitalized + capitalized).
      # allcaps and end-capitalized are common enough too, underestimate as 2x factor to be safe.
      word =~ all_upper or word =~ start_upper or word =~ end_upper ->
        2

      # otherwise calculate the number of ways to capitalize n_u+n_l uppercase+lowercase letters
      # with nU uppercase letters or less. or, if there's more uppercase than lower (for eg. PASSwORD),
      # the number of ways to lowercase nU+nL letters with nL lowercase letters or less.
      true ->
        n_u = length(Enum.filter(String.codepoints(word), fn char -> char =~ ~r/[A-Z]/ end))
        n_l = length(Enum.filter(String.codepoints(word), fn char -> char =~ ~r/[a-z]/ end))
        Enum.reduce(1..min(n_u, n_l), 0, fn i, acc -> acc + nCk(n_u + n_l, i) end)
    end
  end

  def l33t_variations(match) do
    # return 1 if not match.l33t
    # variations = 1
    # for subbed, unsubbed of match.sub
    #   # lower-case match.token before calculating: capitalization shouldn't affect l33t calc.
    #   chrs = match.token.toLowerCase().split('')
    #   S = (chr for chr in chrs when chr == subbed).length   # num of subbed chars
    #   U = (chr for chr in chrs when chr == unsubbed).length # num of unsubbed chars
    #   if S == 0 or U == 0
    #     # for this sub, password is either fully subbed (444) or fully unsubbed (aaa)
    #     # treat that as doubling the space (attacker needs to try fully subbed chars in addition to
    #     # unsubbed.)
    #     variations *= 2
    #   else
    #     # this case is similar to capitalization:
    #     # with aa44a, U = 3, S = 2, attacker needs to try unsubbed + one sub + two subs
    #     p = Math.min(U, S)
    #     possibilities = 0
    #     possibilities += @nCk(U + S, i) for i in [1..p]
    #     variations *= possibilities
    # variations
  end

  ## Helpers

  defp adjacency_graphs, do: Zxcvbn.Data.AdjacencyGraphs.all()

  defp keyboard_starting_positions, do: Enum.count(adjacency_graphs().qwerty)

  defp keypad_starting_positions, do: Enum.count(adjacency_graphs().keypad)

  # Used in spatial guesses
  def keyboard_average_degree, do: calc_average_degree(adjacency_graphs().qwerty)

  # slightly different for keypad/mac keypad, but close enough
  def keypad_average_degree, do: calc_average_degree(adjacency_graphs().keypad)

  # On qwerty, 'g' has degree 6, being adjacent to 'ftyhbv'. '\' has degree 1.
  # this calculates the average over all keys.
  defp calc_average_degree(graph) do
    # average = 0
    # for key, neighbors of graph
    #   average += (n for n in neighbors when n).length
    # average /= (k for k,v of graph).length
    # average
  end

  def nCk(n, k) when n >= 0 and k >= 0 do
    if k == 0, do: 1, else: nCk(n, k, 1, 1)
  end

  defp nCk(n, k, k, acc), do: div(acc * (n - k + 1), k)
  defp nCk(n, k, i, acc), do: nCk(n, k, i + 1, div(acc * (n - i + 1), i))

  defp log10(n) do
    # Math.log(n) / Math.log(10) # IE doesn't support Math.log10 :(
  end

  defp log2(n) do
    # Math.log(n) / Math.log(2)
  end

  defp factorial(n) do
    # # unoptimized, called only on small n
    # return 1 if n < 2
    # f = 1
    # f *= i for i in [2..n]
    # f
  end
end
