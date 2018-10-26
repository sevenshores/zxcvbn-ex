defmodule Zxcvbn.Data.ParserTest do
  use ExUnit.Case

  import Zxcvbn.Data.Parser, only: [parse_data_file: 1]

  describe "parse_data_file/1" do
    setup [:create_test_file]

    test "parses the file", %{test_file: filename} do
      dict = parse_data_file(filename)
      assert dict.words["first"] == 1
      assert dict.words["middle"] == 2
      assert dict.words["end"] == 3
      assert dict.words["googlygoob"] == nil

      assert dict.name == "test"
    end
  end

  ## Setup helpers

  defp create_test_file(_) do
    "priv/data/test.txt"
    |> File.open!([:write, :utf8])
    |> IO.write("first\nmiddle\nend\n")
    |> File.close()

    on_exit(fn ->
      File.rm!("priv/data/test.txt")
    end)

    {:ok, test_file: "test.txt"}
  end
end
