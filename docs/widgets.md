# Widgets
## BaseWidget

```nim
renderable BaseWidget
```

The base widget of all widgets. Supports redrawing the entire Application
by calling `<WidgetName>State.app.redraw()`

###### Fields

- `sensitive: bool = true` If the widget is interactive
- `sizeRequest: tuple[x, y: int] = (-1, -1)` Requested widget size. A value of -1 means that the natural size of the widget will be used.
- `tooltip: string = ""` The widget's tooltip is shown on hover

###### Setters

- `margin: int`
- `margin: Margin`
- `style: StyleClass`
- `style: varargs[StyleClass]`
- `style: HashSet[StyleClass]`


## BaseWindow

```nim
renderable BaseWindow of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `defaultSize: tuple[width, height: int] = (800, 600)` Initial size of the window
- `fullscreened: bool`
- `iconName: string`

###### Events

- close: `proc ()` Called when the window is closed


## Window

```nim
renderable Window of BaseWindow
```

###### Fields

- All fields from [BaseWindow](#BaseWindow)
- `title: string`
- `titlebar: Widget` Custom widget set as the titlebar of the window
- `child: Widget`

###### Adders

- All adders from [BaseWindow](#BaseWindow)
- `add` Adds a child to the window. Each window may only have one child.

- `addTitlebar` Sets a custom titlebar for the window


###### Example

```nim
Window:
  Label(text = "Hello, world")
```


## Box

```nim
renderable Box of BaseWidget
```

A Box arranges its child widgets along one dimension.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `orient: Orient` Orientation of the Box and its containing elements. May be one of OrientX (to orient horizontally) or OrientY (to orient vertically)
- `spacing: int` Spacing between the children of the Box
- `children: seq[BoxChild[Widget]]`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add` Adds a child to the Box.
When expand is true, the child grows to fill up the remaining space in the Box.
The `hAlign` and `vAlign` properties allow you to set the horizontal and vertical 
alignment of the child within its allocated area. They may be one of `AlignFill`, 
`AlignStart`, `AlignEnd` or `AlignCenter`.

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
    style = [BoxLinked]
    for it in 0 ..< 5:
      Button {.expand: false.}:
        text = "Button " & $it
        proc clicked() =
          echo it

```


## CenterBox

```nim
renderable CenterBox of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `startWidget: Widget`
- `centerWidget: Widget`
- `endWidget: Widget`
- `baselinePosition: BaselinePosition = BaselineCenter`
- `shrinkCenterLast: bool = false` Since: `GtkMinor >= 12`
- `orient: Orient = OrientX`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `addStart`
- `addEnd`
- `add`


## Overlay

```nim
renderable Overlay of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `child: Widget`
- `overlays: seq[AlignedChild[Widget]]`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`
- `addOverlay`
  - `hAlign = AlignFill`
  - `vAlign = AlignFill`


## EmojiChooser

```nim
renderable EmojiChooser of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)

###### Events

- emojiPicked: `proc (emoji: string)`


## Label

```nim
renderable Label of BaseWidget
```

The default widget to display text.
Supports rendering [Pango Markup](https://docs.gtk.org/Pango/pango_markup.html#pango-markup) 
if `useMarkup` is enabled.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `text: string` Text displayed by the label
- `xAlign: float = 0.5` Horizontal alignment of the text within the widget
- `yAlign: float = 0.5` Vertical alignment of the text within the widget
- `ellipsize: EllipsizeMode` Determines whether to ellipsise the text in case space is insufficient to render all of it. May be one of `EllipsizeNone`, `EllipsizeStart`, `EllipsizeMiddle` or `EllipsizeEnd`
- `wrap: bool = false` Enables/Disable wrapping of text
- `useMarkup: bool = false` Determines whether to interpret the given text as Pango Markup

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


## EditableLabel

```nim
renderable EditableLabel of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `text: string = ""`
- `editing: bool = false` Determines whether the edit view (editing = false) or the "read" view (editing = true) is being shown
- `enableUndo: bool = true`
- `alignment: float = 0.0`

