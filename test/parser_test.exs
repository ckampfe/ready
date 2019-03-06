defmodule Ready.ParserTest do
  use ExUnit.Case
  alias Ready.Parser

  test "parses simple strings" do
    assert Parser.parse("+OK\r\n") == "OK"
  end

  test "parses integers" do
    assert Parser.parse(":7272\r\n") == 7272
  end

  test "parses bulk strings" do
    assert Parser.parse("$6\r\nfoobar\r\n") == "foobar"
  end

  test "parses arrays" do
    # assert Redis.parse("*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n") == ["foo", "bar"]
    assert Parser.parse("*2\r\n$3\r\nGET\r\n$16\r\nkey:000000000000\r\n") == ["GET", "key:000000000000"]
  end
end
