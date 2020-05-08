defmodule Observer.Common.Common do
  alias Observer.Cron.Rollup

  def convert_string_to_int(string) when is_nil(string), do: {:error, string}
  def convert_string_to_int(string) when is_integer(string), do: {:ok, string}
  def convert_string_to_int(string) do
    {int, _} = Integer.parse(string)
    {:ok, int}
  end

  def compare(op, val1, val2) do
    {_, val2_converted} = convert_string_to_int(val2)
    do_compare(op, val1, val2_converted)
  end

  def do_compare(:greater_than, val1, val2) do
    val1 > val2
  end

  def do_compare(:less_than, val1, val2) do
    val1 < val2
  end

  def do_compare(:greater_than_or_equal_to, val1, val2) do
    val1 >= val2
  end

  def do_compare(:less_than_or_equal_to, val1, val2) do
    val1 <= val2
  end

  def do_compare(:equal_to, val1, val2) do
    val1 == val2
  end

  def do_compare(:not_equal_to, val1, val2) do
    val1 != val2
  end

  def convert_float_to_integer(float) when is_integer(float), do: {:ok, float}
  def convert_float_to_integer(float) do
    {:ok, round(float)}
  end

  def convert_from_miliseconds_to_seconds(miliseconds) do
    seconds = miliseconds / 1000
    {:ok, int} = convert_float_to_integer(seconds)
    int
  end
end
