defmodule S5Server.CLI do
  @default_count 4

  @moduledoc """
  Handel the command line parsing and the dispatch.
  """

  def run(argv) do
    argv
      |> parse_args
      |> process
  end
  
  def process(:help) do
    IO.puts """
    get env url: #{Application.get_env(:s5_server, :github_url)}
    """
    IO.puts """
    usage: s5_server <user> <project> [count | #{@default_count}]
    """

    System.halt(0)
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    case parse do
      {[help: true], _, _} -> :help
      {_, [user, project, count], _} -> {user, project, String.to_integer(count)}
      {_, [user, project], _} -> {user, project, @default_count}
      _ -> :help
    end
  end
end
