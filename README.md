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
      
      Box(orient = OrientX, margin = 12, spacing = 6):
        Label(text = $app.counter) {.expand: true.}
        Button:
          text = "+"
          style = {ButtonSuggested}
          proc clicked() =
            app.counter += 1

brew(gui(App()))
```

The code above will result in the following application:

![Counter Application](docs/assets/introduction.png)

Owlkettle also supports building libadwaita apps.
To enable libadwaita, import `owlkettle/adw` and change the last line to `adw.brew(gui(App()))`.

![Counter Application using Adwaita Stylesheet](docs/assets/introduction.png)

## Installation

Owlkettle requires GTK 4 to be installed on your system.
You can install it by running `dnf install gtk4-devel` on Fedora or `apt install libgtk-4-dev` on Ubuntu.

```bash
$ nimble install owlkettle
```

## Documentation

You can find a reference of all widgets in [docs/widgets.md](docs/widgets.md).

If you want to cross compile checkout [docs/cross_compiling.md](docs/cross_compiling.md).

Additional examples can be found in the [examples](examples) folder.

## License

Owlkettle is licensed under the MIT license.
See `LICENSE.txt` for more information.
