# Widgets


## BaseWidget

```nim
renderable BaseWidget
```

###### Fields

- `sensitive: bool = true`
- `size_request: tuple[x, y: int] = (-1, -1)`

###### Setters

- `margin: int`
- `margin: Margin`


## Window

```nim
renderable Window of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `title: string`
- `titlebar: Widget`
- `default_size: tuple[width, height: int] = (800, 600)`
- `child: Widget`

###### Events

- close: `proc ()`

###### Example

```nim
Window:
  Label(text = "Hello, world")
```


## Box

```nim
renderable Box of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `orient: Orient`
- `spacing: int`
- `children: seq[BoxChild[Widget]]`
- `style: set[BoxStyle]`

###### Example

```nim
Box:
  orient = OrientX
  Label(text = "Label") {.expand: true.}
  Button(text = "Button")
```

```nim
Box:
  orient = OrientY
  margin = 12
  spacing = 6
  for it in 0 ..< 5:
    Label(text = "Label " & $it) {.expand: true.}
```

```nim
HeaderBar {.add_titlebar.}:
  Box {.add_left.}:
    style = {BoxLinked}
    for it in 0 ..< 5:
      Button:
        text = "Button " & $it
        proc clicked() =
          echo it

```


## Label

```nim
renderable Label of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `text: string`
- `x_align: float = 0.5`
- `y_align: float = 0.5`
- `ellipsize: EllipsizeMode`
- `wrap: bool = false`
- `use_markup: bool = false`

###### Example

```nim
Label:
  text = "Hello, world!"
  x_align = 0.0
  ellipsize = EllipsizeEnd
```

```nim
Label:
  text = "Test ".repeat(50)
  wrap = true
```

```nim
Label:
  text = "<b>Bold</b>, <i>Italic</i>, <span font=\"20\">Font Size</span>"
  use_markup = true
```


## Icon

```nim
renderable Icon of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `name: string`
- `pixel_size: int = -1`

###### Example

```nim
Icon:
  name = "list-add-symbolic"
```

```nim
Icon:
  name = "object-select-symbolic"
  pixel_size = 100
```


## Button

```nim
renderable Button of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `style: set[ButtonStyle]`
- `child: Widget`

###### Setters

- `text: string`
- `icon: string`

###### Events

- clicked: `proc ()`

###### Example

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

```nim
Button:
  text = "Inactive Button"
  sensitive = false
```


## HeaderBar

```nim
renderable HeaderBar of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `title: Widget`
- `show_title_buttons: bool = true`
- `left: seq[Widget]`
- `right: seq[Widget]`

###### Example

```nim
Window:
  title = "Title"
  HeaderBar {.add_titlebar.}:
    Button {.add_left.}:
      icon = "list-add-symbolic"
    Button {.add_right.}:
      icon = "open-menu-symbolic"
```


## ScrolledWindow

```nim
renderable ScrolledWindow of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `child: Widget`


## Entry

```nim
renderable Entry of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `text: string`
- `placeholder: string`
- `width: int = -1`
- `x_align: float = 0.0`
- `visibility: bool = true`
- `invisible_char: Rune = '*'.Rune`

###### Events

- changed: `proc (text: string)`
- activate: `proc ()`

###### Example

```nim
Entry:
  text = app.text
  proc changed(text: string) =
    app.text = text

```

```nim
Entry:
  text = app.query
  placeholder = "Search..."
  proc changed(query: string) =
    app.query = query

  proc activate() =
    ## Runs when enter is pressed
    echo app.query

```

```nim
Entry:
  placeholder = "Password"
  visibility = false
  invisible_char = '*'.Rune
```


## Paned

```nim
renderable Paned of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `orient: Orient`
- `initial_position: int`
- `first: PanedChild[Widget]`
- `second: PanedChild[Widget]`

###### Example

```nim
Paned:
  initial_position = 200
  Box(orient = OrientY) {.resize: false.}:
    Label(text = "Sidebar") {.expand: true.}
  Box(orient = OrientY) {.resize: true.}:
    Label(text = "Content") {.expand: true.}
```


## DrawingArea

```nim
renderable DrawingArea of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `focusable: bool`
- `events: DrawingAreaEvents`

###### Events

- draw: `proc (ctx: CairoContext; size: (int, int)): bool`
- mouse_pressed: `proc (event: ButtonEvent): bool`
- mouse_released: `proc (event: ButtonEvent): bool`
- mouse_moved: `proc (event: MotionEvent): bool`
- key_pressed: `proc (event: KeyEvent): bool`
- key_released: `proc (event: KeyEvent): bool`


