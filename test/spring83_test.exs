defmodule Spring83Test do
  use ExUnit.Case
  doctest Spring83

  test "greets the world" do
    assert Spring83.hello() == :world
  end
end
