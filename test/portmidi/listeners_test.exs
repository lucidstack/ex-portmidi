defmodule PortMidiListenersTest do
  alias PortMidi.Listeners
  use ExUnit.Case, async: true

  test "creates an empty map of listeners" do
    assert Listeners.list == []
  end

  test "adds pids when registering a process" do
    Listeners.register(self)
    assert self in Listeners.list
  end

  test "removes listeners when down" do
    {:ok, listener} = Agent.start(fn -> 0 end)
    Listeners.register(listener)

    assert listener in Listeners.list

    Agent.stop(listener)
    refute listener in Listeners.list
  end
end
