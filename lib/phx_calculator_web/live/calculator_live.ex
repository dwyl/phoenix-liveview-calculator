defmodule PhxCalculatorWeb.CalculatorLive do
alias PhxCalculatorWeb.CoreComponents
  use PhxCalculatorWeb, :live_view
  import CoreComponents

  def mount(_params, _session, socket) do
    socket = assign(socket, calc: "0")
    {:ok, socket}
  end

  def handle_event("button-press", %{"input" => input}, socket) do
    calc =
    case socket.assigns.calc do
      "0" -> ""
      _ -> socket.assigns.calc
    end
    socket = assign(socket, calc: calc <> input)
    {:noreply, socket}
  end

  def handle_event("equals", _unsigned_params, socket) do

  end

  def render(assigns) do
    ~H"""
    <h1>Calculator </h1>
    <.calculator><%= @calc %></.calculator>
    """
  end
end
