defmodule PortMidiDevicesTest do
  import PortMidi.Devices, only: [list: 0]
  alias PortMidi.Device

  use ExUnit.Case, async: false
  import Mock

  @mock_nif_devices %{
    input:  [%{name: 'Launchpad Mini', interf: 'CoreMIDI', input: 1, output: 0, opened: 0}],
    output: [%{name: 'Launchpad Mini', interf: 'CoreMIDI', input: 0, output: 1, opened: 0}]
  }

  test_with_mock "list returns a map of devices", PortMidi.Nifs.Devices, [do_list: fn -> @mock_nif_devices end] do
    assert list == %{
      input: [%Device{name: "Launchpad Mini", interf: "CoreMIDI", input: 1, output: 0, opened: 0}],
      output: [%Device{name: "Launchpad Mini", interf: "CoreMIDI", input: 0, output: 1, opened: 0}]
    }
  end
end
