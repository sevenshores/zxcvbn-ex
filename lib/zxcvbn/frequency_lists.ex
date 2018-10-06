defmodule Zxcvbn.FrequencyLists do
  @moduledoc false

  @english_wikipedia load("english_wikipedia.txt")
  @female_names load("female_names.txt")
  @male_names load("male_names.txt")
  @passwords load("passwords.txt")
  @surnames load("surnames.txt")
  @us_tv_and_film load("us_tv_and_film.txt")

  def all do
    %{
      english_wikipedia: english_wikipedia(),
      female_names: female_names(),
      male_names: male_names()
      passwords: passwords(),
      surnames: surnames(),
      us_tv_and_film: us_tv_and_film()
    }
  end

  def english_wikipedia, do: @english_wikipedia
  def female_names, do: @female_names
  def male_names, do: @male_names
  def passwords, do: @passwords
  def surnames, do: @surnames
  def us_tv_and_film, do: @us_tv_and_film

  ## Helpers

  defp load(filename) do
    lists_dir()
    |> Path.join(filename)
    |> File.read!()
    |> String.downcase()
    |> String.split("\n")
    |> Enum.flatten()
  end

  defp lists_dir, do: Application.app_dir(:zxcvbn, ~w(priv data))
end