###### Events

- changed: `proc (text: string)` Fired every time `text` changes.
- editStateChanged: `proc (newEditState: bool)` Fired every time `editing` changes.


## Icon

```nim
renderable Icon of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `name: string` See [recommended_tools.md](recommended_tools.md#icons) for a list of icons.
- `pixelSize: int = -1` Determines the size of the icon

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


## Picture

```nim
renderable Picture of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `pixbuf: Pixbuf`
- `contentFit: ContentFit = ContentContain` Requires GTK 4.8 or higher to fully work, compile with `-d:gtkminor=8` to enable


## Button

```nim
renderable Button of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `child: Widget`
- `shortcut: string` Keyboard shortcut

###### Setters

- `text: string`
- `icon: string` Sets the icon of the Button (see [recommended_tools.md](recommended_tools.md#icons) for a list of icons)

###### Events

- clicked: `proc ()`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`

###### Example

```nim
Button:
  icon = "list-add-symbolic"
  style = [ButtonSuggested]
  proc clicked() =
    echo "clicked"

```

```nim
Button:
  text = "Delete"
  style = [ButtonDestructive]
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
- `title: BoxChild[Widget]`
- `showTitleButtons: bool = true`
- `decorationLayout: Option[string] = none(string)`
- `left: seq[Widget]`
- `right: seq[Widget]`

###### Setters

- `windowControls: DecorationLayout`
- `windowControls: Option[DecorationLayout]`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `addTitle` Adds a custom title widget to the HeaderBar.
When expand is true, it grows to fill up the remaining space in the headerbar.
The `hAlign` and `vAlign` properties allow you to set the horizontal and vertical 
alignment of the child within its allocated area. They may be one of `AlignFill`, 
`AlignStart`, `AlignEnd` or `AlignCenter`.

  - `expand = false`
  - `hAlign = AlignFill`
  - `vAlign = AlignFill`
- `addLeft` Adds a widget to the left side of the HeaderBar.

- `addRight` Adds a widget to the right side of the HeaderBar.


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
- `propagateNaturalWidth: bool = false`
- `propagateNaturalHeight: bool = false`

###### Events

- edgeOvershot: `proc (edge: Edge)` Called when the user attempts to scroll past limits of the scrollbar
- edgeReached: `proc (edge: Edge)` Called when the user reaches the limits of the scrollbar

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
- `placeholder: string` Shown when the Entry is empty.
- `width: int = -1`
- `maxWidth: int = -1`
- `xAlign: float = 0.0`
- `visibility: bool = true`
- `invisibleChar: Rune = '*'.Rune`

###### Events

- changed: `proc (text: string)` Called when the text in the Entry changed
- activate: `proc ()` Called when the user presses enter/return

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


## Spinner

```nim
renderable Spinner of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `spinning: bool`


## SpinButton

```nim
renderable SpinButton of BaseWidget
```

Entry for entering numeric values

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `digits: uint = 1` Number of digits
- `climbRate: float = 0.1`
- `wrap: bool` When the maximum (minimum) value is reached, the SpinButton will wrap around to the minimum (maximum) value.
- `min: float = 0.0` Lower bound
- `max: float = 100.0` Upper bound
- `stepIncrement: float = 0.1`
- `pageIncrement: float = 1`
- `pageSize: float = 0`
- `value: float`

###### Events

- valueChanged: `proc (value: float)`

###### Example

```nim
SpinButton:
  value = app.value
  proc valueChanged(value: float) =
    app.value = value

```


## Paned

