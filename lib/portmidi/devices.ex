defmodule PortMidi.Devices do
  @on_load :init
  def init do
    :portmidi
    |> :code.priv_dir
    |> :filename.join("portmidi_list")
    |> :erlang.load_nif(0)
  end

  def list_devices do
    do_list_devices
  end

  def do_list_devices do
    raise "NIF library not loaded"
  end
end
