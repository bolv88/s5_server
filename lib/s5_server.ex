defmodule S5Server do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, [listen_host, listen_port]) do
    #import Supervisor.Spec, warn: false
    :observer.start
    start_sup([listen_host, listen_port])
  end
  def start_sup([listen_host, listen_port]) do
    S5Server.Supervisor.start_link([listen_host, listen_port])
  end

end
