defmodule Zxcvbn.Data.ParserTest do
  use ExUnit.Case

  import Zxcvbn.Data.Parser, only: [parse_data_file: 1]

  describe "parse_data_file/1" do
    # @tag :pending
    test "" do
      # setup
      {:ok, file} = File.open("priv/data/test.txt", [:write, :utf8])
      IO.write(file, "first\nmiddle\nend\n")
      File.close(file)

      dict = parse_data_file("test.txt")
      assert dict.words["first"] == 1
      assert dict.words["middle"] == 2
      assert dict.words["end"] == 3
      assert dict.words["googlygoob"] == nil

      assert dict.name == "test"

      # teardown
      File.rm("priv/data/test.txt")
    end
  end
end
