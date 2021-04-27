defmodule PortMidi.Listeners do
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Client implementation
  #######################

  def register(input, pid), do: GenServer.cast(__MODULE__, {:register, input, pid})

  def list(input), do: GenServer.call(__MODULE__, {:list, input})

  # Server implementation
  #######################

  def init(:ok), do: {:ok, {%{}, %{}}}

  def handle_call({:list, input}, _from, {listeners, _} = state) do
    if Map.has_key?(listeners, input) do
      {:reply, Map.get(listeners, input), state}
    else
      {:reply, {:error, :input_not_found}, state}
    end
  end

  def handle_cast({:register, input, pid}, {listeners, refs}) do
    ref = Process.monitor(pid)
    refs = refs |> Map.put(ref, pid)

    input_listeners = [pid | Map.get(listeners, input, [])]
    listeners = listeners |> Map.put(input, input_listeners)

    {:noreply, {listeners, refs}}
  end

  def handle_info({:DOWN, ref, :process, _, _}, {listeners, refs}) do
    {pid, refs} = Map.pop(refs, ref)
    listeners = do_update_listeners(listeners, pid)

    {:noreply, {listeners, refs}}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  require Logger
  def terminate(reason, _), do: Logger.error(reason)

  # Private implementation
  ########################

  def do_update_listeners(listeners, pid) do
    Enum.reduce(listeners, %{}, fn {input, listeners}, acc ->
      Map.put(acc, input, do_find_new_listeners(listeners, pid))
    end)
  end

  def do_find_new_listeners(listeners, pid) do
    listeners |> Enum.reject(&(&1 == pid))
  end
end
