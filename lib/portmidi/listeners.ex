defmodule PortMidi.Listeners do
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Client implementation
  #######################

  def register(pid), do:
    GenServer.cast(__MODULE__, {:register, pid})

  def list, do:
    GenServer.call(__MODULE__, {:list})

  # Server implementation
  #######################

  def init(:ok), do:
    {:ok, %{}}

  def handle_call({:list}, _from, listeners), do:
    {:reply, Map.keys(listeners), listeners}

  def handle_cast({:register, pid}, listeners) do
    unless listeners |> Map.has_key?(pid) do
      ref = Process.monitor(pid)
      listeners = listeners |> Map.put(pid, ref)
    end

    {:noreply, listeners}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, listeners) do
    listeners = Map.delete(listeners, pid)
    {:noreply, listeners}
  end

  def handle_info(_msg, state), do:
    {:noreply, state}
end
