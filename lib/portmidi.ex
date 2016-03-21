defmodule PortMidi do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(PortMidi.Input,  [Application.get_env(:port_midi, :device)]),
      worker(PortMidi.Output, [Application.get_env(:port_midi, :device)]),
    ]

    opts = [strategy: :one_for_one, name: PortMidi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
