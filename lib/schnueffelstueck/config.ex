defmodule Schnueffelstueck.Config do
  use GenServer

  require Logger

  # Client

  def start_link(defaults) do
    GenServer.start_link(__MODULE__, defaults, name: __MODULE__)
  end

  def init(defaults) when is_list(defaults) do
    super(defaults)
  end

  def init(config_path) when is_binary(config_path) do
    config = config_file(config_path)
      |> read_config
      |> Map.get("services")
      |> transform
    {:ok, config}
  end

  defp config_file(path) do
    System.cwd! |> Path.join(path)
  end

  defp read_config(path) do
    YamlElixir.read_from_file(path)
  end

  defp transform(map_config) do
    Enum.map(map_config, &(transform_service(&1)))
  end

  defp transform_service(map_service_config) do
    [
      token: map_service_config["fastly_service_token"],
      reporter: Enum.map(map_service_config["reporter"], &(transform_reporter(&1))) |> Enum.reject(&(is_nil(&1)))
    ]
  end

  defp transform_reporter(%{"librato" => config}) do
    {Schnueffelstueck.Reporter.Librato, [user: config["user"], token: config["token"], service: config["service"]]}
  end

  defp transform_reporter(reporter) do
    Logger.warn "Unsupported reporter detected: #{inspect reporter}"
    nil
  end

  def services do
    GenServer.call(__MODULE__, :services)
  end

  # Server

  def handle_call(:services, _from, config) do
    {:reply, config, config}
  end
end
