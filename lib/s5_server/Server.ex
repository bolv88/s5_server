defmodule S5Server.Server do
  require Logger
  use GenServer

  @timeout 5000

  def start_link(state, opts) do
    Logger.debug "start link"
    output [state, opts]
    GenServer.start(__MODULE__, state, opts)
  end

  def init([socket, super_id]) do
    output "init one s5 server"
    {:ok, %S5Server.State{super_id: super_id, socket: socket, number: 60}, 0}
  end

  def init(args) do 
    output([:o_init, args])
    {:ok, args}
  end

  def handle_call(:to_close, state) do
    {:noreply, state, 0}
  end

  def handle_info(:timeout, state = %S5Server.State{client: nil, socket: socket, super_id: _super_id}) do
    output [:init_timeout, state]
    {:ok, client} = :gen_tcp.accept(socket)
    #send super_id, :start_child
    S5Server.start_child()
    {:noreply, %S5Server.State{state|client: client}}
  end

  # client connect
  def handle_info(
    {:tcp, client, bin}, 
    state = %S5Server.State{client: client, server: nil}
  ) do
    bin = bin_decode(bin)
    output [:tcp_client, bin]

    bin_size = byte_size bin
    addr_size = bin_size - 7
    case bin do
      <<_ver, _nmethods, _methods>> ->
        :gen_tcp.send(client, bin_encode(<<5, 0>>))

      <<5, 1, _rsv1, _atyp, _unknow, addr::binary-size(addr_size), port::integer-size(16)>> ->
        output ["try connect server", addr, port]
        {:ok, server} = :gen_tcp.connect(String.to_char_list(addr), 
          port, [:binary, packet: 0])
        :gen_tcp.send(client,
          bin_encode(<<5,0,0,1, 13, 0, 0, 0, 0, 0>>)
        )
        state = %S5Server.State{state | server: server}

        output ["connected", addr, port]
      _ ->
        output ["not support"]

    end
    {:noreply, state}
  end

  def handle_info(:timeout, state = %S5Server.State{server: server, client: client}) do
    output ["timeout not init", state]
    try do
      :gen_tcp.close(server)
    catch
      _ -> :pass
    end

    try do
      :gen_tcp.close(client)
    catch
      _ -> :pass
    end

    #{:stop, "timeout not init", state}
    {:noreply, state}
  end

  def handle_info(
    {:tcp, client, bin}, 
    state = %S5Server.State{client: client, server: server}
  ) do
    output([:from_client, bin])
    :gen_tcp.send(server, bin_decode(bin))
    {:noreply, state}
  end

  def handle_info(
    {:tcp, server, bin}, 
    state = %S5Server.State{client: client, server: server}
  ) do
    output([:from_server, bin])
    :gen_tcp.send(client, bin_decode(bin))
    {:noreply, state}
  end

  def handle_info(
    {:tcp_closed, client},
    state = %S5Server.State{client: client, server: server}
  ) do
    :gen_tcp.close(server)
    output "client close"
    #{:stop, "client close", state}
    GenServer.call(self(), :to_close)
    {:noreply, state}
  end

  def handle_info(
    {:tcp_closed, server},
    state = %S5Server.State{client: client, server: server}
  ) do
    :gen_tcp.close(client)
    output "server close"
    #{:stop, "server close", state}
    GenServer.call(self(), :to_close)
    {:noreply, state}
  end

  def handle_info(info, state) do
    output([:last_info, info, state])
    {:noreply, state}
  end

  
  def terminate(reason, state) do
    IO.inspect [:terminate, reason, state]
    :ok
  end

  #def code_change(_from_version, _state, _extra) do
  #end

  #def format_status(reason, [pdict, state]) do
  #  [reason, pdict, state]
  #end

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
