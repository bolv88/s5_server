defmodule S5Server do
  use Application
  use Supervisor

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, [listen_host, listen_port]) do
    #import Supervisor.Spec, warn: false

    Supervisor.start_link(__MODULE__, [listen_host, listen_port])
  end

  def init( [listen_host, listen_port]) do
    # listen 
    {:ok, socket} = :gen_tcp.listen(listen_port,  [
      :binary, 
      packet: 0, 
      active: true, 
      reuseaddr: true,
      backlog: 128
    ])

    children = [
      # Define workers and child supervisors to be supervised
      #worker(S5Server.Server, [socket], restart: :transient),
      #worker(S5Server.Server, [socket], restart: :temporary),
      worker(S5Server.Server, [[socket, S5Server.Supervisor]], restart: :temporary),
      #worker(Stack, [[socket, S5Server.Supervisor]]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :simple_one_for_one, name: S5Server.Supervisor]
    {:ok, super_pid} = Supervisor.start_link(children, opts)
    r  = supervise(children, opts)
    :observer.start()
    start_child()
    r

    #send self(), :start_child

    #loop()
  end

  defp loop() do
    receive do
      :start_child ->
        start_child()
      other ->
        IO.puts "received unknow info"
        IO.inspect other
    end
    loop
  end
  def start_child() do
    Supervisor.start_child(S5Server.Supervisor, [[]] )
  end

end
