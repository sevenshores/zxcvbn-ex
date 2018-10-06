defmodule ZxcvbnTest do
  use ExUnit.Case
  doctest Zxcvbn

  test "scores a password" do
    assert Zxcvbn.check("password") === 0
  end
end
