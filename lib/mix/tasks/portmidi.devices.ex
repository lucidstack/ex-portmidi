defmodule Mix.Tasks.Portmidi.Devices do
  use Mix.Task
  @shortdoc "Shows the connected devices"

  def run(_args) do
    IO.puts "Input:"
    list_devices(:input)

    IO.puts "Output:"
    list_devices(:output)
  end

  defp list_devices(type) do
    PortMidi.devices[type]
    |> Enum.each(&print_device/1)
  end

  defp print_device(device) do
    IO.puts " - #{device.name}"
  end
end
