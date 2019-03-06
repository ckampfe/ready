defmodule Ready.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Ready.EtsStore, []},
      {Ready.ListenerStarter,
       %{
         port: Application.get_env(:ready, :port) || 6379,
         max_connections: Application.get_env(:ready, :max_connections) || 10_000,
         num_acceptors: Application.get_env(:ready, :num_acceptors) || 100
       }}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ready.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
