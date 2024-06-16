# Libadwaita Widgets


Some widgets are only available when linking against later libadwaita versions.
Set the target libadwaita version by passing `-d:adwminor=<Minor Version>`.



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
- `canShrink: bool` Defines whether the ButtonContent can be smaller than the size of its contents. Since: `AdwVersion >= (1, 4)`


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


## PreferencesPage

```nim
renderable PreferencesPage of BaseWidget
```

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `preferences: seq[Widget]`
- `iconName: string`
- `name: string`
- `title: string`
- `useUnderline: bool`
- `description: string` Since: `AdwVersion >= (1, 4)`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`


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
- `expanded: bool = false`
- `enableExpansion: bool = true`
- `showEnableSwitch: bool = false`
- `titleLines: int` Determines how many lines of text from the title are shown before it ellipsizes the text. Defaults to 0 which means it never elipsizes and instead adds new lines to show the full text. Since: `AdwVersion >= (1, 3)`
- `subtitleLines: int` Determines how many lines of text from the subtitle are shown before it ellipsizes the text. Defaults to 0 which means it never elipsizes and instead adds new lines to show the full text. Since: `AdwVersion >= (1, 3)`

###### Events

- expand: `proc (newExpandState: bool)` Triggered when row gets expanded

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

Since: `AdwVersion >= (1, 2)`

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

Since: `AdwVersion >= (1, 2)`

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


## OverlaySplitView

```nim
renderable OverlaySplitView of BaseWidget
```

Since: `AdwVersion >= (1, 4)`

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `content: Widget`
- `sidebar: Widget`
- `collapsed: bool = false`
- `enableHideGesture: bool = true`
- `enableShowGesture: bool = true`
- `maxSidebarWidth: float = 280.0`
- `minSidebarWidth: float = 180.0`
- `pinSidebar: bool = false`
- `showSidebar: bool = true`
- `sidebarPosition: PackType = PackStart`
- `widthFraction: float = 0.25`
- `widthUnit: LengthUnit = LengthScaleIndependent`

###### Events

- toggle: `proc (shown: bool)`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`
- `addSidebar`


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
- `showBackButton: bool = true` Since: `AdwVersion >= (1, 4)`
- `showTitle: bool = true` Determines whether to show or hide the title Since: `AdwVersion >= (1, 4)`

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


## ToolbarView

```nim
renderable ToolbarView of BaseWidget
```

Since: `AdwVersion >= (1, 4)`

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `content: Widget`
- `bottomBars: seq[Widget]`
- `topBars: seq[Widget]`
- `bottomBarStyle: ToolbarStyle = ToolbarFlat`
- `extendContentToBottomEdge: bool = false`
- `extendContentToTopEdge: bool = false`
- `revealBottomBars: bool = true`
- `revealTopBars: bool = true`
- `topBarStyle: ToolbarStyle = ToolbarFlat`

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`
- `addBottom`
- `addTop`


## AboutWindow

```nim
renderable AboutWindow
```

Since: `AdwVersion >= (1, 2)`

###### Fields

- `applicationName: string`
- `developerName: string`
- `version: string`
- `supportUrl: string`
- `issueUrl: string`
- `website: string`
- `copyright: string`
- `license: string` A custom license text. If this field is used instead of `licenseType`, `licenseType` has to be empty or `LicenseCustom`.
- `licenseType: LicenseType` A license from the `LicenseType` enum.
- `legalSections: seq[LegalSection]` Adds extra sections to the "Legal" page. You can use these sections for dependency package attributions etc.
- `applicationIcon: string`
- `releaseNotes: string`
- `comments: string`
- `debugInfo: string` Adds a "Troubleshooting" section. Use this field to provide instructions on how to acquire logs or other info you want users of your app to know about when reporting bugs or debugging.
- `developers: seq[string]`
- `designers: seq[string]`
- `artists: seq[string]`
- `documenters: seq[string]`
- `credits: seq[tuple[title: string, people: seq[string]]]` Additional credit sections with customizable titles
- `acknowledgements: seq[tuple[title: string, people: seq[string]]]` Acknowledgment sections with customizable titles
- `links: seq[tuple[title: string, url: string]]` Additional links placed in the details section

###### Example

```nim
AboutWindow:
  applicationName = "My Application"
  developerName = "Erika Mustermann"
  version = "1.0.0"
  applicationIcon = "application-x-executable"
  supportUrl = "https://github.com/can-lehmann/owlkettle/discussions"
  issueUrl = "https://github.com/can-lehmann/owlkettle/issues"
  website = "https://can-lehmann.github.io/owlkettle/README"
  links = @{"Tutorial": "https://can-lehmann.github.io/owlkettle/docs/tutorial.html", "Installation": "https://can-lehmann.github.io/owlkettle/docs/installation.html"}
  comments = """My Application demonstrates the use of the Adwaita AboutWindow. Comments will be shown on the Details page, above links. <i>Unlike</i> GtkAboutDialog comments, this string can be long and detailed. It can also contain <a href='https://docs.gtk.org/Pango/pango_markup.html'>links</a> and <b>Pango markup</b>."""
  copyright = "Erika Mustermann"
  licenseType = LicenseMIT_X11
```


## ToastOverlay

```nim
renderable ToastOverlay of BaseWidget
```

Displays messages (toasts) to the user.

Use `newToast` to create a `Toast`.
`Toast` has the following properties that can be assigned to:

- title: The text to display in the toast. Hidden if customTitle is set.
- customTitle: A Widget to display in the toast. Causes title to be hidden if it is set. Only available when compiling for Adwaita version 1.2 or higher.
- buttonLabel: If set, the Toast will contain a button with this string as its text. If not set, the Toast will not contain a button.
- priority: Defines the behaviour of the toast. `ToastPriorityNormal` will put the toast at the end of the queue of toasts to display. `ToastPriorityHigh` will display the toast **immediately**, ignoring any others.
- timeout: The time in seconds after which the toast is dismissed automatically. Disables automatic dismissal if set to 0. Defaults to 5. 
- dismissalHandler: An event handler which is called when the toast is dismissed
- clickedHandler: An event handler which is called when the user clicks on the button that appears if `buttonLabel` is defined. Only available when compiling for Adwaita version 1.2 or higher.
- useMarkup: Whether to interpret the title as Pango Markup. Only available when compiling for Adwaita version 1.4 or higher.

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `child: Widget`
- `toastQueue: ToastQueue` The Toasts to display. Toasts of priority `ToastPriorityNormal` are displayed in First-In-First-Out order, after toasts of priority `ToastPriorityHigh` which are displayed in Last-In-First-Out order.

###### Adders

- All adders from [BaseWidget](#BaseWidget)
- `add`


## SwitchRow

```nim
renderable SwitchRow of ActionRow
```

Since: `AdwVersion >= (1, 4)`

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

Since: `AdwVersion >= (1, 3)`

###### Fields

- All fields from [BaseWidget](#BaseWidget)
- `buttonLabel: string` Label of the optional banner button. Button will only be added to the banner if this Label has a value.
- `title: string`
- `useMarkup: bool = true` Determines whether using Markup in title is allowed or not.
- `revealed: bool = true` Determines whether the banner is shown.

###### Events

- clicked: `proc ()` Triggered by clicking the banner button


