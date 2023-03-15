import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **Adders**

Adders are used to add widgets that get passed from parent-widgets to the current widget.

Remember the previous example with CustomLabel. Back then we were unable to add Widgets to CustomLabel like this:
```nim
...
method view*(state: AppState): Widget =
  gui:
    Window:
      CustomLabel(text = "test"):
        Label(text = "Also render me!")
...
```

That is because `CustomLabel` doesn't have the ability to store or render child widgets, *yet*!
In order to add child widgets to our own widgets, we need to define an adder.

Not all Widgets have adders.
But all Widgets that want to be passed other Widgets from the outside to contain (like `Box` for example) need at least one.

An adder is a proc that enables the field that stores child-widgets and defines how to add widgets to that field.
It implicitly receives the parameters:
  1) `widget` of type `Widget` (the custom widget itself) and
  2) `child` of type `Widget` (the child-widget to add).

"Enabling" a field of your custom widget causes it to overwrite the current value in the widget state.
In this case it allows adding `Widget`s to the `child` field.
If the `child` field was not enabled, any children added to the `CustomBox` would be ignored.

Note: Any field you define under `viewable` will be present on `widget` in the form of the boolean field `has<FieldName>` and `val<FieldName>`.
`has<FieldName>` controls whether the field is dis/enabled. `val<FieldName>` is the actual field value.
"""
nbSave
