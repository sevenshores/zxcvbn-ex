defmodule Zxcvbn.Data.ParserTest do
  use ExUnit.Case

  import Zxcvbn.Data.Parser, only: [parse_data_file: 1]

  # todo as a 'setUp' create a temp file in priv/data, delete afterwards
  describe "parse_data_file/1" do
    # @tag :pending
    test "" do
      dict = parse_data_file("surnames.txt")
      assert dict.words["smith"] == 1
      assert dict.words["weed"] == 3908

      assert dict.name == "surnames"
    end
  end
end
