# Schnüffelstück
*| < schnueffel > ˈstuːk |* *german* – *snifter valve [noun]*: a valve on a steam engine that allows air in or out.

A piece of service that extracts realtime metrics from fastly logs and pushes them into your metrics system

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add schnueffelstueck to your list of dependencies in `mix.exs`:

        def deps do
          [{:schnueffelstueck, "~> 0.0.1"}]
        end

  2. Ensure schnueffelstueck is started before your application:

        def application do
          [applications: [:schnueffelstueck]]
        end
