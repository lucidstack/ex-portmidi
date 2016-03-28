defmodule PortMidi.Nifs.Devices do
  @on_load :init
  def init do
    :portmidi
    |> :code.priv_dir
    |> :filename.join("portmidi_devices")
    |> :erlang.load_nif(0)
  end

  def do_list, do:
    raise "NIF library not loaded"
end
