defmodule S5Server.Server do
  use GenServer

  def start_link(start_arguments) do
    GenServer.start_link(__MODULE__, start_arguments)
  end

  def next_number(pid) do
    #GenServer.call __MODULE__, :next_number
    GenServer.call pid, :next_number
  end

  def increment_number(pid, delta) do
    GenServer.cast pid, {:increment_number, delta}
  end

  def init(start_arguments) do
    {:ok, start_arguments}
  end

  def handle_call(:next_number, _from, state) do
    {:reply, state, state+1}
  end

  def handle_cast({:increment_number, delta}, state) do
    {:noreply, state+delta}
  end

  def handle_info(info, state) do
    IO.inspect [:info, info, state]
  end
  
  def terminate(reason, state) do
    IO.inspect [:terminate, reason, state]
  end

  def code_change(from_version, state, extra) do
  end

  def format_status(reason, [pdict, state]) do
    [reason, pdict, state]
  end
end
