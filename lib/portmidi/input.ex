defmodule PortMidi.Input do
  @on_load {:init, 0}
  def init do
    :ok = :portmidi
    |> :code.priv_dir
    |> :filename.join("portmidi_in")
    |> :erlang.load_nif(0)
  end

  # Client implementation
  #######################

  def start_link(device_name) do
    :ok = device_name |> open
    {:ok, self}
  end

  def open(device_name), do:
    device_name
    |> String.to_char_list
    |> do_open

  def listen, do:
    {:ok, Task.async(&do_listen/0).pid}

  def do_listen do
    if poll == :read do
      read |> send_to_listeners
    end

    unless terminated?, do: do_listen
  end

  def send_to_listeners(data) do
    PortMidi.Listeners.list
    |> Enum.each( &(send(&1, data)) )
  end

  def stop(task), do:
    send(task, :stop)

  def terminated? do
    receive do
      :stop -> true
    after
      0 -> false
    end
  end

  def poll, do:
    do_poll

  def read, do:
    do_read

  # NIFs implementation
  #####################

  def do_poll, do:
    raise "NIF library not loaded"

  def do_read, do:
    raise "NIF library not loaded"

  def do_open(_device_name), do:
    raise "NIF library not loaded"

  def do_listen(_stream), do:
    raise "NIF library not loaded"
end
