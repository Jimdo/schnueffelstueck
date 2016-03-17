defmodule Schnueffelstueck.Connection do
  @moduledoc """
  Handles a single tcp connection to a log emmiting node.
  """

  alias Schnueffelstueck.Parser.Syslog

  @behaviour :ranch_protocol

  @timeout Application.get_env(:schnueffelstueck, :tcp_timeout)
  @token Application.get_env(:schnueffelstueck, :fastly_token)

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
    :ok = :ranch.accept_ack(ref)
  	loop(socket, transport)
  end

  def loop(socket, transport) do
    case transport.recv(socket, 0, @timeout) do
  		{:ok, << @token <> data >>} ->
        parse_and_report(data)
  			loop(socket, transport)
      {:ok, _} ->
        loop(socket, transport)
  		_ ->
  			:ok = transport.close(socket)
  	end
  end

  defp parse_and_report(data) do
    Task.start(fn -> Syslog.parse(data) |> inspect |> IO.puts end)
  end
end
