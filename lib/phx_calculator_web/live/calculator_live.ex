defmodule PhxCalculatorWeb.CalculatorLive do
alias PhxCalculatorWeb.CoreComponents
  use PhxCalculatorWeb, :live_view
  import CoreComponents

  def mount(_params, _session, socket) do
    socket = assign(socket, calc: [], current: "0", history: [])
    {:ok, socket}
  end

  def handle_event("number", %{"number" => number}, socket) do
    current =
    case socket.assigns.current do
      "0" -> ""
      val when is_float(val) -> ""
      _ -> socket.assigns.current
    end
    socket = assign(socket, current: current <> number)
    {:noreply, socket}
  end

  def handle_event("operation", %{"operation" => operation}, socket) do
    calc = socket.assigns.calc ++ [socket.assigns.current, operation]
    current = ""
    socket = assign(socket, calc: calc, current: current)
    {:noreply, socket}
  end

  # buggy and not finished
  def handle_event("equals", _unsigned_params, socket) do
    calc = socket.assigns.calc ++ [socket.assigns.current]
    current = ""
    socket = assign(socket, calc: calc, current: current)
    {:noreply, socket}

    [acc | rest] = calc
    Float.parse(acc)
    acc = Float.parse(acc) |> elem(0)
    calculate(acc, rest, socket)
  end

  # pass accumulator value and the to-be calculated values
  defp calculate(acc, calc, socket) when length(calc) > 0 do

    # obtain the operation and the next number
    [op, num2 | rest] = calc
    num2 = Float.parse(num2) |> elem(0)
    acc = apply_operation(acc, op, num2)

    # call recursively
    calculate(acc, rest, socket)
  end

  defp calculate(acc, [], socket) do
    socket = assign(socket, current: acc, calc: [])
    {:noreply, socket} |> dbg()
  end

  # helper functions
  defp apply_operation(num1, "+", num2), do: num1 + num2
  defp apply_operation(num1, "-", num2), do: num1 - num2
  defp apply_operation(num1, "x", num2), do: num1 * num2
  defp apply_operation(num1, "/", num2), do: num1 / num2

  def render(assigns) do
    ~H"""
    <h1>Calculator </h1>
    <.calculator><%= @current %></.calculator>
    """
  end
end
