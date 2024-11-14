defmodule PhxCalculatorWeb.CalculatorLiveTest do
  use PhxCalculatorWeb.ConnCase
  import Phoenix.LiveViewTest

  test "disconnected and connected mount", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Calculator"

    {:ok, _view, _html} = live(conn)
  end

  # test "calc is being properly calculated in `button-press`", %{conn: conn},
  # %{socket: socket} do

  #   {:ok, view, _html} = live(conn, "/")
  #   assert socket.assigns.calc = "0"
  #   view
  #   |> element("button[phx-value-input=\"0\"]")
  #   |> render_click()
  #   assert socket.assigns.calc = "0"

  #   view
  #   |> element("button[phx-value-input=\"1\"]")
  #   |> render_click()
  #   assert socket.assigns.calc = "1"
  # end

  test "button-press", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    assert render(view) =~ "0"
    view
    |> element("button[phx-click=\"button-press\"][phx-value-input=\"1\"]")
    |> render_click()
    assert render(view) =~ "1"
  end
end
