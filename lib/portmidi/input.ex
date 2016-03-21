defmodule PortMidi.Input do
  def start_link(device_name) do
    Task.async(fn -> start_input(device_name) end)
    {:ok, self}
  end

  def start_input(device_name) do
    Process.flag(:trap_exit, true)
    device_name |> open_port |> listen
  end

  def listen(port) do
    receive do
      {^port, {:data, values}} ->
        IO.inspect(values)
        listen(port)
      _ ->
        listen(port)
    end
  end

  def open_port(device_name) do
    Port.open({
      :spawn_executable,
      :filename.join(:code.priv_dir(:portmidi), 'port_midi_in')
    }, [
      packet: 2,
      args: [device_name]
    ])
  end
end
