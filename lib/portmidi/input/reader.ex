defmodule PortMidi.Input.Reader do
  import PortMidi.Nifs.Input
  alias PortMidi.Input.Server

  def start_link(server, device_name) do
    Agent.start_link fn ->
      {:ok, stream} = device_name |> open
      {server, stream}
    end
  end

  # Client implementation
  #######################

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
end

