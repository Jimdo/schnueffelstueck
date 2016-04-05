defmodule Schnueffelstueck.Reporter.LibratoTest do
  use ExUnit.Case, async: true
  doctest Schnueffelstueck.Reporter.Librato, except: [start_link: 2]

  alias Schnueffelstueck.Metric
  alias Schnueffelstueck.Reporter.Librato

  test "build the json request body in the librato format" do
    metric = %Metric{measure_time: 1457364121, name: :hit, source: "cache-lhr6325", value: "HIT"}
    body = Librato.build_req_body([metric], [service: "servicename"])
    assert body == ~s({"gauges":[{"measure_time":1457364121,"name":"servicename.fastly.cache_hit.HIT","source":"cache-lhr","value":1}]})
  end

  test "transform the keeps the order of metrics" do
    metrics = [
      %Metric{measure_time: 1457364121, name: :hit, source: "cache-lhr6325", value: "HIT"},
      %Metric{measure_time: 1457364121, name: :status, source: "cache-ams6525", value: "200"}
    ]
    body = Librato.transform(metrics, "servicename", [])
    assert body == [
      %{"measure_time" => 1457364121, "name" => "servicename.fastly.cache_hit.HIT", "source" => "cache-lhr", "value" => 1},
      %{"measure_time" => 1457364121, "name" => "servicename.fastly.status.200", "source" => "cache-ams", "value" => 1}
    ]
  end

  test "transform adds metrics to the beginning of the existing list" do
    metrics = [
      %Metric{measure_time: 1457364121, name: :hit, source: "cache-lhr6325", value: "HIT"},
      %Metric{measure_time: 1457364121, name: :status, source: "cache-ams6525", value: "200"}
    ]
    body = Librato.transform(metrics, "servicename", [
      %{"measure_time" => 1457364121, "name" => "servicename.fastly.request", "source" => "cache-fra", "value" => 1}
    ])
    assert body == [
      %{"measure_time" => 1457364121, "name" => "servicename.fastly.request", "source" => "cache-fra", "value" => 1},
      %{"measure_time" => 1457364121, "name" => "servicename.fastly.cache_hit.HIT", "source" => "cache-lhr", "value" => 1},
      %{"measure_time" => 1457364121, "name" => "servicename.fastly.status.200", "source" => "cache-ams", "value" => 1}
    ]
  end

  test "transform the `request` metric" do
    metric = %Metric{measure_time: 1457364121, name: :request, source: "cache-lhr6325", value: 1}
    assert Librato.transform([metric], "servicename", []) == [
      %{"measure_time" => 1457364121, "name" => "servicename.fastly.requests", "source" => "cache-lhr", "value" => 1}
    ]
  end

  test "transform the `status` metric" do
    metric = %Metric{measure_time: 1457364121, name: :status, source: "cache-lhr6325", value: "200"}
    assert Librato.transform([metric], "servicename", []) == [
      %{"measure_time" => 1457364121, "name" => "servicename.fastly.status.200", "source" => "cache-lhr", "value" => 1}
    ]
  end

  test "transform the `hit` metric" do
    metric = %Metric{measure_time: 1457364121, name: :hit, source: "cache-lhr6325", value: "HIT"}
    assert Librato.transform([metric], "servicename", []) == [
      %{"measure_time" => 1457364121, "name" => "servicename.fastly.cache_hit.HIT", "source" => "cache-lhr", "value" => 1}
    ]
  end

  test "transform the `method` metric" do
    metric = %Metric{measure_time: 1457364121, name: :method, source: "cache-lhr6325", value: "GET"}
    assert Librato.transform([metric], "servicename", []) == [
      %{"measure_time" => 1457364121, "name" => "servicename.fastly.method.GET", "source" => "cache-lhr", "value" => 1}
    ]
  end

  test "transform the `bytes` metric" do
    metric = %Metric{measure_time: 1457364121, name: :bytes, source: "cache-lhr6325", value: "73080"}
    assert Librato.transform([metric], "servicename", []) == [
      %{"measure_time" => 1457364121, "name" => "servicename.fastly.bytes", "source" => "cache-lhr", "value" => 73080}
    ]
  end

  test "ignore the `num_hits` metric" do
    metric = %Metric{measure_time: 1457364121, name: :num_hits, source: "cache-lhr6325", value: "3"}
    assert Librato.transform([metric], "servicename", []) == []
  end

  test "ignore the `lastuse` metric" do
    metric = %Metric{measure_time: 1457364121, name: :lastuse, source: "cache-lhr6325", value: "29.309"}
    assert Librato.transform([metric], "servicename", []) == []
  end

  test "transform the `latency` metric" do
    metric = %Metric{measure_time: 1457364121, name: :latency, source: "cache-lhr6325", value: "0.000"}
    assert Librato.transform([metric], "servicename", []) == [
      %{"measure_time" => 1457364121, "name" => "servicename.fastly.origin_latency", "source" => "cache-lhr", "value" => 0}
    ]
  end
end
