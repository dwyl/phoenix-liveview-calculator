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

In this section we will talk about the tests we used to obtain 100% test 
coverage. Instead of examining each test with a code snippet like we did 
with our functions, we'll examine the general test code structure, the helper 
function used to reduce code repetition, and then speak about the test cases 
in a more general manner. 

## File and code structure
The [testing](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)
in this project is organized into **describe** blocks 
containing the relevant test suite, which helps separate 
the logic and make it more readable and easier for the developer to 
figure out which test is failing (along with test names).

```elixir
describe "test suite name" do
  # Your test suite
end
```
The test themselves are named, and in this project we pass a `conn` instance
which we use with 
[`live/2`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html#live/2)
to spawn a a connected LiveView process enabling us to obtain a LiveView to
test.

> _Note: We're using Phoenix's 
[ConnCase](https://hexdocs.pm/phoenix/1.7.12/Phoenix.ConnTest.html#module-recycling)_

We test the `view` using 
[`render_click/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html#render_click/3)
which sends a click event to the view with value 
and returns the rendered result, and then we use `assert` to determine
whether the correct value has been calculated. 

```elixir
test "clear", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/")

  render_click(view, "number", number: "1")
  render_click(view, "clear")

  # screen should be empty
  assert render(view) =~ ~s(<div id="screen" class="mr-4"></div>)
end
```

So in this example we've simulated clicking the number `1` 
and then the `clear` button. 

We then check to see if our "screen" is empty on the calculator using 
assert and accessing the screen via its `id`. 


## Helper function 
Since this is a calculator, we'll be "pressing" a **lot** of buttons. 
Obviously we don't want to be typing _endless_ `render_click()`'s, 
which is where the following **helper function** comes in:

```elixir
defp apply_sequence(sequence, view, equals?) do
  Enum.each(sequence, fn map ->
    %{event: event, value: value} = map
    render_click(view, event, %{event => value})
  end)
  if(equals?) do
    render_click(view, "equals")
  end
end
```

Let's break it down:
- We pass in three parameters
  - `sequence`: is a list of key-value maps containing the click `event` 
  and its corresponding value
  - `view`: is the current LiveView of the process, the same one we create we 
  `live(conn, "/")`
  - `equals?`: is the boolean that determines whether we want to call the 
  `equals` event

- We loop through the `sequence` list with 
[` Enum.each()`](https://hexdocs.pm/elixir/1.12/Enum.html#each/2)
  - We pass `(sequence, fn map ->` to `Enum.each` which allows us to 
  run a function on each entry (`map`) of `sequence` list
  - Using [pattern matching](https://hexdocs.pm/elixir/pattern-matching.html)
  we destruct the map into its components `event` and `value`
  - Then call `render_click()` with that data

- If `equals?` is `true` we also render the `equals` event after the sequence.

This function allows us to increase readability and reduce repeated code.

For example, look at how it's used an addition test:

```elixir
# Addition block
test "with identity element", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/")

  apply_sequence([
  %{event: "number", value: "1"},
  %{event: "operator", value: "+"},
  %{event: "number", value: "0"}
  ], view, true)

  assert render(view) =~ ~s(<div id="screen" class="mr-4">1</div>)
end
```

We can clearly read what the test is doing, and we didn't have to type
_four_ **render_click()** functions. Awesome!

## Connection test

## Addition, multiplication, division, subtraction

In the addition test suite, and indeed all test suites involving a calculation, 
I have tried to not only ensure 
[branch coverage]()
but also to test all behaviours of the operator and test correct handling of every 
button.

To ensure this, each test suite that handles a calculation has a similar format:

- Test the operator with the 0 element 
- Test the operator with the 
[identity element](https://brilliant.org/wiki/identity-element/) 
- Test the operator with numbers consisting of every digit, e.g. 
`1.2345 + 6.7890` 

> Notice that for addition and subtraction the 0 element _is_ the identity 
> element 

The `subtraction` test suite is slightly different as we also test a 
calculation that returns a negative result, as well as a positive one. 

```elixir
# Subtraction block
describe "subtraction" do
  test "with identity element", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    apply_sequence([
      %{event: "number", value: "1"},
      %{event: "operator", value: "-"},
      %{event: "number", value: "0"}
      ], view, true)

    assert render(view) =~ ~s(<div id="screen" class="mr-4">1</div>)
  end

  test "with positive result", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    apply_sequence([
      %{event: "number", value: "1.2345"},
      %{event: "operator", value: "-"},
      %{event: "number", value: "6.7890"}
    ], view, true)

    assert render(view) =~ "5.5545"
  end

  test "with negative result", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    apply_sequence([
      %{event: "number", value: "1.2345"},
      %{event: "operator", value: "-"},
      %{event: "number", value: "6.7890"}
    ], view, true)

    assert render(view) =~ "-5.5545"
  end
end
```

## Deletion 
The deletion test suite is testing behavior involved in removing 
data from the screen, either with the `backspace` or `clear` operator.

### Backspace

We test two behaviors (branches) of our `backspace` logic, what happens after 
we click backspace when the calculator is in "display" mode and when it is not
(i.e when it is in "number" or "operator" mode).

Clearly, when not in "display" mode we'd like the the `backspace` event to 
remove the last digit of whatever is currently on the screen. After using 
our `apply_sequence()` with numbers `3`, `2`, `1` we can just check that the 
`1` was removed with:

```elixir
render_click(view, "backspace")

assert render(view) =~ ~s(<div id="screen" class="mr-4">32</div>)
```

And then for "display" mode the backspace event shouldn't do anything,
so we just assert that the result of the calculation is still present
after the `apply_sequence` followed by the `equals` event:

```elixir
render_click(view, "backspace")

# nothing should happen
assert render(view) =~ "1.0"
```

### Clear

To test the `clear` event, all we need to do is trigger a `number` event
followed by the `clear` event and then assert whether the screen is empty:

```elixir
render_click(view, "number", number: "1")
render_click(view, "clear")

# screen should be empty
assert render(view) =~ ~s(<div id="screen" class="mr-4"></div>)
```

## Rendering logic  

This test suite is for testing the behavior ensuring legal calculations
are being typed (e.g stopping a calculation like `1+-+=`). We'll quickly
examine each test. 

```elixir
test "number after equals", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/")

  apply_sequence([
    %{event: "number", value: "1"},
    %{event: "operator", value: "/"},
    %{event: "number", value: "1"}
    ], view, true)
    render_click(view, "number", %{number: "2"})

  assert render(view) =~ ~s(<div id="screen" class="mr-4">2</div>)
end
```
Here we are checking that when entering a number after the calculator 
is displaying a result a new calculation (`calc` string) is started. 
So when we use `render_click(view, "number", %{number: "2"})` after 
calculating the sequence the screen should only contain the `2`. 

Next we test the behavior of two operators being clicked in a row:

```elixir
test "operator after operator", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/")

  apply_sequence([
    %{event: "number", value: "1"},
    %{event: "operator", value: "+"},
    %{event: "operator", value: "-"}
    ], view, false)

  # new operator replaces old operator
  assert render(view) =~ "1-"
end
```

As we have seen, in this design the desired action is to replace the
first operator with the second, so we simply assert that all that is 
being displayed is `1-` after the sequence `1`, `+`, `-`. 

The last two tests are examining the behavior of an operator _followed_
by an equals sign (e.g. `1+=`) and the operator _following_ a result 
(e.g. `1+1=+1). 

In each case nothing should happen:

```elixir
test "operator with equals", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/")

  apply_sequence([
    %{event: "number", value: "1"},
    %{event: "operator", value: "/"},
    %{event: "number", value: "1"}
    ], view, true)
    render_click(view, "operator", operator: "+")

  # nothing should happen
  assert render(view) =~ "1.0"
end
```
So we assert that the result is still being displayed after inputting 
an operator, and..

```elixir
test "equals after operator", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/")

  apply_sequence([
    %{event: "number", value: "1"},
    %{event: "operator", value: "+"}
    ], view, true)

  # nothing should happen
  assert render(view) =~ "1+"
end
```

We check that the `equals` event (which we triggered by passing 
`true` to the helper function) does nothing.


## Brackets


