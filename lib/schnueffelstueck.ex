defmodule Schnueffelstueck do
  use Application

  @port Application.get_env(:schnueffelstueck, :port)
  @acceptors Application.get_env(:schnueffelstueck, :acceptors)

  defmodule Metric do
    defstruct [:name, :value, :measure_time, :source]
    @type t :: %__MODULE__{}
  end

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Domo.Worker, [arg1, arg2, arg3]),
      worker(Schnueffelstueck.Config, []),
      :ranch.child_spec(:schnueffelstueck, @acceptors, :ranch_tcp,
        [port: @port], Schnueffelstueck.Connection, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Schnueffelstueck.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
