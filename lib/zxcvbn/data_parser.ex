defmodule Zxcvbn.DataParser do
  @moduledoc false

  def parse_data_file(filename) do
    lists_dir()
    |> Path.join(filename)
    |> File.read!()
    |> String.downcase()
    |> String.split("\n")
    |> List.flatten()
  end

  defp lists_dir, do: Application.app_dir(:zxcvbn, ~w(priv data))
end
