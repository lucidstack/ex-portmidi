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
    {:ok, reader} = PortMidi.Input.Reader.start_link(self, device_name)
    Reader.listen(reader)

    {:ok, reader}
  end

  def handle_cast({:new_message, message}, reader) do
    Listeners.list(self)
    |> Enum.each(&(send(&1, message)))

    {:noreply, reader}
  end

  def terminate(:normal, reader), do:
    reader |> Reader.stop
end
