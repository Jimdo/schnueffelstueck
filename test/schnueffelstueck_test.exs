defmodule SchnueffelstueckTest do
  use ExUnit.Case, async: true
  doctest Schnueffelstueck

  @tag skip: "figure out how to handle gen_tcp in tests"
  test "the truth" do
    assert 1 + 1 == 2
  end
end
