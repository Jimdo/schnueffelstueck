defmodule Schnueffelstueck.Parser.Syslog do
  @moduledoc """
  Module for partsing the syslog(-ish) format fastly provides as realtime logs.
  """

  use Timex
  alias Schnueffelstueck.Metric

  @doc """
  Transforms the fastly syslog(-ish) log into a List of Metrics.

  Returns `[%Schnueffelstueck.Metric{measure_time: 1457364121, name: :status, source: "cache-lhr6325", value: "200"}, ...]`

  ## Examples

      iex> Schnueffelstueck.Parser.Syslog.parse "<134>2016-03-07T15:22:04Z cache-lhr6325 test-syslog[396422]: 109.17.194.160 Mon, 07 Mar 2016 15:22:01 GMT GET /path/to/resource 200 73080 HIT 3 29.309 0.000"
      [%Schnueffelstueck.Metric{measure_time: 1457364121, name: :status, source: "cache-lhr6325", value: "200"},
            %Schnueffelstueck.Metric{measure_time: 1457364121, name: :hit, source: "cache-lhr6325", value: "HIT"},
            %Schnueffelstueck.Metric{measure_time: 1457364121, name: :method, source: "cache-lhr6325", value: "GET"},
            %Schnueffelstueck.Metric{measure_time: 1457364121, name: :bytes, source: "cache-lhr6325", value: "73080"},
            %Schnueffelstueck.Metric{measure_time: 1457364121, name: :num_hits, source: "cache-lhr6325", value: "3"},
            %Schnueffelstueck.Metric{measure_time: 1457364121, name: :lastuse, source: "cache-lhr6325", value: "29.309"},
            %Schnueffelstueck.Metric{measure_time: 1457364121, name: :latency, source: "cache-lhr6325", value: "0.000"}]
  """
  @spec parse(String.t) :: [Metric.t]
  def parse(line) when is_binary(line) do
    line
    |> String.split(" ")
    |> parse
  end

  @spec parse(list) :: [Metric.t]
  def parse([_prival_and_date, source, _appname, _remote_ip | rest]) do
    generate_metrics(rest, source)
  end

  @spec generate_metrics(list, String.t) :: [Metric.t]
  defp generate_metrics([date_ddd, date_dd, date_mmm, date_yyyy, date_time, date_tz | rest], source) do
    ts = Enum.join([date_ddd, date_dd, date_mmm, date_yyyy, date_time, date_tz], " ")
    |> Timex.parse("{RFC1123}") |> elem(1)
    |> Timex.to_unix
    generate_metrics(ts, rest, source)
  end

  @spec generate_metrics(integer, list, String.t) :: [Metric.t]
  defp generate_metrics(time, [method, _path, status, bytes, cache_hit, num_hits, lastuse, latency], source) do
    [
      %Metric{name: :status, value: status, source: source, measure_time: time },
      %Metric{name: :hit, value: cache_hit, source: source, measure_time: time },
      %Metric{name: :method, value: method, source: source, measure_time: time },
      %Metric{name: :bytes, value: bytes, source: source, measure_time: time },
      %Metric{name: :num_hits, value: num_hits, source: source, measure_time: time },
      %Metric{name: :lastuse, value: lastuse, source: source, measure_time: time },
      %Metric{name: :latency, value: latency, source: source, measure_time: time }
    ]
  end
end
