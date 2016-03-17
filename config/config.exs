# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# The tcp port where the syslog server will listen on.
#
#     config :schnueffelstueck, port: 5555
config :schnueffelstueck, port: 5000

# Number of acceptor processes, each of them indefinitely accepting connections.
#
#     config :schnueffelstueck, acceptors: 100
config :schnueffelstueck, acceptors: 100

# Time the tcp socket will wait for data until it closes the conection.
#
#     config :schnueffelstueck, tcp_timeout: 30_000
config :schnueffelstueck, tcp_timeout: 30_000

# Token configured in the fastly web ui, to skip requests not meant for this
# schnueffelstueck instance.
#
#     config :schnueffelstueck, fastly_token: "testtoken"
config :schnueffelstueck, fastly_token: "testtoken"

# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
