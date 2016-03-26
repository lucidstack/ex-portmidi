defmodule PortMidi do
  alias PortMidi.Input
  alias PortMidi.Output
  alias PortMidi.Listeners

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Listeners, [])
    ]

    opts = [strategy: :one_for_one, name: PortMidi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def open(:input, device_name), do:
    Input.start_link device_name

  def open(:output, device_name), do:
    Output.start_link device_name

  def listen(input, pid), do:
    Input.listen(input, pid)

  def write(output, message), do:
    Output.write(output, message)

  def close(:input, input), do:
    Input.stop(input)

  def close(:output, output), do:
    Input.stop(output)
end
