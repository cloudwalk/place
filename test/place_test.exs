defmodule PlaceTest do
  use ExUnit.Case
  doctest Place

  test "greets the world" do
    assert Place.hello() == :world
  end
end
