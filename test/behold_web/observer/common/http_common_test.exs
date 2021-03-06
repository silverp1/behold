defmodule Observer.Common.HTTPTest do
  use BeholdWeb.ConnCase
  alias Observer.Common.HTTP

  test "check_return_value/2 properly compares status codes", _ do
    response = HTTP.check_return_value(200, "200")
    assert response == {true, 200}

    response = HTTP.check_return_value(201, "200")
    assert response == {false, 201}
  end
end
