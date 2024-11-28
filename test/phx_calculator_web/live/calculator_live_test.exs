defmodule PhxCalculatorWeb.CalculatorLiveTest do
  use PhxCalculatorWeb.ConnCase
  import Phoenix.LiveViewTest

  test "disconnected and connected mount", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "History"

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
      ], view, true)

      assert render(view) =~ ~s(<div id="screen" class="mr-4">1</div>)
    end

    test "with all numbers", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1.2345"},
        %{event: "operator", value: "+"},
        %{event: "number", value: "6.7890"}
      ], view, true)

      assert render(view) =~ "8.0235"
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
      ], view, true)

      assert render(view) =~ ~s(<div id="screen" class="mr-4">0</div>)
    end

    test "with identity element", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1"},
        %{event: "operator", value: "*"},
        %{event: "number", value: "1"}
        ], view, true)

      assert render(view) =~ ~s(<div id="screen" class="mr-4">1</div>)
    end

    test "with all numbers", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1.2345"},
        %{event: "operator", value: "*"},
        %{event: "number", value: "6.7890"}
      ], view, true)

      assert render(view) =~ "8.3810205"
    end
  end

  # Subtraction block
  describe "subtraction" do
    test "with identity element", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1"},
        %{event: "operator", value: "-"},
        %{event: "number", value: "0"}
        ], view, true)

      assert render(view) =~ ~s(<div id="screen" class="mr-4">1</div>)
    end

    test "with positive result", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1.2345"},
        %{event: "operator", value: "-"},
        %{event: "number", value: "6.7890"}
      ], view, true)

      assert render(view) =~ "5.5545"
    end

    test "with negative result", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1.2345"},
        %{event: "operator", value: "-"},
        %{event: "number", value: "6.7890"}
      ], view, true)

      assert render(view) =~ "-5.5545"
    end
  end

  # Division block
  describe "division" do
    test "with 0 element", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
      %{event: "number", value: "1"},
      %{event: "operator", value: "/"},
      %{event: "number", value: "0"}
      ], view, true)

      assert render(view) =~ "ERROR"
    end

    test "with identity element", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "2"},
        %{event: "operator", value: "/"},
        %{event: "number", value: "1"}
        ], view, true)

      assert render(view) =~ "2.0"
    end

    test "with all numbers", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1.2345"},
        %{event: "operator", value: "/"},
        %{event: "number", value: "6.7890"}
      ], view, true)

      assert render(view) =~ "0.1818382677861246"
    end
  end

  describe "deletion" do
    test "backspace with number", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "3"},
        %{event: "number", value: "2"},
        %{event: "number", value: "1"}
        ], view, false)
      render_click(view, "backspace")

      assert render(view) =~ ~s(<div id="screen" class="mr-4">32</div>)
    end

    test "backspace with equals", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1"},
        %{event: "operator", value: "/"},
        %{event: "number", value: "1"}
        ], view, true)
      render_click(view, "backspace")

      # nothing should happen
      assert render(view) =~ "1.0"
    end

    test "clear", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      render_click(view, "number", number: "1")
      render_click(view, "clear")

      # screen should be empty
      assert render(view) =~ ~s(<div id="screen" class="mr-4"></div>)
    end
  end

  # Block to test the rendering logic which prevents
  # illegal statements
  describe "rendering logic" do
    test "number after equals", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1"},
        %{event: "operator", value: "/"},
        %{event: "number", value: "1"}
        ], view, true)
        render_click(view, "number", %{number: "2"})

      assert render(view) =~ ~s(<div id="screen" class="mr-4">2</div>)
    end

    test "operator after operator", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1"},
        %{event: "operator", value: "+"},
        %{event: "operator", value: "-"}
        ], view, false)

      # new operator replaces old operator
      assert render(view) =~ "1-"
    end

    test "operator with equals", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1"},
        %{event: "operator", value: "/"},
        %{event: "number", value: "1"}
        ], view, true)
        render_click(view, "operator", operator: "+")

      # nothing should happen
      assert render(view) =~ "1.0"
    end

    test "equals after operator", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
        %{event: "number", value: "1"},
        %{event: "operator", value: "+"}
        ], view, true)

      # nothing should happen
      assert render(view) =~ "1+"
    end

  end

  describe "brackets" do
    test "valid brackets", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
      %{event: "number", value: "6"},
      %{event: "operator", value: "/"},
      %{event: "number", value: "("},
      %{event: "number", value: "3"},
      %{event: "operator", value: "-"},
      %{event: "number", value: "2"},
      %{event: "number", value: ")"}
      ], view, true)

      assert render(view) =~ "6.0"
    end
    test "invalid brackets", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      apply_sequence([
      %{event: "number", value: "("},
      %{event: "number", value: "("},
      %{event: "number", value: ")"}
      ], view, true)

      assert render(view) =~ "ERROR"
    end
  end


  defp apply_sequence(sequence, view, equals?) do
    Enum.each(sequence, fn map ->
      %{event: event, value: value} = map
      render_click(view, event, %{event => value})
    end)
    if(equals?) do
      render_click(view, "equals")
    end
  end

end
