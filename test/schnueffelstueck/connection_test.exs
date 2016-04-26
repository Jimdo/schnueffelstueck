defmodule Schnueffelstueck.ConnectionTest do
  use ExUnit.Case, async: true
  doctest Schnueffelstueck.Connection

  alias Schnueffelstueck.Connection

  @logline "testtoken<134>2016-03-07T15:22:04Z cache-lhr6325 test-syslog[396422]: 109.17.194.160 Tue, 29 Mar 2016 11:11:01 GMT GET /?format=medium&ressource=http%3A%2F%2Fapi.dmp.jimdo-server.com%2Fdesigns%2F293%2Fversions%2F2.0.4 200 73080 HIT 3 29.309 0.000"

  setup do
    mapping = [
      {"testtoken", [
        {__MODULE__, :pid1},
        {__MODULE__, :pid2}
      ]},
      {"othertoken", [
        {__MODULE__, :notapid}
      ]}
    ]
    {:ok, mapping: mapping}
  end

  def submit(metrics, pid) do
    {:submitted, metrics, pid}
  end

  test "passing the metrics to the corresponding reporters", %{mapping: mapping} do
    result = Connection.parse_and_report(@logline, mapping)
    assert result == [
      {:submitted, [
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :request, source: "cache-lhr6325", value: 1},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :status, source: "cache-lhr6325", value: "200"},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :hit, source: "cache-lhr6325", value: "HIT"},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :method, source: "cache-lhr6325", value: "GET"},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :bytes, source: "cache-lhr6325", value: 73080},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :num_hits, source: "cache-lhr6325", value: 3},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :lastuse, source: "cache-lhr6325", value: 29.309},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :latency, source: "cache-lhr6325", value: 0.000}
      ], :pid1},
      {:submitted, [
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :request, source: "cache-lhr6325", value: 1},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :status, source: "cache-lhr6325", value: "200"},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :hit, source: "cache-lhr6325", value: "HIT"},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :method, source: "cache-lhr6325", value: "GET"},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :bytes, source: "cache-lhr6325", value: 73080},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :num_hits, source: "cache-lhr6325", value: 3},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :lastuse, source: "cache-lhr6325", value: 29.309},
        %Schnueffelstueck.Metric{measure_time: 1459249861, name: :latency, source: "cache-lhr6325", value: 0.000}
      ], :pid2}]
  end
end
