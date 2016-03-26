defmodule PortMidi.Output do
  @default_timestamp 0

  def start_link(device_name) do
    GenServer.start_link(__MODULE__, device_name)
  end

  # Client implementation
  #######################

  def write(server, message, timestamp \\ @default_timestamp)

  def write(_, message, _) when length(message) != 3, do:
    raise "message must be [status, note, velocity]"

  def write(server, message, timestamp), do:
    GenServer.call(server, {:write, message, timestamp})

  def stop(server), do:
    GenServer.stop(server)

  # Server implementation
  #######################

  def init(device_name) do
    device_name
    |> String.to_char_list
    |> do_open
  end

  def handle_call({:write, message, timestamp}, _from, stream) do
    response = do_write(stream, message, timestamp)
    {:reply, response, stream}
  end

  def terminate(:normal, _state), do:
    :ok

  # NIFs implementation
  #####################
  @on_load {:init_nif, 0}

  def init_nif do
    :ok = :portmidi
    |> :code.priv_dir
    |> :filename.join("portmidi_out")
    |> :erlang.load_nif(0)
  end

  def do_open(_device_name), do:
    raise "NIF library not loaded"

  def do_write(_stream, _message, _timestamp), do:
    raise "NIF library not loaded"
end
