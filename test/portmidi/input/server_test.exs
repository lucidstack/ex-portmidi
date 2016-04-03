defmodule PortMidiInputServerTest do
  alias PortMidi.Input.Reader
  alias PortMidi.Listeners
  import PortMidi.Input.Server

  use ExUnit.Case, async: false
  import Mock

  test "new_message/2 broadcasts to processes in Listeners" do
    {:ok, input} = Agent.start(fn -> [] end)
    Listeners.register(input, self)

    Agent.get input, fn(_) ->
      handle_cast({:new_message, {176, 0, 127}}, nil)
    end

    assert_received {input, {176, 0, 127}}
  end

  test "terminating the server calls close on the reader" do
    test_pid = self
    reader_mock = [start_link: fn(_pid, _device_name) -> {:ok, test_pid} end,
                   listen:     fn(_reader) -> :ok end,
                   stop:       fn(_reader) -> :ok end]

    with_mock Reader, reader_mock  do
      {:ok, server} = start_link("Launchpad Mini")
      stop(server)

      assert called Reader.stop(test_pid)
    end
  end

  test "an error from Reader on open stops the server" do
    reader_mock = [start_link: fn(_pid, _device_name) ->
     {:error, :invalid_device_id}
    end]

    with_mock Reader, reader_mock  do
      assert {:stop, :invalid_device_id} = init("Launchpad Mini")
    end
  end
end
