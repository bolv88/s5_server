defmodule Stack do
  require Logger
  use GenServer

  def start_link(state, opts) do
    Logger.info "start linke"
    IO.inspect "start link"
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init([socket, super_id]) do
    output "init one s5 server"
    {:ok, [socket, super_id], 100}
    #{:ok, %S5Server.State{super_id: super_id, socket: socket, number: 60}, 0}
  end

  def handle_call(:pop, _from, [h|t]) do
    {:reply, h, t, 1000}
  end

  def handle_cast({:push, h}, t) do
    {:noreply, [h|t]}
  end

  def handle_info(:timeout, s) do
    IO.inspect [:timeout,s]
    {:stop, "timeout not init 2", s}
  end

  def handle_info(info, s) do
    IO.inspect [:o, info, s]
    {:noreply, s}
  end

  def terminate(reason, state) do
    IO.inspect [:terminate, reason, state]
    :ok
  end
  defp output(params) do
    IO.inspect params
  end

  defp bin_encode(bin) do
    bin
  end

  defp bin_decode(bin) do
    bin
  end
end
