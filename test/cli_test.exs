defmodule CliTest do
  use ExUnit.Case
  import S5Server.CLI, only: [parse_args: 1]


  test ":help" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "user project with number" do
    assert parse_args(["user", "project", "99"]) == {"user", "project", 99}
  end

  test "user project without number" do
    assert parse_args(["user", "project"]) == {"user", "project", 4}
  end
end

