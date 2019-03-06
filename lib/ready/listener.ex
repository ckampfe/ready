defmodule Ready.ListenerStarter do
  use GenServer
  require Logger
  alias :ranch, as: Ranch

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    {:ok, args, {:continue, :init_server}}
  end

  def handle_continue(:init_server, state) do
    {:ok, listen_socket} =
      Ranch.start_listener(
        :listener,
        :ranch_tcp,
        %{
          socket_opts: [{:port, Map.fetch!(state, :port)}],
          max_connections: Map.fetch(state, :max_connections),
          num_acceptors: Map.fetch!(state, :num_acceptors)
        },
        Ready.Acceptor,
        []
      )

    state = Map.put(state, :listen_socket, listen_socket)

    Logger.info("Listener started")

    {:noreply, state}
  end
end
