defmodule PhxCalculatorWeb.CalculatorLive do
alias PhxCalculatorWeb.CoreComponents
  use PhxCalculatorWeb, :live_view
  import CoreComponents

  def mount(_params, _session, socket) do

    {:ok, socket}
  end

  def handle_event("number", _unsigned_params, socket) do

  end

  def handle_event("operation", _unsigned_params, socket) do

  end

  def handle_event("equals", _unsigned_params, socket) do

  end

  def render(assigns) do
    ~H"""
    <h1>Calculator </h1>
    <.calculator></.calculator>
    """
  end
end
