defmodule PortMidi.Output do
  @default_timestamp 0
  @on_load {:init, 0}
  def init do
    :ok = :portmidi
    |> :code.priv_dir
    |> :filename.join("portmidi_out")
    |> :erlang.load_nif(0)
  end

  def start_link(device_name) do
    GenServer.start_link(__MODULE__, device_name, name: __MODULE__)
  end

  # Client implementation
  #######################

  def message(message, _) when length(message) != 3, do:
    raise "message must be [status, note, velocity]"

  def message(message, timestamp \\ @default_timestamp), do:
    GenServer.call(__MODULE__, {:message, message, timestamp})

  # Server implementation
  #######################

  def init(device_name) do
    device_name
    |> String.to_char_list
    |> do_open
  end

  def handle_call({:message, message, timestamp}, from, stream) do
    response = do_message(stream, message, timestamp)
    {:reply, response, stream}
  end

  # NIFs implementation
  #####################

  def do_open(_device_name), do:
    raise "NIF library not loaded"

  def do_message(_stream, _message, _timestamp), do:
    raise "NIF library not loaded"
end
