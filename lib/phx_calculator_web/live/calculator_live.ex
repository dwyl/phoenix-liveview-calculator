defmodule PhxCalculatorWeb.CalculatorLive do
  use PhxCalculatorWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="bg-slate-600 rounded-xl h-96 pt-4 px-4 w-80 justify-center">
      <div class="bg-green-200 rounded-lg h-14 mb-6">
        0
      </div>

      <div class="flex flex-col space-y-4 justify-between">

        <div class="flex flex-row w-full justify-between">
          <button class="bg-slate-300 w-14 h-14 rounded-lg">1</button>
          <button class="bg-slate-300 w-14 h-14 rounded-lg">2</button>
          <button class="bg-slate-300 w-14 h-14 rounded-lg">3</button>
          <button class="bg-yellow-300 w-14 h-14 rounded-lg">&divide</button>
        </div>

        <div class="flex flex-row w-full justify-between">
          <button class="bg-slate-300 w-14 h-14 rounded-lg">4</button>
          <button class="bg-slate-300 w-14 h-14 rounded-lg">5</button>
          <button class="bg-slate-300 w-14 h-14 rounded-lg">6</button>
          <button class="bg-yellow-300 w-14 h-14 rounded-lg">X</button>
        </div>

        <div class="flex flex-row w-full justify-between">
          <button class="bg-slate-300 w-14 h-14 rounded-lg">7</button>
          <button class="bg-slate-300 w-14 h-14 rounded-lg">8</button>
          <button class="bg-slate-300 w-14 h-14 rounded-lg">9</button>
          <button class="bg-yellow-300 w-14 h-14 rounded-lg">-</button>
        </div>

        <div class="flex flex-row w-full justify-between">
          <button class="bg-slate-300 w-14 h-14 rounded-lg">0</button>
          <button class="bg-slate-300 w-14 h-14 rounded-lg">.</button>
          <button class="bg-orange-300 w-14 h-14 rounded-lg">=</button>
          <button class="bg-yellow-300 w-14 h-14 rounded-lg">+</button>
        </div>

      </div>
    </div>
    """
  end
end
