defmodule PortMidi.Input.Server do
  alias PortMidi.Listeners
  alias PortMidi.Input.Reader

  def start_link(device_name) do
    GenServer.start_link(__MODULE__, device_name)
  end

  # Client implementation
  #######################

  def new_messages(server, messages), do: GenServer.cast(server, {:new_messages, messages})

  def stop(server), do: GenServer.stop(server)

  # Server implementation
  #######################

  def init(device_name) do
    Process.flag(:trap_exit, true)

    case Reader.start_link(self(), device_name) do
      {:ok, reader} ->
        Reader.listen(reader)
        {:ok, reader}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  def handle_cast({:new_messages, messages}, reader) do
    self()
    |> Listeners.list()
    |> Enum.each(&send(&1, {self(), messages}))

    {:noreply, reader}
  end

  def terminate(_reason, reader), do: reader |> Reader.stop()
end
