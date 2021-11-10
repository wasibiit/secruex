defmodule SecureXTest do
  use ExUnit.Case
  doctest SecureX

  test "greets the world" do
    assert SecureX.hello() == :world
  end
end
