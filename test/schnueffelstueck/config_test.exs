defmodule Schnueffelstueck.ConfigTest do
  use ExUnit.Case, async: true
  doctest Schnueffelstueck.Config

  alias Schnueffelstueck.Config

  @simple_test_config [[
     {:token, "testtoken"},
     {:reporter, [{Schnueffelstueck.Reporter.Librato,
        user: "superuser", token: "ov%3IyC4xlY$zuAJx9L!", service: "metermacher"}]}
  ]]

  test "list config is passed through" do
    assert Config.init(@simple_test_config) == {:ok, @simple_test_config}
  end

  test "path to yaml file is parsed and converted" do
    assert Config.init("test/config.yml") == {:ok, [
      [
        {:token, "testtoken"},
        {:reporter, [{Schnueffelstueck.Reporter.Librato, user: "bla@jimdo.com", token: 12345, service: "catwalk"}]}
      ],
      [
        {:token, "catwalktoken"},
        {:reporter, [{Schnueffelstueck.Reporter.Librato, user: "bla2@jimdo.com", token: 6789, service: "metermacher"}]}
      ]
    ]}
  end
end
