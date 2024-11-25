# PhxCalculator - WORK IN PROGRESS

# Brief Phoenix Overview
This Phoenix LiveView project is being created with the aim of putting into 
practice the theory and knowledge gained from the many 
open source tutorials provided by the wonderful
[dwyl](https://github.com/dwyl).

This readme will include a breakdown for anyone 
else starting their functional programming / elixir 
journey in the hopes that this will be another 
useful resource on that quest.

If you are looking for a complete beginner look into Phoenix and Elixir,
I'd strongly suggest reviewing the basics with
[dwyl-learn-elixir](https://github.com/dwyl/learn-elixir) and 
[dwyl-learn-phoenix](https://github.com/dwyl/learn-phoenix)
first, before coming back and seeing these technologies in action!

# Calculator Logic
The calculation logic implementation was made **incredibly** simple thanks to 
the elixir package [Abacus](https://github.com/narrowtux/abacus).

## Abacus

Utilizing the Abacus package kept our calculation logic _extremely easy_ and 
**highly** effective. It provides the `Abacus.eval()` function which converts 
Strings to a mathematical equation and calculates the result. It also 
makes error handling simple as the returned tuple can be pattern matched to 
either extract the result or handle the error. More on that later. 

The installation instructions on Abacus were out of date, the corrected
instructions are:

1. Add `abacus` to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    ...
    {:abacus, "~> 2.1.0"},
    ...
  ]
end
```

2.  Include `abacus` in the extra applications

```elixir
 def application do
    [
      mod: {PhxCalculator.Application, []},
      extra_applications: [:logger, :runtime_tools, :abacus] # here 
    ]
  end
```

We can now call `Abacus.eval()` in our project!

## Event handling

### `phx-click` and `phx-value`

To handle the event of clicking a button, I need my project to know that 
and _event_ has been triggered and the _value_ of button that has been pressed.

In Phoenix this is very simple, we can use 
[`phx-click`](https://hexdocs.pm/phoenix_live_view/bindings.html#click-events) 
and 
[`phx-value`](https://hexdocs.pm/phoenix_live_view/bindings.html#click-events)

The html for our calculated is in the 
`lib\phx_calculator_web\components\core_components.ex`
file to make our LiveView file cleaner, and in it we see `phx-click` 
on every button which triggers the corresponding event, and if a value is
needed then the corresponding `phx-value`:

```html
<button class="bg-gray-700 text-purple-800 h-16 font-mono text-3xl
rounded-lg" phx-click="number" phx-value-number="1">1</button>
```

**Note:** not every button needs to pass a value to the handler function, 
for example we can handle a `"clear"` or `"backspace"` event without any 
data being passed

```html
<button class="bg-gray-700 text-blue-400 h-16 font-mono text-3xl
rounded-lg" phx-click="clear">C</button>
```

### Mount
Before we dive into talking about the event handling it is worth briefly 
looking at our 
[`mount`/3](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:mount/3)
as it details the set-up of our 
[socket](https://hexdocs.pm/phoenix/Phoenix.Socket.html)
struct which is used in determining which inputs are permitted.

```elixir
def mount(_params, _session, socket) do
  socket = assign(socket, calc: "", mode: "", history: "")
  {:ok, socket}
end
```
Ok. So in our [assigns](https://hexdocs.pm/phoenix/Phoenix.Socket.html#assign/3)
we see we have the keys `calc`, `mode` and `history`.

- `calc` will be used to store the calculation string which is auto-rendered 
thanks to LiveView
- `mode` is very useful as it allows the system to 'know' what behavior the 
calculator is performing. This can be utilized to prevent illegal expressions
as we'll see shortly
- `history` will be used to store the calculation history of the session and 
render it to the history tab

### "number" event

All calculations start by clicking on a number (yes, or perhaps bracket..)
so let's have a look at that first. 

When a button is pressed with the `phx-click="number"`

```elixir
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
```

Ok, first thing to notice is that we are saving the phx-value in the **number**
variable with `%{"number" => number}`. 

By implementing a [`case`](https://hexdocs.pm/elixir/case-cond-and-if.html) 
we then either concatenate the new number to the existing `calc` string saved 
in the socket `calc = socket.assigns.calc <> number` and then update the socket,
or if the calculator is in display mode _(after clicking the equals button)_ 
we start a new string with `calc = number` and update the socket accordingly.


# Tests


