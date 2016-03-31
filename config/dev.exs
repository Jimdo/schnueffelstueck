use Mix.Config

config :schnueffelstueck, initial_config: [[
   {:token, "testtoken"},
   {:reporter, [{Schnueffelstueck.Reporter.Librato,
      user: System.get_env("LIBRATO_USER"), token: System.get_env("LIBRATO_TOKEN"), service: System.get_env("LIBRATO_PREFIX")}]}
]]
