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
