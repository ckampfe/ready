defmodule Ready.Acceptor do
  require Logger
  alias :ranch, as: Ranch

  def start_link(ref, _socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, transport, opts])
    {:ok, pid}
  end

  def init(ref, transport, _opts) do
    {:ok, socket} = Ranch.handshake(ref)
    loop(socket, transport)
  end

  def loop(socket, transport) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, bytes} ->
        response =
          case Ready.Parser.parse(bytes) do
            [command | _] = commands when is_list(command) ->
              Enum.map(commands, &Ready.Redis.op/1)

            command ->
              Ready.Redis.op(command)
          end

        :gen_tcp.send(socket, response)
        loop(socket, transport)

      {:error, :closed} ->
        transport.close(socket)

      {:error, error} ->
        Logger.error(inspect(error))
        transport.close(socket)

      e ->
        transport.close()
        Logger.error(e)
    end
  end
end
