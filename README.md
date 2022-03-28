# Owlkettle
*Freshly brewed user interfaces.*

Owlkettle is a declarative user interface framework based on GTK.

```nim
import owlkettle

viewable App:
  counter: int

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Counter"
      default_size = (200, 60)
      border_width = 12
      
      Box(orient = OrientX, spacing = 6):
        Label(text = $app.counter)
        Button:
          text = "+"
          style = {ButtonSuggested}
          proc clicked() =
            app.counter += 1

brew(gui(App()))
```

The code above will result in the following application:

![Counter Application](docs/assets/introduction.png)

## Installation

Owlkettle requires GTK 3 to be installed on your system.
You can install it by running `dnf install gtk3-devel` on Fedora or `apt install libgtk-3-dev` on Ubuntu.

```bash
$ nimble install https://github.com/can-lehmann/owlkettle
```

## Documentation

You can find a reference of all widgets in [docs/widgets.md](docs/widgets.md).

Additional examples can be found in the [examples](examples) folder.

## License

Owlkettle is licensed under the MIT license.
See `LICENSE.txt` for more information.
