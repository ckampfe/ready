defmodule Ready.Parser do
  require Logger

  @crlf "\r\n"
  @cr to_charlist("\r") |> List.first()
  @zero_through_nine MapSet.new(Enum.map(0..9, fn digit -> to_string(digit) |> to_charlist end))

  def parse(s) do
    {res, _remaining} = do_parse(s)

    res
  end

  # BULKSTRINGS
  def do_parse("$" <> rest) do
    string_digits =
      rest
      |> String.to_charlist()
      |> Enum.take_while(fn char ->
        MapSet.member?(
          @zero_through_nine,
          [char]
        )
      end)
      |> to_string

    {digits, _} = Integer.parse(string_digits)

    bs = byte_size(string_digits)
    <<_b::bytes-size(bs), @crlf, payload::bytes-size(digits), @crlf, r::binary()>> = rest

    {payload, r}
  end

  # SIMPLE STRINGS
  def do_parse("+" <> rest) do
    str =
      Enum.take_while(String.to_charlist(rest), fn char ->
        char != @cr
      end)
      |> to_string()

    bs = byte_size(str)
    <<str::bytes-size(bs), r::binary()>> = rest

    {str, r}
  end

  # INTEGERS
  def do_parse(":" <> rest) do
    integer_string =
      Enum.take_while(String.to_charlist(rest), fn char ->
        char != @cr
      end)
      |> to_string()

    {integer, _} = Integer.parse(integer_string)

    bs = byte_size(integer_string)
    <<_str::bytes-size(bs), r::binary()>> = rest

    {integer, r}
  end

  # ARRAYS
  def do_parse("*" <> rest) do
    integer_string =
      Enum.take_while(String.to_charlist(rest), fn char ->
        char != @cr
      end)
      |> to_string()

    {array_size, _} = Integer.parse(integer_string)

    bs = byte_size(integer_string)
    <<_::bytes-size(bs), @crlf, rest::binary()>> = rest

    {array_items, remaining} =
      Enum.reduce(0..(array_size - 1), {[], rest}, fn _val, {collected, rest} ->
        {el, remaining} = do_parse(rest)
        {[el | collected], remaining}
      end)

    {Enum.reverse(array_items), remaining}
  end

  # when commands have no prefix!
  def do_parse(inline_commands) do
    commands = String.split(inline_commands, "\r\n")

    split_commands =
      Enum.map(commands, fn
        command ->
          String.split(command, " ")
      end)
      |> Enum.filter(fn
        [""] ->
          nil

        _otherwise ->
          true
      end)

    {split_commands, ""}
  end
end
