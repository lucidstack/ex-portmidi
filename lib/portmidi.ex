defmodule PortMidi do
  @moduledoc """
    The entry module of portmidi. Through this module you can open and close
    devices, listen on input devices, or write to output devices.
  """

  alias PortMidi.Input
  alias PortMidi.Output
  alias PortMidi.Listeners
  alias PortMidi.Devices

  use Application

  @doc """
    Starts the `:portmidi` application. Under the hood, starts the
    `Portmidi.Listeners` GenServer, that holds all the listeners to
    input devices.
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Listeners, [])
    ]

    opts = [strategy: :one_for_one, name: PortMidi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
    Opens a connection to the device with name `device_name` of type
    `device_type`.

    Returns the `pid` to the corresponding GenServer. Use this `pid` to call
    `listen/2`, if the device is an input, or `write/2` if it is an output.
  """
  def open(device_type, device_name)
  def open(:input, device_name),  do: Input.start_link device_name
  def open(:output, device_name), do: Output.start_link device_name

  @doc """
    Terminates the GenServer held by the `device` argument. If the type is an
    input, and `listen/2` was called on it, it also shuts down the listening
    process. Using the given `device` after calling this method will raise an
    error.
  """
  def close(device_type, device)
  def close(:input, input),   do: Input.stop(input)
  def close(:output, output), do: Input.stop(output)

  @doc """
    Starts a listening process on the given `input`, and returns `:ok`. After
    calling this method, the process with the given `pid` will receive MIDI
    events in its mailbox as soon as they are emitted from the device.
  """
  def listen(input, pid), do:
    Input.listen(input, pid)

  @doc """
    Writes a MIDI event to the given `output` device. `message` must be a tuple
    `{status, note, velocity}`. Returns `:ok` on write.
  """
  def write(output, message), do:
    Output.write(output, message)

  @doc """
    Writes a MIDI event to the given `output` device, with given `timestamp`.
    `message` must be a tuple `{status, note, velocity}`. Returns `:ok` on
    write.
  """
  def write(output, message, timestamp), do:
    Output.write(output, message, timestamp)

  @doc """
    Returns a map with input and output devices, in the form of
    `PortMidi.Device` structs
  """
  def devices, do: Devices.list
end
