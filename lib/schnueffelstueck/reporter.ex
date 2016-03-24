defmodule Schnueffelstueck.Reporter do
  @type config :: [{atom, String.t}]
  @type metrics :: [Schnueffelstueck.Metric.t]

  @doc "Starts the reporter server."
  @callback start_link(config, list) :: {:ok, pid} | {:error, term}
  @doc "Submits a metric to the given reporter."
  @callback submit(metrics, pid) :: :ok | {:error, reason :: String.t}
end
