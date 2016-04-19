defmodule PortMidi.Mixfile do
  use Mix.Project
  @version "4.2.0"

  def project do
    [app: :portmidi,
     version: @version,
     elixir: "~> 1.2",
     description: "Elixir bindings to the portmidi C library",
     package: package,
     compilers: [:port_midi, :elixir, :app],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,

     # Docs
     name: "PortMidi",
     docs: [source_ref: "v#{@version}", main: "PortMidi",
            source_url: "https://github.com/lucidstack/ex-portmidi"]
   ]
  end

  def application do
    [applications: [:logger],
     mod: {PortMidi, []}]
  end

  defp deps do
    [{:credo, "~> 0.3", only: [:dev, :test]},
     {:mock, "~> 0.1.1", only: :test},
     {:ex_doc, github: "elixir-lang/ex_doc", only: :dev},
     {:earmark, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [maintainers: ["Andrea Rossi"],
     files: ["priv", "lib", "src", "Makefile", "mix.exs", "README.md", "LICENSE"],
     licenses: ["MIT"],
     links: %{"Github" => "https://github.com/lucidstack/ex-portmidi"}]
  end
end

defmodule Mix.Tasks.Compile.PortMidi do
  @shortdoc "Compiles portmidi bindings"
  def run(_) do
    if Mix.shell.cmd("make") != 0 do
      raise Mix.Error, message: "could not run `make`. Do you have make, gcc and libportmidi installed?"
    end
  end
end
