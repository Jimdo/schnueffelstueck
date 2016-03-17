defmodule Schnueffelstueck do
  use Application

  @port Application.get_env(:schnueffelstueck, :port)
  @acceptors Application.get_env(:schnueffelstueck, :acceptors)

  defmodule Metric do
    defstruct [:name, :value, :measure_time, :source]
    @type t :: %__MODULE__{}
  end

  def start(_type, _args) do
    :ranch.start_listener(:schnueffelstueck, @acceptors,
      :ranch_tcp, [{:port, @port}], Schnueffelstueck.Connection, [:binary, packet: :line])
  end
end
