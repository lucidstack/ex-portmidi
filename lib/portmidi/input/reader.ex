defmodule PortMidi.Input.Reader do
  import PortMidi.Nifs.Input
  alias PortMidi.Input.Server

  def start_link(server, device_name) do
    Agent.start_link fn -> do_start(server, device_name) end
  end

  # Client implementation
  #######################

  def listen(agent), do:
    Agent.get_and_update agent, &do_listen/1

  def stop(agent) do
    Agent.get agent, &do_stop/1
    Agent.stop(agent)
  end

  # Agent implementation
  ######################

  defp do_start(server, device_name) do
    case device_name |> String.to_char_list |> do_open do
      {:ok,    stream} -> {server, stream}
    end
  end

  defp do_listen({server, stream}) do
    task = Task.async fn -> do_loop(server, stream) end
    {:ok, {server, stream, task}}
  end

  defp do_loop(server, stream) do
    if do_poll(stream) == :read do
      Server.new_message(server, stream |> do_read)
    end

    do_loop(server, stream)
  end

  defp do_stop({_server, stream, task}) do
    task   |> Task.shutdown
    stream |> do_close
  end
end
