defmodule Zxcvbn.FrequencyLists do
  @moduledoc false

  alias Zxcvbn.DataParser

  @english_wikipedia DataParser.parse_data_file("english_wikipedia.txt")
  @female_names DataParser.parse_data_file("female_names.txt")
  @male_names DataParser.parse_data_file("male_names.txt")
  @passwords DataParser.parse_data_file("passwords.txt")
  @surnames DataParser.parse_data_file("surnames.txt")
  @us_tv_and_film DataParser.parse_data_file("us_tv_and_film.txt")

  def all do
    %{
      english_wikipedia: english_wikipedia(),
      female_names: female_names(),
      male_names: male_names(),
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
end
