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

    log_acceptor = :ranch.child_spec(:schnueffelstueck, @acceptors,
      :ranch_tcp, [port: @port], Schnueffelstueck.Connection, [{:reporter, Schnueffelstueck.Reporter.Librato}, {:token, System.get_env("FASTLY_TOKEN")}])

    reporter_config = [
      {:user, System.get_env("LIBRATO_USER")},
      {:token, System.get_env("LIBRATO_TOKEN")},
      {:service, System.get_env("LIBRATO_PREFIX")}
    ]

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Domo.Worker, [arg1, arg2, arg3]),
      log_acceptor,
      worker(Schnueffelstueck.Reporter.Librato, [reporter_config, [name: Schnueffelstueck.Reporter]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Schnueffelstueck.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