## ColorButton

```nim
renderable ColorButton of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `color: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0)`
- `use_alpha: bool = false`

###### Events

- changed: `proc (color: tuple[r, g, b, a: float])`


## Switch

```nim
renderable Switch of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `state: bool`

###### Events

- changed: `proc (state: bool)`

###### Example

```nim
Switch:
  state = app.state
  proc changed(state: bool) =
    app.state = state

```


## ToggleButton

```nim
renderable ToggleButton of Button
```

###### Fields

- All fields from [Button](#Button)
- `state: bool`

###### Events

- changed: `proc (state: bool)`

###### Example

```nim
ToggleButton:
  text = "Current State: " & $app.state
  state = app.state
  proc changed(state: bool) =
    app.state = state

```


## CheckButton

```nim
renderable CheckButton of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `state: bool`

###### Events

- changed: `proc (state: bool)`

###### Example

```nim
CheckButton:
  state = app.state
  proc changed(state: bool) =
    app.state = state

```


## Popover

```nim
renderable Popover of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `child: Widget`


## MenuButton

```nim
renderable MenuButton of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `child: Widget`
- `popover: Widget`

###### Setters

- `text: string`
- `icon: string`


## Separator

```nim
renderable Separator of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `orient: Orient`


## TextView

```nim
renderable TextView of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `buffer: TextBuffer`
- `monospace: bool`

###### Events

- changed: `proc ()`


## ListBoxRow

```nim
renderable ListBoxRow of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `child: Widget`

###### Events

- activate: `proc ()`

###### Example

```nim
ListBox:
  for it in 0 ..< 10:
    ListBoxRow {.add_row.}:
      proc activate() =
        echo it

      Label(text = $it)
```


## ListBox

```nim
renderable ListBox of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `rows: seq[Widget]`
- `selection_mode: SelectionMode`
- `selected: HashSet[int]`

###### Events

- select: `proc (rows: HashSet[int])`

###### Example

```nim
ListBox:
  for it in 0 ..< 10:
    Label(text = $it)
```


## FlowBoxChild

```nim
renderable FlowBoxChild of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `child: Widget`

###### Example

```nim
FlowBox:
  columns = 1 .. 5
  for it in 0 ..< 10:
    FlowBoxChild {.add_child.}:
      Label(text = $it)
```


## FlowBox

```nim
renderable FlowBox of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `homogeneous: bool`
- `row_spacing: int`
- `column_spacing: int`
- `columns: HSlice[int, int] = 1 .. 5`
- `selection_mode: SelectionMode`
- `children: seq[Widget]`

###### Example

```nim
FlowBox:
  columns = 1 .. 5
  for it in 0 ..< 10:
    Label(text = $it)
```


## Frame

```nim
renderable Frame of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `label: string`
- `align: tuple[x, y: float] = (0.0, 0.0)`
- `child: Widget`

###### Example

```nim
Frame:
  label = "Frame Title"
  align = (0.2, 0.0)
  Label:
    text = "Content"
```


## DialogButton

```nim
renderable DialogButton
```

###### Fields

- `text: string`
- `response: DialogResponse`
- `style: set[ButtonStyle]`

###### Setters

- `res: DialogResponseKind`


## Dialog

```nim
renderable Dialog of Window
```

###### Fields

- All fields from [Window](#Window)
- `buttons: seq[DialogButton]`


## BuiltinDialog

```nim
renderable BuiltinDialog
```

###### Fields

- `title: string`
- `buttons: seq[DialogButton]`


## FileChooserDialog

```nim
renderable FileChooserDialog of BuiltinDialog
```

###### Fields

- All fields from [BuiltinDialog](#BuiltinDialog)
- `action: FileChooserAction`
- `filename: string`


## ColorChooserDialog

```nim
renderable ColorChooserDialog of BuiltinDialog
```

###### Fields

- All fields from [BuiltinDialog](#BuiltinDialog)
- `color: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0)`
- `use_alpha: bool = false`


## MessageDialog

```nim
renderable MessageDialog of BuiltinDialog
```

###### Fields

- All fields from [BuiltinDialog](#BuiltinDialog)
- `message: string`


## AboutDialog

```nim
renderable AboutDialog of BuiltinDialog
```

###### Fields

- All fields from [BuiltinDialog](#BuiltinDialog)
- `program_name: string`
- `logo: string`
- `copyright: string`
- `version: string`
- `license: string`
- `credits: seq[(string, seq[string])]`


