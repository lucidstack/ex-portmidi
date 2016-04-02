defmodule PortMidi.Input.Server do
  alias PortMidi.Listeners
  alias PortMidi.Input.Reader

  def start_link(device_name) do
    GenServer.start_link(__MODULE__, device_name)
  end

  # Client implementation
  #######################

  def new_message(server, message), do:
    GenServer.cast(server, {:new_message, message})

  def stop(server), do:
    GenServer.stop(server)

  # Server implementation
  #######################

  def init(device_name) do
    Process.flag(:trap_exit, true)

    {:ok, reader} = Reader.start_link(self, device_name)
    Reader.listen(reader)

    {:ok, reader}
  end

  def handle_cast({:new_message, message}, reader) do
    self
    |> Listeners.list
    |> Enum.each(&(send(&1, {self, message})))

    {:noreply, reader}
  end

  def terminate(_reason, reader), do:
    reader |> Reader.stop

end
