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
        Label(text = $app.counter)
        Button {.expand: false.}:
          text = "+"
          style = {ButtonSuggested}
          proc clicked() =
            app.counter += 1

brew(gui(App()))
```

The code above will result in the following application:

<img alt="Counter Application" src="docs/assets/introduction.png" width="228px">

Owlkettle also supports building libadwaita apps.
To enable libadwaita, import `owlkettle/adw` and change the last line to `adw.brew(gui(App()))`.

<img alt="Counter Application using Adwaita Stylesheet" src="docs/assets/introduction_adwaita.png" width="322px">

## Installation

Owlkettle requires GTK 4 to be installed on your system.
You can install it by running `dnf install gtk4-devel libadwaita-devel` on Fedora or `apt install libgtk-4-dev libadwaita-1-dev` on Ubuntu.

```bash
$ nimble install owlkettle
```

## Documentation

You can find a reference of all widgets in [docs/widgets.md](docs/widgets.md).

If you want to cross compile checkout [docs/cross_compiling.md](docs/cross_compiling.md).

Additional examples can be found in the [examples](examples) folder.

A guide for migrating from owlkettle 1.x.x to 2.0.0 [is available here](docs/migrating_1_to_2.md).

## License

Owlkettle is licensed under the MIT license.
See `LICENSE.txt` for more information.
