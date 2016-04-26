defmodule Schnueffelstueck.Parser.SyslogTest do
  use ExUnit.Case, async: true
  doctest Schnueffelstueck.Parser.Syslog

  alias Schnueffelstueck.Parser.Syslog, as: Parser

  @test_line "<134>2016-03-07T15:21:35Z cache-jfk1030 test-syslog[396422]: 186.212.102.41 Mon, 07 Mar 2016 15:21:35 GMT GET /?format=iphone&ressource=http%3A%2F%2Fapi.dmp.jimdo-server.com%2Fdesigns%2F333%2Fversions%2F1.2.41 200 359624 MISS 0 1457364095.588 2.476"

  test "parses the souce" do
    [first_metric | _] = Parser.parse(@test_line)
    assert first_metric.source == "cache-jfk1030"
  end

  test "parses the time" do
    [first_metric | _] = Parser.parse(@test_line)
    assert first_metric.measure_time == 1457364095
  end

  test "generates the request metric" do
    metric = Parser.parse(@test_line)
    |> Enum.find(fn(x) -> x.name == :request end)
    assert metric.name == :request
    assert metric.value == 1
  end

  test "generates the status metric" do
    metric = Parser.parse(@test_line)
    |> Enum.find(fn(x) -> x.name == :status end)
    assert metric.name == :status
    assert metric.value == "200"
  end

  test "generates the hit metric" do
    metric = Parser.parse(@test_line)
    |> Enum.find(fn(x) -> x.name == :hit end)
    assert metric.name == :hit
    assert metric.value == "MISS"
  end

  test "generates the method metric" do
    metric = Parser.parse(@test_line)
    |> Enum.find(fn(x) -> x.name == :method end)
    assert metric.name == :method
    assert metric.value == "GET"
  end

  test "generates the bytes metric" do
    metric = Parser.parse(@test_line)
    |> Enum.find(fn(x) -> x.name == :bytes end)
    assert metric.name == :bytes
    assert metric.value == 359624
  end

  test "generates the num_hits metric" do
    metric = Parser.parse(@test_line)
    |> Enum.find(fn(x) -> x.name == :num_hits end)
    assert metric.name == :num_hits
    assert metric.value == 0
  end

  test "generates the lastuse metric" do
    metric = Parser.parse(@test_line)
    |> Enum.find(fn(x) -> x.name == :lastuse end)
    assert metric.name == :lastuse
    assert metric.value == 1457364095.588
  end

  test "generates the latency metric" do
    metric = Parser.parse(@test_line)
    |> Enum.find(fn(x) -> x.name == :latency end)
    assert metric.name == :latency
    assert metric.value == 2.476
  end

  @tag :regression
  test "fastly (null) bytes won't let the app crash" do
    metric ="<134>2016-03-07T15:21:35Z cache-jfk1030 test-syslog[396422]: 186.212.102.41 Mon, 07 Mar 2016 15:21:35 GMT GET /?format=iphone&ressource=http%3A%2F%2Fapi.dmp.jimdo-server.com%2Fdesigns%2F333%2Fversions%2F1.2.41 200 (null) MISS 0 1457364095.588 2.476"
    |> Parser.parse
    |> Enum.find(fn(x) -> x.name == :bytes end)
    assert metric.name == :bytes
    assert metric.value == nil
  end
end
