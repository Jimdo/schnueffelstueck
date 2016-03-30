defmodule Schnueffelstueck.Config do
  use GenServer

  # Client

  def start_link(defaults \\ []) do
    GenServer.start_link(__MODULE__, defaults, name: __MODULE__)
  end

  def services do
    GenServer.call(__MODULE__, :services)
  end

  # Server

  def init(_) do
    # read yml // or parse raw input
    reporter_config = [
      {:user, System.get_env("LIBRATO_USER")},
      {:token, System.get_env("LIBRATO_TOKEN")},
      {:service, System.get_env("LIBRATO_PREFIX")}
    ]

    parser_configs = [
      [
        {:token, System.get_env("FASTLY_TOKEN")},
        {:reporter, [
          {Schnueffelstueck.Reporter.Librato, reporter_config}
        ]}
      ],
    ]

    {:ok, parser_configs}
  end

  def handle_call(:services, _from, config) do
    {:reply, config, config}
  end
end
