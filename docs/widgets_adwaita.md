# Libadwaita Widgets


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
- `maximumSize: int`
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
- `suffixes: seq[Suffix[Widget]]`

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


