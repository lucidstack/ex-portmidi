defmodule PortMidi.Input do
  alias PortMidi.Input.Server

  def start_link(device_name) do
    Server.start_link device_name
  end

  def listen(input, pid) do
    PortMidi.Listeners.register(input, pid)
  end

  def stop(input) do
    Server.stop(input)
  end
end

