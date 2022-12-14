# Widgets


## BaseWidget

```nim
renderable BaseWidget
```

###### Fields

- `sensitive: bool = true`
- `sizeRequest: tuple[x, y: int] = (-1, -1)`
- `tooltip: string = ""`

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
- `defaultSize: tuple[width, height: int] = (800, 600)`
- `child: Widget`

###### Events

- close: `proc ()`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`
- `addTitlebar`

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

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`
  - `expand = true`
  - `hAlign = AlignFill`
  - `vAlign = AlignFill`

###### Example

```nim
Box:
  orient = OrientX
  Label(text = "Label")
  Button(text = "Button") {.expand: false.}
```

```nim
Box:
  orient = OrientY
  margin = 12
  spacing = 6
  for it in 0 ..< 5:
    Label(text = "Label " & $it)
```

```nim
HeaderBar {.addTitlebar.}:
  Box {.addLeft.}:
    style = {BoxLinked}
    for it in 0 ..< 5:
      Button {.expand: false.}:
        text = "Button " & $it
        proc clicked() =
          echo it

```


## Overlay

```nim
renderable Overlay of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `child: Widget`
- `overlays: seq[OverlayChild[Widget]]`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`
- `addOverlay`
  - `hAlign = AlignFill`
  - `vAlign = AlignFill`


## Label

```nim
renderable Label of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `text: string`
- `xAlign: float = 0.5`
- `yAlign: float = 0.5`
- `ellipsize: EllipsizeMode`
- `wrap: bool = false`
- `useMarkup: bool = false`
- `style: set[LabelStyle]`

###### Example

```nim
Label:
  text = "Hello, world!"
  xAlign = 0.0
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
  useMarkup = true
```


## Icon

```nim
renderable Icon of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `name: string`
- `pixelSize: int = -1`

###### Example

```nim
Icon:
  name = "list-add-symbolic"
```

```nim
Icon:
  name = "object-select-symbolic"
  pixelSize = 100
```


## Button

```nim
renderable Button of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `style: set[ButtonStyle]`
- `child: Widget`
- `shortcut: string`

###### Setters

- `text: string`
- `icon: string`

###### Events

- clicked: `proc ()`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`

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

```nim
Button:
  text = "Copy"
  shortcut = "<Ctrl>C"
  proc clicked() =
    app.writeClipboard("Hello, world!")

```


## HeaderBar

```nim
renderable HeaderBar of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `title: Widget`
- `showTitleButtons: bool = true`
- `left: seq[Widget]`
- `right: seq[Widget]`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `addTitle`
- `addLeft`
- `addRight`

###### Example

```nim
Window:
  title = "Title"
  HeaderBar {.addTitlebar.}:
    Button {.addLeft.}:
      icon = "list-add-symbolic"
    Button {.addRight.}:
      icon = "open-menu-symbolic"
```


## ScrolledWindow

```nim
renderable ScrolledWindow of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `child: Widget`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`


## Entry

```nim
renderable Entry of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `text: string`
- `placeholder: string`
- `width: int = -1`
- `maxWidth: int = -1`
- `xAlign: float = 0.0`
- `visibility: bool = true`
- `invisibleChar: Rune = '*'.Rune`
- `style: set[EntryStyle]`

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
  invisibleChar = '*'.Rune
```


## Paned

```nim
renderable Paned of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `orient: Orient`
- `initialPosition: int`
- `first: PanedChild[Widget]`
- `second: PanedChild[Widget]`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`
  - `resize = true`
  - `shrink = false`

###### Example

```nim
Paned:
  initialPosition = 200
  Box(orient = OrientY) {.resize: false.}:
    Label(text = "Sidebar")
  Box(orient = OrientY) {.resize: true.}:
    Label(text = "Content")
```


## CustomWidget

```nim
renderable CustomWidget of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `focusable: bool`
- `events: CustomWidgetEvents`

###### Events

- mousePressed: `proc (event: ButtonEvent): bool`
- mouseReleased: `proc (event: ButtonEvent): bool`
- mouseMoved: `proc (event: MotionEvent): bool`
- scroll: `proc (event: ScrollEvent): bool`
- keyPressed: `proc (event: KeyEvent): bool`
- keyReleased: `proc (event: KeyEvent): bool`


## DrawingArea

```nim
renderable DrawingArea of CustomWidget
```

###### Fields

- All fields from [CustomWidget](#CustomWidget)

###### Events

- draw: `proc (ctx: CairoContext; size: (int, int)): bool`


## GlArea

```nim
renderable GlArea of CustomWidget
```

###### Fields

- All fields from [CustomWidget](#CustomWidget)
- `useEs: bool = false`
- `requiredVersion: tuple[major, minor: int] = (4, 3)`
- `hasDepthBuffer: bool = true`
- `hasStencilBuffer: bool = false`

###### Events

- setup: `proc (size: (int, int)): bool`
- render: `proc (size: (int, int)): bool`


## ColorButton

```nim
renderable ColorButton of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `color: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0)`
- `useAlpha: bool = false`

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


## LinkButton

```nim
renderable LinkButton of Button
```

###### Fields

- All fields from [Button](#Button)
- `uri: string`
- `visited: bool`


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

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`


## PopoverMenu

```nim
renderable PopoverMenu of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `pages: Table[string, Widget]`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`
  - `name = "main"`


## MenuButton

```nim
renderable MenuButton of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `child: Widget`
- `popover: Widget`
- `style: set[ButtonStyle]`

###### Setters

- `text: string`
- `icon: string`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `addChild`
- `add`


## ModelButton

```nim
renderable ModelButton of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `text: string`
- `icon: string`
- `menuName: string`

###### Events

- clicked: `proc ()`


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
- `monospace: bool = false`
- `cursorVisible: bool = true`
- `editable: bool = true`
- `acceptsTab: bool = true`
- `indent: int = 0`

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

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`

###### Example

```nim
ListBox:
  for it in 0 ..< 10:
    ListBoxRow {.addRow.}:
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
- `selectionMode: SelectionMode`
- `selected: HashSet[int]`

###### Events

- select: `proc (rows: HashSet[int])`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `addRow`
- `add`

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

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`

###### Example

```nim
FlowBox:
  columns = 1 .. 5
  for it in 0 ..< 10:
    FlowBoxChild {.addChild.}:
      Label(text = $it)
```


## FlowBox

```nim
renderable FlowBox of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `homogeneous: bool`
- `rowSpacing: int`
- `columnSpacing: int`
- `columns: HSlice[int, int] = 1 .. 5`
- `selectionMode: SelectionMode`
- `children: seq[Widget]`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `addChild`
- `add`

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

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`

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

###### Adders

- All adders from [Window](#Window)
- `addButton`


## BuiltinDialog

```nim
renderable BuiltinDialog
```

###### Fields

- `title: string`
- `buttons: seq[DialogButton]`

###### Adders

- `addButton`


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
- `useAlpha: bool = false`


## MessageDialog

```nim
renderable MessageDialog of BuiltinDialog
```

###### Fields

- All fields from [BuiltinDialog](#BuiltinDialog)
- `message: string`


## AboutDialog

```nim
renderable AboutDialog of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `programName: string`
- `logo: string`
- `copyright: string`
- `version: string`
- `license: string`
- `credits: seq[(string, seq[string])]`

###### Example

```nim
AboutDialog:
  programName = "My Application"
  logo = "applications-graphics"
  version = "1.0.0"
  credits = @{"Code": @["Erika Mustermann", "Max Mustermann"],
              "Art": @["Max Mustermann"]}
```


