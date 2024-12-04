defmodule PhxCalculatorWeb.CalculatorLive do
alias PhxCalculatorWeb.CoreComponents
  use PhxCalculatorWeb, :live_view
  import CoreComponents

  def mount(_params, _session, socket) do

    # dbg(socket)
    socket =
      assign(socket, calc: "", mode: "")

    socket = stream(socket, :calcs, [%{id: 1, title: "No history"}])

    # socket =
    #   stream(socket, :calcs, [
    #     %{id: 1, title: "apple"}
    #   ], at: 0)

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
        # update_history(socket)
      _ ->
        {:noreply, socket}
    end
  end

  defp calculate(socket) do
    case Abacus.eval(socket.assigns.calc) do
      {:ok, result} ->
        socket = assign(socket, calc: result, mode: "display")
        {:noreply, socket}

      {:error, _err} ->
        socket = assign(socket, calc: "ERROR", mode: "display")
        {:noreply, socket}
    end
  end

  defp update_history(socket) do
    string = socket.assigns.calc
    stream_insert(socket, :calcs, %{id: 1, string: string})
    {:ok, socket}
  end

  defp backspace(socket, operator \\ "") do
    calc = String.slice(socket.assigns.calc, 0..-2//1) <> operator
    socket = assign(socket, calc: calc)
    {:noreply, socket}
  end

  def render(assigns) do

    ~H"""
    <div class="flex min-h-screen flex-col bg-gray-900 lg:flex-row">
      <.calculator><%= @calc %></.calculator>


      <!-- History -->
        <div class="flex min-h-screen flex-1 flex-col bg-gray-600 p-4">
          <div class="mb-4 flex h-32 items-end justify-end rounded-lg
          bg-gray-800 font-mono text-xl text-white">
            <div class="mr-4">

            <ul id="calcs" phx-update="stream">
              <li :for={{dom_id, calc} <- @streams.calcs} id={dom_id}>
                <%= calc.title %>
              </li>
            </ul>
            </div>
          </div>
          <!-- Additional History content -->
        </div>
      </div>
    """
  end
end
