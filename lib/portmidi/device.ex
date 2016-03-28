defmodule PortMidi.Device do
  defstruct [:name, :interf, :input, :output, :opened]

  def build(map) do
    map
    |> Map.update(:name, nil, &to_string/1)
    |> Map.update(:interf, nil, &to_string/1)
    |> make_struct
  end

  def make_struct(map), do:
    struct(__MODULE__, map)
end

