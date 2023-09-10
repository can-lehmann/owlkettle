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


## Label

```nim
renderable Label of BaseWidget
```

The default widget to display text.
Supports rendering [Pango Markup](https://docs.gtk.org/Pango/pango_markup.html#pango-markup) 
if `useMarkup` is enabled.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `text: string` The text of the Label to render
- `xAlign: float = 0.5`
- `yAlign: float = 0.5`
- `ellipsize: EllipsizeMode` Determines whether to ellipsise the text in case space is insufficient to render all of it. May be one of `EllipsizeNone`, `EllipsizeStart`, `EllipsizeMiddle` or `EllipsizeEnd`
- `wrap: bool = false` Enables/Disable wrapping of text.
- `useMarkup: bool = false` Determines whether to interpret the given text as Pango Markup or not.

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
- `contentFit: ContentFit = ContentContain` Requires GTK 4.8 to fully work, compile with `-d:gtk48` to enable


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
- `left: seq[Widget]`
- `right: seq[Widget]`

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

###### Events

- changed: `proc ()`


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
- `selected: HashSet[int]` Indices of the currently selected items.

###### Events

- select: `proc (rows: HashSet[int])`

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
- `selected: int` Index of the currently selected item.
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
- `rowSpacing: int` Spacing between the rows of the grid.
- `columnSpacing: int` Spacing between the columns of the grid.
- `rowHomogeneous: bool`
- `columnHomogeneous: bool`

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


