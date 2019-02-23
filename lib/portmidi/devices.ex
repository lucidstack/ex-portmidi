defmodule PortMidi.Devices do
  import PortMidi.Nifs.Devices
  alias  PortMidi.Device

  def list do
    do_list()
    |> Map.update(:input,  [], &do_build_devices/1)
    |> Map.update(:output, [], &do_build_devices/1)
  end

  defp do_build_devices(devices), do:
    Enum.map(devices, &Device.build/1)
end
