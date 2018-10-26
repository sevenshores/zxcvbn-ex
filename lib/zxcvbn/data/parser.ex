defmodule Zxcvbn.Data.Parser do
  @moduledoc false

  def parse_data_file(filename) do
    name = filename |> String.split(".") |> List.first()

    {words, _} =
      lists_dir()
      |> Path.join(filename)
      |> File.read!()
      |> String.downcase()
      |> String.split("\n")
      |> List.flatten()
      |> Enum.reduce({%{}, 1}, &add_and_count(&1, &2))

    %{name: name, words: words}
  end

  defp add_and_count(word, {words, cnt}) do
    words = Map.update(words, word, cnt, & &1)
    {words, cnt + 1}
  end

  defp lists_dir, do: Application.app_dir(:zxcvbn, ~w(priv data))
end
