defmodule PortMidi.Output do
  use GenServer

  # Client implementation
  #######################

  def start_link(device_name) do
    GenServer.start_link(__MODULE__, device_name, name: Output)
  end

  def message(message) do
    GenServer.cast(Output, {:send, message})
  end

  # Server implementation
  #######################

  def init(device_name), do: {:ok, open_port(device_name)}

  def handle_cast({:send, message}, port) do
    Port.command(port, [1 | message])
    {:noreply, port}
  end

  def open_port(device_name) do
    Port.open({
      :spawn_executable,
      :filename.join(:code.priv_dir(:portmidi), 'port_midi_out')
    }, [
      packet: 2,
      args: [device_name]
    ])
  end
end
