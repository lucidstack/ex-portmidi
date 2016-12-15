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
    Opens a connection to the input device with name `device_name`.

    Returns the `pid` to the corresponding GenServer. Use this `pid` to call
    `listen/2`.

    If Portmidi can't open the device, a tuple `{:error, reason}` is returned.
    Check `src/portmidi_shared.c#makePmErrorAtom` for all possible errors.
  """
  @spec open(:input, <<>>) :: {:ok, pid()} | {:error, atom()}
  def open(:input, device_name) do
    Input.start_link device_name
  end

  @doc """
    Opens a connection to the output device with name `device_name`.

    Returns the `pid` to the corresponding GenServer. Use this `pid` to call
    `write/2`.

    If Portmidi can't open the device, a tuple `{:error, reason}` is returned.
    Check `src/portmidi_shared.c#makePmErrorAtom` for all possible errors.
  """
  @spec open(:output, <<>>, non_neg_integer() \\ 0) :: {:ok, pid()} | {:error, atom()}
  def open(:output, device_name, latency \\ 0) do
    Output.start_link(device_name, latency)
  end

  @doc """
    Terminates the GenServer held by the `device` argument, and closes the
    PortMidi stream. If the type is an input, and `listen/2` was called on it,
    it also shuts down the listening process. Using the given `device` after
    calling this method will raise an error.
  """
  @spec close(atom, pid()) :: :ok
  def close(device_type, device)
  def close(:input, input),   do: Input.stop(input)
  def close(:output, output), do: Input.stop(output)

  @doc """
    Starts a listening process on the given `input`, and returns `:ok`. After
    calling this method, the process with the given `pid` will receive MIDI
    events in its mailbox as soon as they are emitted from the device.
  """
  @spec listen(pid(), pid()) :: :ok
  def listen(input, pid), do:
    Input.listen(input, pid)

  @doc """
    Writes a MIDI event to the given `output` device. `message` can be a tuple
    `{status, note, velocity}`, a tuple `{{status, note, velocity}, timestamp}`
    or a list `[{{status, note, velocity}, timestamp}, ...]`. Returns `:ok` on write.
  """
  @type message :: {byte(), byte(), byte()}
  @type timestamp :: byte()

  @spec write(pid(), message) :: :ok
  @spec write(pid(), {message, timestamp}) :: :ok
  @spec write(pid(), [{message, timestamp}, ...]) :: :ok
  def write(output, message), do:
    Output.write(output, message)

  @doc """
    Returns a map with input and output devices, in the form of
    `PortMidi.Device` structs
  """
  @spec devices() :: %{input: [%PortMidi.Device{}, ...], output: [%PortMidi.Device{}, ...]}
  def devices, do: Devices.list
end
