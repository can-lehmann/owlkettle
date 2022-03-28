# Widgets


## Container

```nim
renderable Container
```

### Fields

- `border_width: int`


## Bin

```nim
renderable Bin of Container
```

### Fields

- All fields from [Container](#Container)
- `child: Widget`


## Window

```nim
renderable Window of Bin
```

### Fields

- All fields from [Bin](#Bin)
- `title: string`
- `titlebar: Widget`
- `default_size: tuple[width, height: int] = (800, 600)`

### Example

```nim
Window:
  Label(text = "Hello, world")
```


## Box

```nim
renderable Box of Container
```

### Fields

- All fields from [Container](#Container)
- `orient: Orient`
- `spacing: int`
- `children: seq[PackedChild[Widget]]`
- `style: set[BoxStyle]`

### Example

```nim
Box:
  orient = OrientX
  Label(text = "Label")
  Button(text = "Button") {.expand: false.}
```


## Label

```nim
renderable Label
```

### Fields

- `text: string`
- `x_align: float = 0.5`
- `y_align: float = 0.5`
- `ellipsize: EllipsizeMode`

### Example

```nim
Label:
  text = "Hello, world!"
  x_align = 0.0
  ellipsize = EllipsizeEnd
```


## Icon

```nim
renderable Icon
```

### Fields

- `name: string`

### Example

```nim
Icon:
  name = "list-add-symbolic"
```


## Button

```nim
renderable Button of Bin
```

### Fields

- All fields from [Bin](#Bin)
- `style: set[ButtonStyle]`

### Events

- clicked: `proc ()`

### Example

```nim
Button:
  icon = "list-add-symbolic"
  style = {ButtonSuggested}
  proc clicked() =
    echo "clicked"

```

```nim
Button:
  text = "Delete"
  style = {ButtonDestructive}
```


## HeaderBar

```nim
renderable HeaderBar
```

### Fields

- `title: string`
- `subtitle: string`
- `show_close_button: bool = true`
- `left: seq[Widget]`
- `right: seq[Widget]`

### Example

```nim
Window:
  border_width = 12
  HeaderBar {.add_titlebar.}:
    title = "Title"
    subtitle = "Subtitle"
    Button {.add_left.}:
      icon = "list-add-symbolic"
    Button {.add_right.}:
      icon = "open-menu-symbolic"
```


## ScrolledWindow

```nim
renderable ScrolledWindow of Bin
```

### Fields

- All fields from [Bin](#Bin)


## Entry

```nim
renderable Entry
```

### Fields

- `text: string`
- `placeholder: string`
- `width: int = -1`
- `x_align: float = 0.0`

### Events

- changed: `proc (text: string)`

### Example

```nim
Entry:
  text = app.text
  proc changed(text: string) =
    app.text = text

```


## Paned

```nim
renderable Paned
```

### Fields

- `orient: Orient`
- `initial_position: int`
- `first: PanedChild[Widget]`
- `second: PanedChild[Widget]`


## DrawingArea

```nim
renderable DrawingArea
```

### Events

- draw: `proc (ctx: CairoContext; size: (int, int))`
- mouse_pressed: `proc (event: ButtonEvent)`
- mouse_released: `proc (event: ButtonEvent)`
- mouse_moved: `proc (event: MotionEvent)`


## ColorButton

```nim
renderable ColorButton
```

### Fields

- `color: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0)`
- `use_alpha: bool = false`

### Events

- changed: `proc (color: tuple[r, g, b, a: float])`


## Switch

```nim
renderable Switch
```

### Fields

- `state: bool`

### Events

- changed: `proc (state: bool)`


## ToggleButton

```nim
renderable ToggleButton of Button
```

### Fields

- All fields from [Button](#Button)
- `state: bool`

### Events

- changed: `proc (state: bool)`


## CheckButton

```nim
renderable CheckButton of ToggleButton
```

### Fields

- All fields from [ToggleButton](#ToggleButton)


## Popover

```nim
renderable Popover
```

### Fields

- `child: Widget`


## MenuButton

```nim
renderable MenuButton of Button
```

### Fields

- All fields from [Button](#Button)
- `popover: Widget`


## TextView

```nim
renderable TextView
```

### Fields

- `buffer: TextBuffer`
- `monospace: bool`

### Events

- changed: `proc ()`


## ListBoxRow

```nim
renderable ListBoxRow of Bin
```

### Fields

- All fields from [Bin](#Bin)


## ListBox

```nim
renderable ListBox
```

### Fields

- `rows: seq[Widget]`
- `selection_mode: SelectionMode`


## Frame

```nim
renderable Frame of Bin
```

### Fields

- All fields from [Bin](#Bin)
- `label: string`
- `align: tuple[x, y: float] = (0.0, 0.0)`


## DialogButton

```nim
renderable DialogButton
```

### Fields

- `text: string`
- `response: DialogResponse`
- `style: set[ButtonStyle]`


## Dialog

```nim
renderable Dialog
```

### Fields

- `buttons: seq[DialogButton]`


## FileChooserDialog

```nim
renderable FileChooserDialog of Dialog
```

### Fields

- All fields from [Dialog](#Dialog)
- `title: string = ""`
- `action: FileChooserAction`
- `filename: string = ""`


