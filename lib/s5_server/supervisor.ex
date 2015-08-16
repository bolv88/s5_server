defmodule S5Server.Supervisor do
  use Supervisor
  def start_link([listen_host, listen_port]) do
    result = {:ok, _sup} = Supervisor.start_link(__MODULE__, [listen_host, listen_port], name: __MODULE__)
    start_child()
    result
  end

  def init([listen_host, listen_port]) do
    IO.puts "s5 server supervisor init"
    socket = start_socket([listen_host, listen_port])

    children = [
      # Define workers and child supervisors to be supervised
      worker(S5Server.Server, [[socket, __MODULE__]], restart: :temporary),
    ]

    opts = [strategy: :simple_one_for_one]
    supervise(children, opts)

    # IO.puts "s5 server supervisor init - 1"
    # start_child()
    # IO.puts "s5 server supervisor init - 2"
  end

  def start_child() do
    Supervisor.start_child(__MODULE__, [[]] )
  end

  defp start_socket([_listen_host, listen_port]) do
    {:ok, socket} = :gen_tcp.listen(listen_port,  [
      :binary, 
      packet: 0, 
      active: true, 
      reuseaddr: true,
      backlog: 128
    ])
    socket
  end

end

