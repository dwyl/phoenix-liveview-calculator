defmodule PhxCalculatorWeb.CalculatorLive do
alias PhxCalculatorWeb.CoreComponents
  use PhxCalculatorWeb, :live_view
  import CoreComponents

  def mount(_params, _session, socket) do
    socket = assign(socket, calc: "", mode: "", history: "")
    {:ok, socket}
  end

  def handle_event("number", %{"number" => number}, socket) do
    case socket.assigns.mode do
      "display" ->
        calc = number
        socket = assign(socket, calc: calc, mode: "number")
        {:noreply, socket}

      _ ->
        calc = socket.assigns.calc <> number
        socket = assign(socket, calc: calc, mode: "number")
        {:noreply, socket}
    end
  end

  def handle_event("operator", %{"operator" => operator}, socket) do
    case socket.assigns.mode do
      "number" ->
        calc = socket.assigns.calc <> operator
        socket = assign(socket, calc: calc, mode: "operator")
        {:noreply, socket}

      "operator" ->
        backspace(socket, operator)

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("clear", _unsigned_params, socket) do
    socket = assign(socket, calc: "")
    {:noreply, socket}
  end

  def handle_event("backspace", _unsigned_params, socket) do
    case socket.assigns.mode do
      "display" ->
        {:noreply, socket}

      _ ->
        backspace(socket)
    end
  end

  def handle_event("equals", _unsigned_params, socket) do
    case socket.assigns.mode do
      "number" ->
        calculate(socket)

      _ ->
        {:noreply, socket}
    end
  end

  defp calculate(socket) do
    case Abacus.eval(socket.assigns.calc) do
      {:ok, result} ->
        socket = assign(socket, calc: result, mode: "display")
        {:noreply, socket}

      {:error, err} ->
        socket = assign(socket, calc: "ERROR", mode: "display")
        {:noreply, socket}
    end
  end

  defp backspace(socket, operator \\ "") do
    calc = String.slice(socket.assigns.calc, 0..-2//1) <> operator
    socket = assign(socket, calc: calc)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
      <.calculator><%= @calc %></.calculator>
    """
  end
end
