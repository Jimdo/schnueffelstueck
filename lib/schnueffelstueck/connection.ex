defmodule Schnueffelstueck.Connection do
  @moduledoc """
  Handles a single tcp connection to a log emmiting node.
  """

  alias Schnueffelstueck.Parser.Syslog

  @behaviour :ranch_protocol

  @timeout Application.get_env(:schnueffelstueck, :tcp_timeout)

  @doc """
  Starts the connrction handling process.

  Returns `{:ok, pid}`
  """
  def start_link(ref, socket, transport, opts) do
    config = Schnueffelstueck.Config.services()
    pid = spawn_link(fn ->

      # mapping = [
      #   {"token", [{Module, pid}]},
      #   {"token", [{Module, pid}]}
      # ]
      mapping = Enum.map(config, fn (reporter_opts) ->
        {:ok, token} = Keyword.fetch(reporter_opts, :token)
        {:ok, reporter_list} = Keyword.fetch(reporter_opts, :reporter)
        {token, Enum.map(reporter_list, fn({module, config}) ->
          {:ok, pid} = module.start_link(config)
          {module, pid}
        end )}
      end)

      init(ref, socket, transport, mapping)
    end)
  	{:ok, pid}
  end

  @doc """
  Accept the connection and starts the receive loop.
  """
  def init(ref, socket, transport, token_reporter_mapping) do
    :ok = :ranch.accept_ack(ref)
    loop(socket, transport, "", token_reporter_mapping)
  end

  def loop(socket, transport, buffer, token_reporter_mapping) do
    case transport.recv(socket, 0, @timeout) do
      {:ok, data} ->
        case parse_line(String.split(buffer <> data, <<"\n">>, trim: true), []) do
          {rest, []} -> loop(socket, transport, rest, token_reporter_mapping)
          {rest, lines} ->
            Enum.map(lines, fn(line) -> Task.start(__MODULE__, :parse_and_report, [line, token_reporter_mapping]) end)
            loop(socket, transport, rest, token_reporter_mapping)
        end
      _ ->
        :ok = transport.close(socket)
    end
  end

  def parse_line([rest | []], lines), do: {rest, Enum.reverse(lines)}
  def parse_line([line | rest], lines), do: parse_line(rest, [line | lines])

  def parse_and_report(line, mapping) do
    [_, line_token, data] = Regex.run(~r/^(.*)(\<.*)/, line)
    {_, reporters} = Enum.find(mapping, (fn ({mapping_token, _}) -> mapping_token == line_token end))
    metrics = Syslog.parse(data)
    Enum.map(reporters, fn({module, pid}) -> module.submit(metrics, pid) end)
  end
end
