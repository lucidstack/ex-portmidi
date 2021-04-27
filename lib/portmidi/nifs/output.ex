defmodule PortMidi.Nifs.Output do
  @on_load {:init, 0}

  def init do
    :ok =
      :portmidi
      |> :code.priv_dir()
      |> :filename.join("portmidi_out")
      |> :erlang.load_nif(0)
  end

  def do_open(_device_name, _latency), do: raise("NIF library not loaded")

  def do_write(_stream, _message), do: raise("NIF library not loaded")

  def do_close(_stream), do: raise("NIF library not loaded")
end
