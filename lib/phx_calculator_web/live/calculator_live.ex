defmodule PhxCalculatorWeb.CalculatorLive do
alias PhxCalculatorWeb.CoreComponents
  use PhxCalculatorWeb, :live_view
  import CoreComponents

  def mount(_params, _session, socket) do
    socket = assign(socket, calc: "", history: "")
    {:ok, socket}
  end

  def handle_event("number", %{"number" => number}, socket) do
    calc = socket.assigns.calc <> number
    socket = assign(socket, calc: calc)
    {:noreply, socket}
  end

  def handle_event("operator", %{"operator" => operation}, socket) do
    calc = socket.assigns.calc <> operation
    socket = assign(socket, calc: calc)
    {:noreply, socket}
  end

  def handle_event("clear", _unsigned_params, socket) do
    socket = assign(socket, calc: "")
    {:noreply, socket}
  end

  def handle_event("backspace", _unsigned_params, socket) do
    calc = String.slice(socket.assigns.calc, 0..-2//1)
    socket = assign(socket, calc: calc)
    {:noreply, socket}
  end

  def handle_event("equals", _unsigned_params, socket) do
    calc = Abacus.eval(socket.assigns.calc) |> elem(1)
    socket = assign(socket, calc: calc)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
      <.calculator><%= @calc %></.calculator>
    """
  end
end
