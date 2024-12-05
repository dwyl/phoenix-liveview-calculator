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
       <!-- Calculator -->
       <div class="flex min-h-screen flex-1 flex-col justify-between bg-gray-900 p-6">
        <!-- Screen -->
        <div class="mb-4 flex h-32 items-end justify-end rounded-lg bg-gray-800
        font-mono text-6xl text-white">
          <div id="screen" class="mr-4"><%= @calc %></div>
        </div>

        <!-- Buttons -->
        <div class="grid flex-grow grid-cols-4 gap-1">
          <%!-- Row 1 --%>
          <button class="button-grey-blue" phx-click="number"
           phx-value-number="(">(</button>

          <button class="button-grey-blue" phx-click="number"
           phx-value-number=")">)</button>

          <button class="button-grey-blue" phx-click="backspace">
          &larr;</button>

          <button class="button-grey-blue" phx-click="clear">C</button>

          <%!-- Row 2 --%>
          <button class="button-grey-purple" phx-click="number"
           phx-value-number="1">1</button>

          <button class="button-grey-purple" phx-click="number"
           phx-value-number="2">2</button>

          <button class="button-grey-purple" phx-click="number"
           phx-value-number="3">3</button>

          <button class="button-grey-blue" phx-click="operator"
          phx-value-operator="+">+</button>

          <%!-- Row 3 --%>
          <button class="button-grey-purple" phx-click="number"
           phx-value-number="4">4</button>

          <button class="button-grey-purple" phx-click="number"
           phx-value-number="5">5</button>

          <button class="button-grey-purple" phx-click="number"
           phx-value-number="6">6</button>

          <button class="button-grey-blue" phx-click="operator"
          phx-value-operator="-">-</button>

          <%!-- Row 4 --%>
          <button class="button-grey-purple" phx-click="number"
           phx-value-number="7">7</button>

          <button class="button-grey-purple" phx-click="number"
           phx-value-number="8">8</button>

          <button class="button-grey-purple" phx-click="number"
           phx-value-number="9">9</button>

          <button class="button-grey-blue" phx-click="operator"
          phx-value-operator="*">x</button>

          <%!-- Row 5 --%>
          <button class="button-grey-purple" phx-click="number"
           phx-value-number=".">.</button>

          <button class="button-grey-purple" phx-click="number"
           phx-value-number="0">0</button>

          <button class="min-h-[4rem] rounded-lg bg-purple-900 font-mono
          text-3xl text-black hover:bg-purple-800" phx-click="equals">=</button>

          <button class="button-grey-blue" phx-click="operator"
          phx-value-operator="/">&divide</button>

        </div>
      </div>



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
