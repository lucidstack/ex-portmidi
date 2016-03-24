defmodule PortMidi do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(PortMidi.Listeners, []),
      worker(PortMidi.Input,  [Application.get_env(:portmidi, :device)]),
      worker(PortMidi.Output, [Application.get_env(:portmidi, :device)]),
    ]

    opts = [strategy: :one_for_one, name: PortMidi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
