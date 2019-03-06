defmodule Ready.EtsStore do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_args) do
    :ets.new(:ready_ets_store, [
      :set,
      :public,
      :named_table,
      {:read_concurrency, true},
      {:write_concurrency, true}
    ])

    {:ok, %{}}
  end

  def get(key) do
    :ets.lookup(:ready_ets_store, key)
  end

  def set(key, value) do
    :ets.insert(:ready_ets_store, {key, value})
  end
end