```nim
renderable Paned of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `orient: Orient` Orientation of the panes
- `initialPosition: int` Initial position of the separator in pixels
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

Allows you to render 2d scenes using cairo.
The `owlkettle/cairo` module provides bindings for cairo.

###### Fields

- All fields from [CustomWidget](#CustomWidget)

###### Events

- draw: `proc (ctx: CairoContext; size: (int, int)): bool` Called when the widget is rendered. Redraws the application if the callback returns true.

###### Example

```nim
DrawingArea:
  ## You need to import the owlkettle/cairo module in order to use CairoContext
  proc draw(ctx: CairoContext; size: tuple[width, height: int]): bool =
    ctx.rectangle(100, 100, 300, 200)
    ctx.source = (0.0, 0.0, 0.0)
    ctx.stroke()

```


## GlArea

```nim
renderable GlArea of CustomWidget
```

Allows you to render 3d scenes using OpenGL.

###### Fields

- All fields from [CustomWidget](#CustomWidget)
- `useEs: bool = false`
- `requiredVersion: tuple[major, minor: int] = (4, 3)`
- `hasDepthBuffer: bool = true`
- `hasStencilBuffer: bool = false`

###### Events

- setup: `proc (size: (int, int)): bool` Called after the OpenGL Context is initialized. Redraws the application if the callback returns true.
- render: `proc (size: (int, int)): bool` Called when the widget is rendered. Your rendering code should be executed here. Redraws the application if the callback returns true.


## ColorButton

```nim
renderable ColorButton of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `color: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0)` Red, Geen, Blue, Alpha as floating point numbers in the range [0.0, 1.0]
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

A clickable link.

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


## RadioGroup

```nim
renderable RadioGroup of BaseWidget
```

A list of options selectable using radio buttons.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `spacing: int = 3` Spacing between the rows
- `rowSpacing: int = 6` Spacing between the radio button and
- `orient: Orient = OrientY` Orientation of the list
- `children: seq[Widget]`
- `selected: int` Currently selected index, may be smaller or larger than the number of children to represent no option being selected

###### Events

- select: `proc (index: int)`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`

###### Example

```nim
RadioGroup:
  selected = app.selected
  proc select(index: int) =
    app.selected = index

  Label(text = "Option 0", xAlign = 0)
  Label(text = "Option 1", xAlign = 0)
  Label(text = "Option 2", xAlign = 0)
```


## BasePopover

```nim
renderable BasePopover of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `hasArrow: bool = true`
- `offset: tuple[x, y: int] = (0, 0)`
- `position: PopoverPosition = PopoverBottom`


## Popover

```nim
renderable Popover of BasePopover
```

###### Fields

