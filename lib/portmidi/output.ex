defmodule PortMidi.Output do
  import PortMidi.Nifs.Output

  def start_link(device_name, latency) do
    GenServer.start_link(__MODULE__, {device_name, latency})
  end


  # Client implementation
  #######################
  def write(server, message), do:
    GenServer.call(server, {:write, message})

  def stop(server), do:
    GenServer.stop(server)


  # Server implementation
  #######################
  def init({device_name, latency}) do
    Process.flag(:trap_exit, true)

    case do_open(to_charlist(device_name), latency) do
      {:ok,    stream} -> {:ok,   stream}
      {:error, reason} -> {:stop, reason}
    end
  end

  def handle_call({:write, messages}, _from, stream) when is_list(messages) do
    response = do_write(stream, messages)
    {:reply, response, stream}
  end

  @default_timestamp 0
  def handle_call({:write, {_, _, _} = message}, _from, stream) do
    response = do_write(stream, [{message, @default_timestamp}])
    {:reply, response, stream}
  end

  def handle_call({:write, message}, _from, stream) do
    response = do_write(stream, [message])
    {:reply, response, stream}
  end

  def terminate(_reason, stream) do
    stream |> do_close
  end
end
