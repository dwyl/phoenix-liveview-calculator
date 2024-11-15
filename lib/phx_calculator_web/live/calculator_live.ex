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

  def handle_event("equals", _unsigned_params, socket) do

  end

  def render(assigns) do
    ~H"""
    <h1>Calculator </h1>
    <.calculator><%= @current %></.calculator>
    """
  end
end
