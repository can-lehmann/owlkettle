# Owlkettle
### Freshly brewed user interfaces.

Owlkettle is a declarative user interface framework based on GTK.

```nim
import owlkettle

viewable App:
  counter: int

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Counter"
      border_width = 12
      default_size = (200, 60)
      Box(orient = OrientX, spacing = 6):
        Label(text = $app.counter)
        Button:
          text = "+"
          style = {ButtonSuggested}
          proc clicked() =
            app.counter += 1

brew(gui(App()))
```

## Installation

```bash
$ nimble install https://github.com/can-lehmann/owlkettle
```

## License

Owlkettle is licensed under the MIT license.
See `LICENSE.txt` for more information.
