defmodule Ready.Redis do
  alias Ready.EtsStore
  require Logger

  @crlf "\r\n"
  @ok "+OK" <> @crlf
  @null "$-1" <> @crlf

  def op(["SET", key, value]) do
    try do
      EtsStore.set(key, value)
      @ok
    rescue
      e ->
        Logger.error(e)
        @null
    end
  end

  def op(["GET", key]) do
    case EtsStore.get(key) do
      [{_k, v}] ->
        ["$", to_string(byte_size(v)), @crlf, v, @crlf]

      _ ->
        @null
    end
  end

  def op(["PING"]) do
    ["+PONG", @crlf]
  end

  def op(["PING", message]) do
    message <> @crlf
  end

  # redis-cli sends this when it starts
  def op(["COMMAND"]) do
    "*0" <> @crlf
  end
end
