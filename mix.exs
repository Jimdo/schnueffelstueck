defmodule Schnueffelstueck.Mixfile do
  use Mix.Project

  def project do
    [app: :schnueffelstueck,
     version: version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      mod: { Schnueffelstueck, [] },
      applications: [:logger, :ranch, :timex, :httpotion, :exjsx, :yaml_elixir]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      { :ranch, "~> 1.2" },
      { :timex, "~> 3.0" },
      { :httpotion, "~> 3.0" },
      { :exjsx, "~> 3.2" },
      { :exrm, "~> 1.0" },
      { :yaml_elixir, "~> 1.0" },
      { :yamerl, github: "yakaz/yamerl" },
      { :dialyxir, "~> 0.3", only: [:dev]}
    ]
  end

  defp version do
    {:ok, version} = File.read "version"
    String.strip version
  end
end
