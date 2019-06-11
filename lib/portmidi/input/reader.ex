defmodule PortMidi.Input.Reader do
  import PortMidi.Nifs.Input
  alias PortMidi.Input.Server
  require Logger

  @buffer_size Application.get_env(:portmidi, :buffer_size, 256)
  @input_poll_sleep Application.get_env(:portmidi, :input_poll_sleep, 1)

  def start_link(server, device_name) do
    Agent.start_link fn -> start(server, device_name) end
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
  defp start(server, device_name) do
    case device_name |> String.to_char_list |> do_open do
      {:ok,    stream} -> {server, stream}
      {:error, reason} -> exit(reason)
    end
  end

  defp do_listen({server, stream}) do
    task = Task.async fn -> loop(server, stream) end
    {:ok, {server, stream, task}}
  end

  defp loop(server, stream) do
    if do_poll(stream) == :read, do: read_and_send(server,stream)
    :timer.sleep(@input_poll_sleep)
    loop(server, stream)
  end

  defp read_and_send(server, stream) do
    case do_read(stream, @buffer_size) do
      {:error, reason} -> Logger.debug("Error Reading Midi: #{reason}")
      messages -> Server.new_messages(server, messages)
    end
  end

  defp do_stop({_server, stream, task}) do
    task   |> Task.shutdown
    stream |> do_close
  end
end
