# ex-portmidi

ex-portmidi is a simple wrapper for the [PortMidi C library](http://portmedia.sourceforge.net/portmidi/),
written in Elixir. This implementation uses ports for the moment. I might give
it a shot, and port everything to NIFs, if possible.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add portmidi to your list of dependencies in `mix.exs`:

        def deps do
          [{:portmidi, "~> 0.0.1"}]
        end

  2. Ensure portmidi is started before your application:

        def application do
          [applications: [:portmidi]]
        end

  3. Configure the name of your device in your `config.exs`:

        config :portmidi, device: "Launchpad Mini"

## Usage

At the moment, `portmidi` has four main modules to interact with:

### `PortMidi.Devices`
Call `PortMidi.Devices.list` to have a list of all connected MIDI devices, with
some info on their input/output capabilities.

### `PortMidi.Listeners`
Call `PortMidi.Listeners.register(pid)` to register a process to listen on the
input device.

### `PortMidi.Input`
After registering your process(es), call `PortMidi.Input.listen` to start
listening for MIDI events. These will be propagated to all processes in the
`Listeners` register.

When calling `PortMidi.Input.listen`, a standard `{:ok, pid}` tuple is
returned. Use the `pid` to call `PortMidi.Input.stop(pid)` when input is no
more needed. Please remember that Elixir has to constantly poll for new events,
so stopping this will save loads of CPU time

### `PortMidi.Output`
Call `PortMidi.Output.message([status, note, velocity])` to send a MIDI message
to the configured MIDI device.
