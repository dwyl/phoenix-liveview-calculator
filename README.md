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

### The `number` event

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

### The `backspace` event 

We'll examine the `backspace event next as the helper function is 
also used for the `operator` event. 

First let's examine the `handle_event/3`:

```elixir
 def handle_event("backspace", _unsigned_params, socket) do
  case socket.assigns.mode do
    "display" ->
      {:noreply, socket}

    _ ->
      backspace(socket)
  end
end
```

Very simple logic thanks to our helper function. If the calculator is in 
display mode we tell our function to do nothing, otherwise we call the 
**helper function** to remove the last character of the calc string.

The helper function works as follows:

```elixir 
defp backspace(socket, operator \\ "") do
  calc = String.slice(socket.assigns.calc, 0..-2//1) <> operator
  socket = assign(socket, calc: calc)
  {:noreply, socket}
end
```

Thanks to [String.slice()](https://hexdocs.pm/elixir/String.html#slice/2)
we can remove the last character. We specify a slice from the range of 
index `0` to `-2//1`. This just means the second to last index (`-2`), 
but we have to specify that the range is increasing with `//1` for 
`.slice()` to be happy. 

#### Why pass `operator \\ ""`?
The reason we're passing an operator with a default of an empty string is so
when we call this helper function with a valid operator, we just **replace** 
the last element of the calc string with the passed in `operator` using 
concatenation. We'll see why that's handy next. 


### The `operator` event 

Examining our handler function we see:

```elixir 
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
```

Much like the `number` event we're saving the passed `operator` variable 
and using that to build the calculation string. But notice we are also 
making use of a case which again is utilizing the `socket.assigns.mode`
to determine what the function should do. 

If we're in mode..
- `number`, meaning the  last input was a number, we simply concatenate 
the `operator` to the `calc` string and update the socket, like we've just
seen before. 
  - i.e if `calc = "1"` and `operator="+"` the updated socket contains `calc = "1+"`

- `operator`, meaning the last input to the calc string was another operator,
we remove the previous operator using the `backspace()` **helper function** 
and then concatenate the new operator as we do not want invalid inputs.
  - i.e if `calc = "1+"` and `operator="-"` the updated socket contains `calc = "1-"`

- `_`, meaning if the previous input was neither a number or an operator then 
we tell our function to do nothing as we do not want to add an operator to the 
calc string unless it follows a number (brackets are handled by the `numbers` 
event)

In the `operator` case we saw the `backspace helper function being used again,
this time we passed in our operator. Like we saw before, that just means 
we concatenate on the new operator once we've used `String.slice()`.

### The `clear` event 

This ones _super simple_. All we need to do is set the calc string to be an 
empty string.

```elixir
def handle_event("clear", _unsigned_params, socket) do
  socket = assign(socket, calc: "")
  {:noreply, socket}
end
```

Simples!

### The `equals` event 

The actual handler function is actually very basic, thanks to another 
**helper function**, which in turn is simple thanks to the aforementioned
`Abacus.eval`.

```elixir
def handle_event("equals", _unsigned_params, socket) do
  case socket.assigns.mode do
    "number" ->
      calculate(socket)

    _ ->
      {:noreply, socket}
  end
end
```

Once again we utilize a `case`, which lets us only call the `calculate()` 
function if the last input was a number which is always the case for valid inputs.

>_Remember that brackets are classed as a number_

For example, the strings:

- `1+2`
- `3-2*1`
- `5 / (3 - 2)`

would all call the `calculate()` function and these strings:

- `1+`
- `12/3-`

would do nothing. 

Let's now dive into the function that's doing all the work:

```elixir
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
```

Of course, another case.

This time, we are 
[pattern matching](https://hexdocs.pm/elixir/pattern-matching.html) 
the result of `Abacus.eval(socket.assigns.socket)` with tuples:

- `{:ok, result}`: is returned when the `.eval` is successful and 
extracts the result which we can pass to our socket.
- `{:error, err}`: is returned when `.eval` is unsuccessful, in cases
like dividing by 0 or improper use of brackets. 

In both cases we set `mode: "display"` which affects certain functions
as we have seen, and we either set the calc string to the result or the 
"ERROR" string. 


# Tests


