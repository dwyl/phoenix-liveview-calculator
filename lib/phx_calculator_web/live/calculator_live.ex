defmodule PhxCalculatorWeb.CalculatorLive do
alias PhxCalculatorWeb.CoreComponents
  use PhxCalculatorWeb, :live_view
  import CoreComponents

  def mount(_params, _session, socket) do
    socket = assign(socket, calc: [], current: "0") |> dbg()
    {:ok, socket}
  end

  def handle_event("number", %{"number" => number}, socket) do
    current =
    case socket.assigns.current do
      "0" -> ""
      _ -> socket.assigns.current
    end
    socket = assign(socket, current: current <> number) |> dbg()
    {:noreply, socket}
  end

  def handle_event("operation", %{"operation" => operation}, socket) do
    calc = socket.assigns.calc ++ [socket.assigns.current, operation]
    current = ""
    socket = assign(socket, calc: calc, current: current) |> dbg()
    {:noreply, socket}
  end

  # buggy and not finished
  def handle_event("equals", _unsigned_params, socket) do
    calc = socket.assigns.calc ++ [socket.assigns.current]
    current = ""
    socket = assign(socket, calc: calc, current: current) |> dbg()
    {:noreply, socket}
    calculate(0, socket.assigns.calc, socket)
  end

  # pass accumulator value and the to-be calculated values
  defp calculate(_acc, calc, socket) when length(calc) > 0 do

    # split calc into lists of 3 (number *(op) number)
    [num1, op, num2 | rest] = calc
    num1 = Float.parse(num1) |> elem(0)
    num2 = Float.parse(num2) |> elem(0)
    acc = apply_operation(num1, op, num2)

    # call recursively
    calculate(acc, rest, socket)
  end

  # Need to handle case where repeated operations are added so length(calc) = 2
  # defp calculate(acc, calc, socket) when length(calc) == 2 do

  #   # split calc into lists of 3 (number *(op) number)
  #   [op, num2 | rest] = calc
  #   num2 = Float.parse(num2) |> elem(0)
  #   acc = apply_operation(acc, op, num2)

  #   # call recursively
  #   calculate(acc, rest, socket)
  # end

  defp calculate(acc, [], socket) do
    socket = assign(socket, current: acc)
    {:noreply, socket}
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
