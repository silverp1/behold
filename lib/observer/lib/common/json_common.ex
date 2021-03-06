defmodule Observer.Common.JSON do
  def get(target, value) do
    try do
      {:ok, response} = HTTPoison.get(target)
      parsed_body = Poison.decode!(response.body)
      validate_response(
        parsed_body,
        value |> split_value()
      )
    rescue
      _ ->
        {false, "error"}
    end
  end

  def validate_response(parsed_body, value_to_check) do
    try do
      case get_in(parsed_body, value_to_check) do
        val when is_nil(val) ->
          {false, "key not found"}
        val when not is_nil(val) ->
          {true, val}
      end
    rescue
      _ ->
        {false, "invalid json"}
    end
  end

  def split_value(value) do
    value
    |> String.split(".")
  end
end
