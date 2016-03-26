defmodule PortMidiListenersTest do
  alias PortMidi.Listeners
  use ExUnit.Case, async: true

  setup do
    {:ok, input} = Agent.start(fn -> nil end)
    {:ok, input: input}
  end

  test "creates an empty map of listeners", %{input: input} do
    assert Listeners.list(input) == {:error, :input_not_found}
  end

  test "adds pids when registering a process", %{input: input} do
    {:ok, listener} = Agent.start(fn -> nil end)

    Listeners.register(input, listener)
    assert listener in Listeners.list(input)
  end

  test "removes listeners when down", %{input: input} do
    {:ok, listener} = Agent.start(fn -> nil end)
    Listeners.register(input, listener)

    assert listener in Listeners.list(input)

    Agent.stop(listener)
    refute listener in Listeners.list(input)
  end
end
