# Libadwaita Widgets


## WindowSurface

```nim
renderable WindowSurface of BaseWindow
```

A Window that does not have a title bar.
A WindowSurface is equivalent to an `Adw.Window`.

###### Fields

- All fields from [BaseWindow](#BaseWindow)
- `content: Widget`

###### Adders

- All adders from [BaseWindow](#BaseWindow)
- `add` Adds a child to the window surface. Each window surface may only have one child.


###### Example

```nim
WindowSurface:
  Box:
    orient = OrientX
    Box {.expand: false.}:
      sizeRequest = (250, -1)
      orient = OrientY
      HeaderBar {.expand: false.}:
        showTitleButtons = false
      Label(text = "Sidebar")
    Separator() {.expand: false.}
    Box:
      orient = OrientY
      HeaderBar() {.expand: false.}
      Label(text = "Main Content")
```


## WindowTitle

```nim
renderable WindowTitle of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `title: string`
- `subtitle: string`

###### Example

```nim
Window:
  HeaderBar {.addTitlebar.}:
    WindowTitle {.addTitle.}:
      title = "Title"
      subtitle = "Subtitle"
```


## Avatar

```nim
renderable Avatar of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `text: string`
- `size: int`
- `showInitials: bool`
- `iconName: string = "avatar-default-symbolic"`

###### Example

```nim
Avatar:
  text = "Erika Mustermann"
  size = 100
  showInitials = true
```


## Clamp

```nim
renderable Clamp of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `maximumSize: int` Maximum width of the content
- `child: Widget`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`

###### Example

```nim
Clamp:
  maximumSize = 600
  margin = 12
  PreferencesGroup:
    title = "Settings"
```


## PreferencesGroup

```nim
renderable PreferencesGroup of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `title: string`
- `description: string`
- `children: seq[Widget]`
- `suffix: Widget`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`
- `addSuffix`

###### Example

```nim
PreferencesGroup:
  title = "Settings"
  description = "Application Settings"
  ActionRow:
    title = "My Setting"
    subtitle = "Subtitle"
    Switch() {.addSuffix.}
```


## PreferencesRow

```nim
renderable PreferencesRow of ListBoxRow
```

###### Fields

- All fields from [ListBoxRow](#ListBoxRow)
- `title: string`


## ActionRow

```nim
renderable ActionRow of PreferencesRow
```

###### Fields

- All fields from [PreferencesRow](#PreferencesRow)
- `subtitle: string`
- `suffixes: seq[AlignedChild[Widget]]`

###### Adders

- All adders from [PreferencesRow](#PreferencesRow)
- `addSuffix`
  - `hAlign = AlignFill`
  - `vAlign = AlignCenter`

###### Example

```nim
ActionRow:
  title = "Color"
  subtitle = "Color of the object"
  ColorButton {.addSuffix.}:(discard )
```


## ExpanderRow

```nim
renderable ExpanderRow of PreferencesRow
```

###### Fields

- All fields from [PreferencesRow](#PreferencesRow)
- `subtitle: string`
- `actions: seq[AlignedChild[Widget]]`
- `rows: seq[AlignedChild[Widget]]`

###### Adders

- All adders from [PreferencesRow](#PreferencesRow)
- `addAction`
  - `hAlign = AlignFill`
  - `vAlign = AlignCenter`
- `addRow`
  - `hAlign = AlignFill`
  - `vAlign = AlignFill`

###### Example

```nim
ExpanderRow:
  title = "Expander Row"
  for it in 0 ..< 3:
    ActionRow {.addRow.}:
      title = "Nested Row " & $it
```


## ComboRow

```nim
renderable ComboRow of ActionRow
```

###### Fields

- All fields from [ActionRow](#ActionRow)
- `items: seq[string]`
- `selected: int`

###### Events

- select: `proc (item: int)`

###### Example

```nim
ComboRow:
  title = "Combo Row"
  items = @["Option 1", "Option 2", "Option 3"]
  selected = app.selected
  proc select(item: int) =
    app.selected = item

```


## EntryRow

```nim
renderable EntryRow of PreferencesRow
```

###### Fields

- All fields from [PreferencesRow](#PreferencesRow)
- `subtitle: string`
- `suffixes: seq[AlignedChild[Widget]]`
- `text: string`

###### Events

- changed: `proc (text: string)`

###### Adders

- All adders from [PreferencesRow](#PreferencesRow)
- `addSuffix`
  - `hAlign = AlignFill`
  - `vAlign = AlignCenter`


## Flap

```nim
renderable Flap
```

###### Fields

- `content: Widget`
- `separator: Widget`
- `flap: FlapChild[Widget]`
- `revealed: bool = false`
- `foldPolicy: FlapFoldPolicy = FlapFoldAuto`
- `foldThresholdPolicy: FoldThresholdPolicy = FoldThresholdNatural`
- `transitionType: FlapTransitionType = FlapTransitionOver`
- `modal: bool = true`
- `locked: bool = false`
- `swipeToClose: bool = true`
- `swipeToOpen: bool = true`

###### Setters

- `swipe: bool`

###### Events

- changed: `proc (revealed: bool)`
- fold: `proc (folded: bool)`

###### Adders

- `add`
- `addSeparator`
- `addFlap`
  - `width = -1`

###### Example

```nim
Flap:
  revealed = app.showFlap
  transitionType = FlapTransitionOver
  proc changed(revealed: bool) =
    app.showFlap = revealed

  Label(text = "Flap") {.addFlap, width: 200.}
  Separator() {.addSeparator.}
  Box:
    Label:
      text = "Content ".repeat(10)
      wrap = true
```


## SplitButton

```nim
renderable SplitButton of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `child: Widget`
- `popover: Widget`

###### Setters

- `text: string`
- `icon: string` Sets the icon of the SplitButton. See [recommended_tools.md](recommended_tools.md#icons) for a list of icons.

###### Events

- clicked: `proc ()`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `addChild`
- `add`


## AboutWindow

```nim
renderable AboutWindow
```

###### Fields

- `applicationName: string`
- `developerName: string`
- `version: string`
- `supportUrl: string`
- `issueUrl: string`
- `website: string`
- `copyright: string`
- `license: string`


