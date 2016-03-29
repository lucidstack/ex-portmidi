defmodule PortMidi.Output do
  import PortMidi.Nifs.Output

  def start_link(device_name) do
    GenServer.start_link(__MODULE__, device_name)
  end

  # Client implementation
  #######################

  @default_timestamp 0
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
    Process.flag(:trap_exit, true)

    device_name
    |> String.to_char_list
    |> do_open
  end

  def handle_call({:write, message, timestamp}, _from, stream) do
    response = do_write(stream, message, timestamp)
    {:reply, response, stream}
  end

  def terminate(_reason, stream), do:
    stream |> do_close

end
