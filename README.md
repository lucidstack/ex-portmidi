# ex-portmidi

ex-portmidi is a wrapper for the [PortMidi C library](http://portmedia.sourceforge.net/portmidi/),
that provides some nice abstractions to (write to|listen on) MIDI devices.

## Installation

1. Add portmidi to your list of dependencies in `mix.exs`:
```
def deps do
  [{:portmidi, "~> 1.0"}]
end
```

2. Ensure portmidi is started before your application:
```
def application do
  [applications: [:portmidi]]
end
```

3. If you are not planning on using more than one device, and you know the name of the device
you are gonna use, configure a device name in your app's configuration files:
```
config :portmidi, device: "Launchpad Mini"
```

## Usage

To send MIDI events to a MIDI device:
```
iex(1)> {:ok, output} = PortMidi.open(:output, "Launchpad Mini")
{:ok, #PID<0.172.0>}
iex(2)> PortMidi.write(output, [176, 0, 127])
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

As simple as that.
