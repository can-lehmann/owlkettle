import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **Adders with properties**

Let's make a custom widget that stores Widgets in a `Table[string, Widget]` and displays the widget next to the key it was stored with.

First we need to add the parameter for the key to our adder.

```nim
...
viewable CustomBox:
  myChildren: Table[string, Widget] # The child-widget field

  adder add {.key: none(string).}:
...
```

Additional parameters passed to adders are called "properties".
Properties **must** have a default value, their type is inferred based on that value.
If you do not want to provide a default value, you can use an `Option` type.

Let's assert that anyone using `CustomBox` also passes a key and doesn't accidentally reuse a key that has already been used to store a Widget that in the table:
"""

nbCode:
  import owlkettle
  import std/[tables, options, strformat]

  viewable CustomBox:
    myChildren: Table[string, Widget] # The child-widget field

    adder add {.key: none(string).}:
      assert key.isSome(), "CustomBox requires you to tell it under which key to store child widgets. Add a 'key' property"

      let keyIsFree = not widget.valMyChildren.hasKey(key.get())
      assert keyIsFree, fmt"A widget with the key '{key.get()} has already been added to CustomBox. Use a different name"

      widget.hasMyChildren = true
      widget.valMyChildren[key.get()] = child

  method view(state: CustomBoxState): Widget =
    gui:
      Box(orient = OrientY):
        for key in state.myChildren.keys:
          Box():
            Label(text = key)
            insert state.myChildren[key]

  ## The App
  viewable App:
    discard

  method view(state: AppState): Widget =
    gui:
      Window:
        CustomBox():
          Label(text = "I was passed in from the outside") {.key: some("key1").}
          Label(text = "Me too!") {.key: some("key2").}
          Label(text = "Me three!") {.key: some("key3").}
          # Label(text = "Me four!") {.key: some("key3").} # Will cause a runtime error because key3 is already in use
  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText:"""
If we were to remove the "#" in front of the last Label, we would be facing a runtime error produced by the application, since "key3" was already used.

Note: When using optionals, due to the macros involved, you can only use the `some(<value>)`/`none(<typedesc>)` syntax.
"""

nbSave
