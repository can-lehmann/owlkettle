# Libadwaita Widgets


## AdwWindow

```nim
renderable AdwWindow of BaseWindow
```

A Window that does not have a title bar.

###### Fields

- All fields from [BaseWindow](#BaseWindow)
- `content: Widget`

###### Adders

- All adders from [BaseWindow](#BaseWindow)
- `add` Adds a child to the window surface. Each window surface may only have one child.


###### Example

```nim
AdwWindow:
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


## ButtonContent

```nim
renderable ButtonContent of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `label: string`
- `iconName: string`
- `useUnderline: bool` Defines whether you can use `_` on part of the label to make the button accessible via hotkey. If you prefix a character of the label text with `_` it will hide the `_` and activate the button if you press ALT + the key of the character. E.g. `_Button Text` will trigger the button when pressing `ALT + B`.
- `canShrink: bool` Defines whether the ButtonContent can be smaller than the size of its contents. Only available for adwaita version 1.3 or higher. Does nothing if set when compiled for lower adwaita versions.


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
- `suffixes: seq[AlignedChild[Widget]]`
- `text: string`

###### Events

- changed: `proc (text: string)`

###### Adders

- All adders from [PreferencesRow](#PreferencesRow)
- `addSuffix`
  - `hAlign = AlignFill`
  - `vAlign = AlignCenter`

###### Example

```nim
EntryRow:
  title = "Name"
  text = app.name
  proc changed(name: string) =
    app.name = name

```


## PasswordEntryRow

```nim
renderable PasswordEntryRow of EntryRow
```

An `EntryRow` that hides the user input

###### Fields

- All fields from [EntryRow](#EntryRow)

###### Example

```nim
PasswordEntryRow:
  title = "Password"
  text = app.password
  proc changed(password: string) =
    app.password = password

```


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


## AdwHeaderBar

```nim
renderable AdwHeaderBar of BaseWidget
```

Adwaita Headerbar that combines GTK Headerbar and WindowControls.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `packLeft: seq[Widget]`
- `packRight: seq[Widget]`
- `centeringPolicy: CenteringPolicy = CenteringPolicyLoose`
- `decorationLayout: Option[string] = none(string)`
- `showRightButtons: bool = true` Determines whether the buttons in `rightButtons` are shown. Does not affect Widgets in `packRight`.
- `showLeftButtons: bool = true` Determines whether the buttons in `leftButtons` are shown. Does not affect Widgets in `packLeft`.
- `titleWidget: Widget` A widget for the title. Replaces the title string, if there is one.
- `showBackButton: bool = true`
- `showTitle: bool = true` Determines whether to show or hide the title

###### Setters

- `windowControls: DecorationLayout`
- `windowControls: Option[DecorationLayout]`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `addLeft` Adds a widget to the left side of the HeaderBar.

- `addRight` Adds a widget to the right side of the HeaderBar.

- `addTitle`


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


## StatusPage

```nim
renderable StatusPage of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `iconName: string` The icon to render in the center of the StatusPage. Setting this overrides paintable. See the [tooling](https://can-lehmann.github.io/owlkettle/docs/recommended_tools.html) section for how to figure out what icon names are available.
- `paintable: Widget` The widget that implements GdkPaintable to render (e.g. IconPaintable, WidgetPaintable) in the center of the StatusPage. Setting this overrides iconName.
- `title: string`
- `description: string`
- `child: Widget`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`
- `addPaintable`


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


## SwitchRow

```nim
renderable SwitchRow of ActionRow
```

###### Fields

- All fields from [ActionRow](#ActionRow)
- `active: bool`

###### Events

- activated: `proc (active: bool)`


## Banner

```nim
renderable Banner of BaseWidget
```

A rectangular Box taking up the entire vailable width with an optional button.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `buttonLabel: string` Label of the optional banner button. Button will only be added to the banner if this Label has a value.
- `title: string`
- `useMarkup: bool = true` Determines whether using Markup in title is allowed or not.
- `revealed: bool = true` Determines whether the banner is shown.

###### Events

- clicked: `proc ()` Triggered by clicking the banner button


