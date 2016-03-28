# ex-portmidi

ex-portmidi is a wrapper for the [PortMidi C library](http://portmedia.sourceforge.net/portmidi/),
that provides some nice abstractions to (write to|listen on) MIDI devices.

## Installation

1. Add portmidi to your list of dependencies in `mix.exs`:
```
def deps do
  [{:portmidi, "~> 3.1"}]
end
```

2. Ensure portmidi is started before your application:
```
def application do
  [applications: [:portmidi]]
end
```

## Usage

To send MIDI events to a MIDI device:
```
iex(1)> {:ok, output} = PortMidi.open(:output, "Launchpad Mini")
{:ok, #PID<0.172.0>}
iex(2)> PortMidi.write(output, {176, 0, 127})
:ok
iex(3)> PortMidi.close(:output, output)
:ok
```

To listen for MIDI events from a MIDI device:
```
iex(1)> {:ok, input} = PortMidi.open(:input, "Launchpad Mini")
{:ok, #PID<0.103.0>}
ex(2)> PortMidi.listen(input, self)
:ok
iex(3)> receive do
...(3)>   event -> IO.inspect(event)
...(3)> end
[144, 112, 127]
iex(4)> PortMidi.close(:input, input)
:ok
```

To list all connected devices:
```
ex(1)> PortMidi.devices
%{input: [%PortMidi.Device{input: 1, interf: "CoreMIDI", name: "Launchpad Mini",
    opened: 0, output: 0}],
  output: [%PortMidi.Device{input: 0, interf: "CoreMIDI",
    name: "Launchpad Mini", opened: 0, output: 1}]}
```

For more details, [check out the Hexdocs](https://hexdocs.pm/portmidi/PortMidi.html).
