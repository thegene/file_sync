defmodule FileSyncTest do
  use ExUnit.Case
  doctest FileSync

  test "greets the world" do
    assert FileSync.hello() == :world
  end
end
