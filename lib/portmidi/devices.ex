defmodule PortMidi.Devices do
  @on_load :init
  def init do
    :portmidi
    |> :code.priv_dir
    |> :filename.join("portmidi_list")
    |> :erlang.load_nif(0)
  end

  def list, do:
    do_list

  def do_list, do:
    raise "NIF library not loaded"
end
