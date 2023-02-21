import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **Adders**

Not all Widgets have adders. 
But all Widgets that want to be passed other Widgets from the outside to contain (like `Box` for example) need at least one.

An adder is a proc that enables the field that stores child-widgets and defines how to add widgets to that field.
It implicitly receives the parameters:
  1) `widget` of type `Widget` (the custom widget itself) and 
  2) `child` of type `Widget` (the child-widget to add).

"Enabling" a field of your custom widget means that it allows an "outside"-Widget to mutate it. In this case it allows adding `Widget`s to the child-widget-field. Without that, manipulating the child-widget-field field is not possible. 

Note: Any field you define under `viewable` will be present on `widget` in the form of the boolean field `has<FieldName>` and `val<FieldName>`. 
`has<FieldName>` controls whether the field is dis/enabled. `val<FieldName>` is the actual field value.
"""
nbSave
