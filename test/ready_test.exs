defmodule ReadyTest do
  use ExUnit.Case
  doctest Ready

  test "greets the world" do
    assert Ready.hello() == :world
  end
end
