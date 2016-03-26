defmodule PortMidi.Input.Reader do
  alias PortMidi.Input.Server

  @on_load {:init, 0}
  def init do
    :ok = :portmidi
    |> :code.priv_dir
    |> :filename.join("portmidi_in")
    |> :erlang.load_nif(0)
  end

  # Client implementation
  #######################

  def start_link(server, device_name) do
    Agent.start_link fn ->
      {:ok, stream} = device_name |> open
      {server, stream}
    end
  end

  def open(device_name), do:
    device_name |> String.to_char_list |> do_open

  def listen(agent), do:
    Agent.get_and_update agent, fn({server, stream}) ->
      task = Task.async(fn -> do_listen(server, stream) end)
      {:ok, {server, stream, task}}
    end

  def stop(agent) do
    Agent.get agent, fn({_, _, task}) -> Task.shutdown(task) end
    Agent.stop(agent)
  end

  # Agent implementation
  ######################

  def do_listen(server, stream) do
    if do_poll(stream) == :read do
      Server.new_message(server, stream |> do_read)
    end

    do_listen(server, stream)
  end

  # NIFs implementation
  #####################

  def do_poll(_stream), do:
    raise "NIF library not loaded"

  def do_read(_stream), do:
    raise "NIF library not loaded"

  def do_open(_device_name), do:
    raise "NIF library not loaded"
end

