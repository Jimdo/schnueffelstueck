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
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
  	{:ok, pid}
  end

  @doc """
  Accept the connection and starts the receive loop.
  """
  def init(ref, socket, transport, opts \\ []) do
    {:ok, reporter} = Keyword.fetch(opts, :reporter)
    {:ok, token} = Keyword.fetch(opts, :token)
    :ok = :ranch.accept_ack(ref)
    loop(socket, transport, token, reporter)
  end

  def loop(socket, transport, token, reporter) do
    case transport.recv(socket, 0, @timeout) do
      {:ok, line} ->
        [_, data] = Regex.run(~r/^#{token}(.*)/, line)
        parse_and_report(data, reporter)
      _ ->
        :ok = transport.close(socket)
    end
  end

  defp parse_and_report(data, reporter) do
    Task.start(fn ->
      Syslog.parse(data) |> reporter.submit(Schnueffelstueck.Reporter)
    end)
  end
end