- All fields from [BasePopover](#BasePopover)
- `child: Widget`

###### Adders

- All adders from [BasePopover](#BasePopover)
- `add`


## PopoverMenu

```nim
renderable PopoverMenu of BasePopover
```

A popover with multiple pages.
It is usually used to create a menu with nested submenus.

###### Fields

- All fields from [BasePopover](#BasePopover)
- `pages: Table[string, Widget]`

###### Adders

- All adders from [BasePopover](#BasePopover)
- `add` Adds a page to the popover menu.

  - `name = "main"`


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
- `icon: string` Sets the icon of the MenuButton. Typically `open-menu` is used. See [recommended_tools.md](recommended_tools.md#icons) for a list of icons.

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `addChild`
- `add`

###### Example

```nim
MenuButton {.addRight.}:
  icon = "open-menu"
  PopoverMenu:
    Box:
      Label(text = "My Menu")
```


## ModelButton

```nim
renderable ModelButton of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `text: string`
- `icon: string` The icon of the ModelButton (see [recommended_tools.md](recommended_tools.md#icons) for a list of icons)
- `shortcut: string`
- `menuName: string`

###### Events

- clicked: `proc ()`

###### Example

```nim
PopoverMenu:
  Box:
    orient = OrientY
    for it in 0 ..< 10:
      ModelButton:
        text = "Menu Entry " & $it
        proc clicked() =
          echo "Clicked " & $it

```


## SearchEntry

```nim
renderable SearchEntry of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `text: string`
- `searchDelay: uint = 100` Determines the minimum time after a `searchChanged` event occurred before the next can be emitted. Since: `GtkMinor >= 8`
- `placeholderText: string = "Search"` Since: `GtkMinor >= 10`

###### Events

- activate: `proc ()` Triggered when the user "activated" the search e.g. by hitting "enter" key while SearchEntry is in focus.
- nextMatch: `proc ()` Triggered when the user hits the "next entry" keybinding while the search entry is in focus, which is Ctrl-g by default.
- previousMatch: `proc ()` Triggered when the user hits the "previous entry" keybinding while the search entry is in focus, which is Ctrl-Shift-g by default.
- changed: `proc (searchString: string)` Triggered when the user types in the SearchEntry.
- stopSearch: `proc ()` Triggered when the user "stops" a search, e.g. by hitting the "Esc" key while SearchEntry is in focus.


## Separator

```nim
renderable Separator of BaseWidget
```

A separator line.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `orient: Orient`


## TextView

```nim
renderable TextView of BaseWidget
```

A text editor with support for formatted text.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `buffer: TextBuffer` The buffer containing the displayed text.
- `monospace: bool = false`
- `cursorVisible: bool = true`
- `editable: bool = true`
- `acceptsTab: bool = true`
- `indent: int = 0`
- `wrapMode: WrapMode = WrapNone`
- `textMargin: Margin`


## ListBoxRow

```nim
renderable ListBoxRow of BaseWidget
```

A row in a `ListBox`.

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
- `selected: HashSet[int]` Indices of the currently selected rows

###### Events

- select: `proc (rows: HashSet[int])` Called when the selection changed. `rows` contains the indices of the newly selected rows.

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `addRow` Adds a row to the list. The added child widget must be a `ListBoxRow`.

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


## DropDown

```nim
renderable DropDown of BaseWidget
```

A drop down that allows the user to select an item from a list of items.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `items: seq[string]`
- `selected: int` Index of the currently selected item
- `enableSearch: bool`
- `showArrow: bool = true`

###### Events

- select: `proc (item: int)`

###### Example

```nim
DropDown:
  items = @["Option 1", "Option 2", "Option 3"]
  selected = app.selectedItem
  proc select(itemIndex: int) =
    app.selectedItem = itemIndex

```


## Grid

```nim
renderable Grid of BaseWidget
```

A grid layout.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `children: seq[GridChild[Widget]]`
- `rowSpacing: int` Spacing between the rows of the grid
- `columnSpacing: int` Spacing between the columns of the grid
- `rowHomogeneous: bool` Whether all rows should have the same width
- `columnHomogeneous: bool` Whether all columns should have the same height

###### Setters

- `spacing: int` Sets the spacing between the rows and columns of the grid.
- `homogeneous: bool`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add` Adds a child at the given location to the grid.
The location of the child within the grid can be set using the `x`, `y`, `width` and `height` properties.
The `hAlign` and `vAlign` properties allow you to set the horizontal and vertical 
alignment of the child within its allocated area. They may be one of `AlignFill`,
`AlignStart`, `AlignEnd` or `AlignCenter`.

  - `x = 0`
  - `y = 0`
  - `width = 1`
  - `height = 1`
  - `hExpand = false`
  - `vExpand = false`
  - `hAlign = AlignFill`
  - `vAlign = AlignFill`

###### Example

```nim
Grid:
  spacing = 6
  margin = 12
  Button {.x: 1, y: 1, hExpand: true, vExpand: true.}:
    text = "A"
  Button {.x: 2, y: 1.}:
    text = "B"
  Button {.x: 1, y: 2, width: 2, hAlign: AlignCenter.}:
    text = "C"
```


## Fixed

```nim
renderable Fixed of BaseWidget
```

A layout where children are placed at fixed positions.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `children: seq[FixedChild[Widget]]`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add` Adds a child at the given position

  - `x = 0.0`
  - `y = 0.0`

###### Example

```nim
Fixed:
  Label(text = "Fixed Layout") {.x: 200, y: 100.}
```


## ContextMenu

```nim
renderable ContextMenu
```

Adds a context menu to a widget.
Context menus are shown when the user right clicks the widget.

###### Fields

- `child: Widget`
- `menu: Widget`
- `controller: GtkEventController = GtkEventController(nil)`

###### Adders

- `add`
- `addMenu`

###### Example

```nim
ContextMenu:
  Label:
    text = "Right click here"
  PopoverMenu {.addMenu.}:
    hasArrow = false
    Box(orient = OrientY):
      for it in 0 ..< 3:
        ModelButton:
          text = "Menu Entry " & $it
```


## LevelBar

```nim
renderable LevelBar of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `value: float = 0.0`
- `min: float = 0.0`
- `max: float = 1.0`
- `inverted: bool = false`
- `mode: LevelBarMode = LevelBarContinuous`
- `orient: Orient = OrientX`

###### Example

```nim
LevelBar:
  value = 0.2
  min = 0
  max = 1
```

```nim
LevelBar:
  value = 2
  max = 10
  orient = OrientY
  mode = LevelBarDiscrete
```


## Calendar

```nim
renderable Calendar of BaseWidget
```

Displays a calendar

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `date: DateTime`
- `markedDays: seq[int] = @[]`
- `showDayNames: bool = true`
- `showHeading: bool = true`
- `showWeekNumbers: bool = true`

###### Events

- daySelected: `proc (date: DateTime)`
- nextMonth: `proc (date: DateTime)`
- prevMonth: `proc (date: DateTime)`
- nextYear: `proc (date: DateTime)`
- prevYear: `proc (date: DateTime)`

###### Example

```nim
Calendar:
  date = app.date
  proc select(date: DateTime) =
    ## Shortcut for handling all calendar events (daySelected,
    ## nextMonth, prevMonth, nextYear, prevYear)
    app.date = date

```


## DialogButton

```nim
renderable DialogButton
```

A button which closes the currently open dialog and sends a response to the caller.
This widget can only be used with the `addButton` adder of `Dialog` or `BuiltinDialog`.

###### Fields

- `text: string`
- `response: DialogResponse`

###### Setters

- `res: DialogResponseKind`
- `style: varargs[StyleClass]` Applies CSS classes to the button. There are some pre-defined classes available: `ButtonSuggested`, `ButtonDestructive`, `ButtonFlat`, `ButtonPill` or `ButtonCircular`. You can also use custom CSS classes using `StyleClass("my-class")`. Consult the [GTK4 documentation](https://developer.gnome.org/hig/patterns/controls/buttons.html?highlight=button#button-styles) for guidance on what to use.
- `style: HashSet[StyleClass]` Applies CSS classes to the button.
- `style: StyleClass` Applies CSS classes to the button.


## Dialog

```nim
renderable Dialog of Window
```

A window which can contain `DialogButton` widgets in its header bar.

###### Fields

- All fields from [Window](#Window)
- `buttons: seq[DialogButton]`

###### Adders

- All adders from [Window](#Window)
- `addButton`

###### Example

```nim
Dialog:
  title = "My Dialog"
  defaultSize = (300, 200)
  DialogButton {.addButton.}:
    text = "Ok"
    res = DialogAccept
  DialogButton {.addButton.}:
    text = "Cancel"
    res = DialogCancel
  Label(text = "Hello, world!")
```


## BuiltinDialog

```nim
renderable BuiltinDialog of BaseWidget
```

Base widget for builtin dialogs.
If you want to create a custom dialog, you should use `Window` or `Dialog` instead.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `title: string`
- `buttons: seq[DialogButton]`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `addButton`


## FileChooserDialog

```nim
renderable FileChooserDialog of BuiltinDialog
```

A dialog for opening/saving files or folders.

###### Fields

- All fields from [BuiltinDialog](#BuiltinDialog)
- `action: FileChooserAction`
- `selectMultiple: bool = false`
- `initialPath: string` Path of the initially shown folder
- `filenames: seq[string]` The selected file paths

###### Example

```nim
FileChooserDialog:
  title = "Open a File"
  action = FileChooserOpen
  selectMultiple = true
  DialogButton {.addButton.}:
    text = "Cancel"
    res = DialogCancel
  DialogButton {.addButton.}:
    text = "Open"
    res = DialogAccept
    style = [ButtonSuggested]
```


## ColorChooserDialog

```nim
renderable ColorChooserDialog of BuiltinDialog
```

A dialog for choosing a color.

###### Fields

- All fields from [BuiltinDialog](#BuiltinDialog)
- `color: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0)`
- `useAlpha: bool = false`

###### Example

```nim
ColorChooserDialog:
  color = (1.0, 0.0, 0.0, 1.0)
  useAlpha = true
```


## MessageDialog

```nim
renderable MessageDialog of BuiltinDialog
```

A dialog for showing a message to the user.

###### Fields

- All fields from [BuiltinDialog](#BuiltinDialog)
- `message: string`

###### Example

```nim
MessageDialog:
  message = "Hello, world!"
  DialogButton {.addButton.}:
    text = "Ok"
    res = DialogAccept
```


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


## Scale

```nim
renderable Scale of BaseWidget
```

A slider for choosing a numeric value within a range.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `min: float = 0` Lower end of the range displayed by the scale
- `max: float = 100` Upper end of the range displayed by the scale
- `value: float = 0` The value the Scale widget displays. Remember to update it via your `valueChanged` proc to reflect the new value on the Scale widget.
- `marks: seq[ScaleMark] = @[]` Adds marks to the Scale at points where `ScaleMark.value` would be placed. If `ScaleMark.label` is provided, it will be rendered next to the mark. `ScaleMark.position` determines the mark's position (and its label) relative to the scale. Note that ScaleLeft and ScaleRight are only sensible when the Scale is vertically oriented (`orient` = `OrientY`), while ScaleTop and ScaleBottom are only sensible when it is horizontally oriented (`orient` = `OrientX`)
- `inverted: bool = false` Determines whether the min and max value of the Scale are ordered (low value) left => right (high value) in the case of `inverted = false` or (high value) left <= right (low value) in the case of `inverted = true`.
- `showValue: bool = true` Determines whether to display the numeric value as a label on the widget (`showValue = true`) or not (`showValue = false`)
- `stepSize: float = 5` Determines the value increment/decrement when the widget is in focus and the user presses arrow keys.
- `pageSize: float = 10` Determines the value increment/decrement when the widget is in focus and the user presses page keys. Typically larger than stepSize.
- `orient: Orient = OrientX` The orientation of the widget. Orients the widget either horizontally (`orient = OrientX`) or vertically (`orient = OrientY`)
- `showFillLevel: bool = true` Determines whether to color the Scale from the "origin" to the place where the slider on the Scale sits. The Scale is filled left => right/top => bottom if `inverted = false` and left <= right/top <= bottom if `inverted = true`
- `precision: int64 = 1` Number of decimal places to display for the value. `precision = 1` enables values like 1.2, while `precision = 2` enables values like 1.23 and so on.
- `valuePosition: ScalePosition` Specifies where the label of the Scale widget's value should be placed. This setting has no effect if `showValue = false`.

###### Events

- valueChanged: `proc (newValue: float)` Emitted when the range value changes from an interaction triggered by the user.

###### Example

```nim
Scale:
  value = app.value
  showFillLevel = false
  min = 0
  max = 1
  marks = @[ScaleMark(some("Just a mark"), ScaleLeft, 0.5)]
  inverted = true
  showValue = false
  proc valueChanged(newValue: float) =
    echo "New value is ", newValue
    app.value = newValue

```


## Video

```nim
renderable Video of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `autoplay: bool = false`
- `loop: bool = false`
- `mediaStream: MediaStream`

###### Setters

- `fileName: string`
- `file: GFile`


## MediaControls

```nim
renderable MediaControls of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `mediaStream: MediaStream`


## Expander

```nim
renderable Expander of BaseWidget
```

Container that shows or hides its child depending on whether it is expanded/collapsed.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `label: string` The clickable header of the Expander. Overwritten by `labelWidget` if it is provided via adder.
- `labelWidget: Widget` The clickable header of the Expander. Overwrites `label` if provided.
- `expanded: bool = false` Determines whether the body of the Expander is shown
- `child: Widget` Determines the body of the Expander
- `resizeToplevel: bool = false`
- `useMarkup: bool = false`
- `useUnderline: bool = false`

###### Events

- activate: `proc (activated: bool)` Triggered whenever Expander is expanded or collapsed

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`
- `addLabel`

###### Example

```nim
Expander:
  label = "Expander"
  Label:
    text = "Content"
```

```nim
Expander:
  label = "Expander"
  expanded = app.expanded
  proc activate(activated: bool) =
    app.expanded = activated

  Label:
    text = "Content"
```

```nim
Expander:
  Label {.addLabel.}:
    text = "Widget Label"
  Label:
    text = "Content"
```


## PasswordEntry

```nim
renderable PasswordEntry of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `text: string`
- `activatesDefault: bool = true`
- `placeholderText: string = "Password"`
- `showPeekIcon: bool = true`

###### Events

- activate: `proc ()` Triggered when the user "activated" the entry e.g. by hitting "enter" key while PasswordEntry is in focus.
- changed: `proc (password: string)` Triggered when the user types in the PasswordEntry.


## ProgressBar

```nim
renderable ProgressBar of BaseWidget
```

A progress bar widget to show progress being made on a long-lasting task

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `ellipsize: EllipsizeMode = EllipsizeEnd` Determines how the `text` gets ellipsized if `showText = true` and `text` overflows.
- `fraction: float = 0.0` Determines how much the ProgressBar is filled. Must be between 0.0 and 1.0.
- `inverted: bool = false`
- `pulseStep: float = 0.1`
- `showText: bool = false`
- `text: string = ""`


## ActionBar

```nim
renderable ActionBar of BaseWidget
```

A Bar for actions to execute in a given context. Can be hidden with intro- and outro-animations.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `centerWidget: Widget`
- `packStart: seq[Widget]` Widgets shown on the start of the ActionBar
- `packEnd: seq[Widget]` Widgets shown on the end of the ActionBar
- `revealed: bool`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`
- `addStart`
- `addEnd`


## ListView

```nim
renderable ListView of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `size: int` Number of items
- `selectionMode: SelectionMode`
- `selected: HashSet[int]` Indices of the currently selected items.
- `showSeparators: bool = false`
- `singleClickActivate: bool = false`
- `enableRubberband: bool = false`

###### Events

- viewItem: `proc (index: int): Widget`
- select: `proc (rows: HashSet[int])`
- activate: `proc (index: int)`


## ColumnView

```nim
renderable ColumnView of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `rows: int` Number of rows
- `columns: seq[ColumnViewColumn]`
- `selectionMode: SelectionMode`
- `selected: HashSet[int]` Indices of the currently selected rows
- `showRowSeparators: bool = false`
- `showColumnSeparators: bool = false`
- `singleClickActivate: bool = false`
- `enableRubberband: bool = false`
- `reorderable: bool = false`

###### Events

- viewItem: `proc (row, column: int): Widget`
- select: `proc (rows: HashSet[int])`
- activate: `proc (index: int)`


