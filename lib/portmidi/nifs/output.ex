defmodule PortMidi.Nifs.Output do
  @on_load {:init_nif, 0}

  def init_nif do
    :ok = :portmidi
    |> :code.priv_dir
    |> :filename.join("portmidi_out")
    |> :erlang.load_nif(0)
  end

  def do_open(_device_name), do:
    raise "NIF library not loaded"

  def do_write(_stream, _message, _timestamp), do:
    raise "NIF library not loaded"
end
