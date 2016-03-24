defmodule Schnueffelstueck.Reporter.Librato do
  alias Schnueffelstueck.Reporter
  alias Schnueffelstueck.Metric
  use GenServer

  @behaviour Reporter

  @doc """
  Starts the reporter process.

  ## Options
  The first argument `config` is a reporter specific configuration, for the librato reporter it must contain:
  - `:user` the librato user that can write to your librato account
  - `:token` the librato token corresponding to the `:user`
  - `:service` needed to construct the metrics keys like `SERVICE.fastly.METRIC`

  The second argument are the GenServer options.
  @see: http://elixir-lang.org/docs/stable/elixir/GenServer.html#start_link/3

  ## Examples
      iex> {:ok, pid} = Schnueffelstueck.Reporter.Librato.start_link([{:user, "frank"}, {:token, "12345"}], [name: Reporter])
      ...> is_pid(GenServer.whereis(Reporter))
      true
  """
  @spec start_link(Reporter.config, list) :: {:ok, pid} | {:error, term}
  def start_link(config, gen_server_options \\ []) do
    GenServer.start_link(__MODULE__, config, gen_server_options)
  end

  @doc """
  Reports a list of metrics to Librato.

  ## Options
  The first argument is a list of Metrics. The second is the reporter `pid`.

  ## Examples
      iex> {:ok, pid} = Schnueffelstueck.Reporter.Librato.start_link([{:user, "frank"}, {:token, "12345"}], [name: Reporter])
      ...> metric = %Schnueffelstueck.Metric{measure_time: 1457364121, name: :hit, source: "cache-lhr6325", value: "HIT"}
      ...> Schnueffelstueck.Reporter.Librato.submit([metric], pid)
      :ok
  """
  @spec submit(Reporter.metrics, pid) :: :ok | {:error, reason :: String.t}
  def submit(metrics, pid) do
    GenServer.cast(pid, {:submit, metrics})
  end

  @doc false
  def handle_cast({:submit, metrics}, config) do
    build_req_body(metrics, config)
    |> send_request(config)
    {:noreply, config}
  end

  @doc """
  Builds the json request body.
  """
  @spec build_req_body(Reporter.metrics, Reporter.config) :: String.t
  def build_req_body(metrics, options) do
    {:ok, service} = Keyword.fetch(options, :service)

    {:ok, body} = JSX.encode(%{
      "gauges" => transform(metrics, service, [])
    })

    body
  end

  @doc """
  Sends off the request to the librato api.
  """
  @spec send_request(String.t, Reporter.config) :: %HTTPotion.Response{}
  defp send_request(body, options) do
    {:ok, user} = Keyword.fetch(options, :user)
    {:ok, token} = Keyword.fetch(options, :token)
    HTTPotion.post "https://metrics-api.librato.com/v1/metrics", [
      basic_auth: {user, token},
      body: body,
      headers: ["User-Agent": "Elixir-Schnueffelstueck", "Content-Type": "application/json"]
    ]
  end

  @doc """
  Finalizes the metrics transfomation with reversing the list.

  ## Examples
      iex> Schnueffelstueck.Reporter.Librato.transform([], [foo: :bar], [1,2,3])
      [3,2,1]
  """
  @spec transform([], Reporter.config, list) :: [map]
  def transform([], _, metrics), do: Enum.reverse(metrics)

  @doc """
  Transforms a `Schnueffelstueck.Metric` into a librato compatible metric representation.
  """
  @spec transform(Reporter.metrics, String.t, [map]) :: [map]
  def transform([%Metric{name: :status, value: value, source: source, measure_time: time} | rest], service, metrics) do
    transform(rest, service, [
      %{"name" => "#{service}.fastly.status.#{value}", "value" => 1, "source" => source, "measure_time" => time} |
      metrics
    ])
  end

  @spec transform(Reporter.metrics, String.t, [map]) :: [map]
  def transform([%Metric{name: :request, value: value, source: source, measure_time: time} | rest], service, metrics) do
    transform(rest, service, [
      %{"name" => "#{service}.fastly.requests", "value" => value, "source" => source, "measure_time" => time} |
      metrics
    ])
  end

  @spec transform(Reporter.metrics, String.t, [map]) :: [map]
  def transform([%Metric{name: :hit, value: value, source: source, measure_time: time} | rest], service, metrics) do
    transform(rest, service, [
      %{"name" => "#{service}.fastly.cache_hit.#{value}", "value" => 1, "source" => source, "measure_time" => time} |
      metrics
    ])
  end

  @spec transform(Reporter.metrics, String.t, [map]) :: [map]
  def transform([%Metric{name: :method, value: value, source: source, measure_time: time} | rest], service, metrics) do
    transform(rest, service, [
      %{"name" => "#{service}.fastly.method.#{value}", "value" => 1, "source" => source, "measure_time" => time} |
      metrics
    ])
  end

  @spec transform(Reporter.metrics, String.t, [map]) :: [map]
  def transform([%Metric{name: :bytes, value: value, source: source, measure_time: time} | rest], service, metrics) do
    transform(rest, service, [
      %{"name" => "#{service}.fastly.bytes", "value" => Integer.parse(value) |> elem(0), "source" => source, "measure_time" => time} |
      metrics
    ])
  end

  @spec transform(Reporter.metrics, String.t, [map]) :: [map]
  def transform([%Metric{name: :latency, value: value, source: source, measure_time: time} | rest], service, metrics) do
    transform(rest, service, [
      %{"name" => "#{service}.fastly.origin_latency", "value" => Integer.parse(value) |> elem(0), "source" => source, "measure_time" => time} |
      metrics
    ])
  end

  @spec transform(Reporter.metrics, String.t, [map]) :: [map]
  def transform([%Metric{name: :num_hits} | rest], service, metrics), do: transform(rest, service, metrics)
  @spec transform(Reporter.metrics, String.t, [map]) :: [map]
  def transform([%Metric{name: :lastuse} | rest], service, metrics), do: transform(rest, service, metrics)
end
