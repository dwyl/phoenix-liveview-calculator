defmodule PhxCalculatorWeb.CalculatorLiveTest do
  use PhxCalculatorWeb.ConnCase
  import Phoenix.LiveViewTest

  test "disconnected and connected mount", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Calculator"

    {:ok, _view, _html} = live(conn)
  end
end
