defmodule PhxCalculatorWeb.CalculatorLiveTest do
  use PhxCalculatorWeb.ConnCase
  import Phoenix.LiveViewTest

  test "disconnected and connected mount", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "history"

    {:ok, _view, _html} = live(conn)
  end

  # Addition block
  describe "addition" do
    test "with identity element", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
      %{event: "number", value: "1"},
      %{event: "operator", value: "+"},
      %{event: "number", value: "0"}
      ], view)

      assert render(view) =~ "1"
    end

    test "with positive element", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1"},
        %{event: "operator", value: "+"},
        %{event: "number", value: "1"}
      ], view)

      assert render(view) =~ "2"
    end
  end

 # Multiplication block
  describe "multiplication" do
    test "with 0 element", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
      %{event: "number", value: "1"},
      %{event: "operator", value: "*"},
      %{event: "number", value: "0"}
      ], view)

      assert render(view) =~ "0"
    end

    test "with identity element", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1"},
        %{event: "operator", value: "*"},
        %{event: "number", value: "1"}
        ], view)

      assert render(view) =~ "1"
    end

    test "with posiitve element", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1"},
        %{event: "operator", value: "*"},
        %{event: "number", value: "2"}
      ], view)

      assert render(view) =~ "2"
    end
  end

  defp apply_sequence(sequence, view) do
    Enum.each(sequence, fn map ->
      %{event: event, value: value} = map
      render_click(view, event, %{event => value})
    end)
  end

end
