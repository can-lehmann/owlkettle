import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **Single Adder**

An adder is a proc that defines how to add child widgets to a widget.
It also enables the field that stores child-widgets.
It implicitly receives the parameters `widget` of type `Widget` (the custom widget itself) and `child` of type `Widget` (the child-widget to add).

To create a widget that can contain other widgets, you must:
  1) Add a field to your widget that can store child-Widgets (e.g. one with type `seq[Widget]`)
  2) Define an adder that enables the child-widget-field and adds a given widget to it
  3) Define how to display the child-widgets in your `view` method

Let's look at an example for a `CustomBox`:
"""

nbCode:
  import owlkettle

  ## The custom widget
  viewable CustomBox:
    myChildren: seq[Widget] # The child-widget field

    adder add: # Define the default adder `add`
      widget.hasMyChildren = true # Enables mutating `myChildren`
      widget.valMyChildren.add(child) # Adds the child-Widget to `myChildren`

  method view(state: CustomBoxState): Widget =
    gui:
      Box(orient = OrientY):
        for child in state.myChildren:
          insert child # Inserts child-widget into this CustomBox-widget

  ## The App
  viewable App:
    discard

  method view(state: AppState): Widget =
    gui:
      Window:
        CustomBox():
          Label(text = "I was passed in from the outside")
          Label(text = "Me too!")
          Label(text = "Me three!")

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText: """
We define `myChildren` and "enable" it in the `add` adder via `widget.hasMyChildren = true`.
Then we define how to add the `child` Widget to it, which in this case is simply us adding it to the seq.

## Adding multiple widgets

To pass multiple Widgets to another Widget, iterate over the widgets and insert them.
This is the preferred way of doing this.
"""

nbCode:
  import owlkettle

  ## The custom widget
  viewable CustomBox2:
    myChildren: seq[Widget] # The child-widget field

    adder add: # Define the default adder `add`
      widget.hasMyChildren = true # Enables mutating `myChildren`
      widget.valMyChildren.add(child) # Adds the child-Widget to `myChildren`

  method view(state: CustomBox2State): Widget =
    gui:
      Box(orient = OrientY):
        for child in state.myChildren:
          insert child # Inserts child-widget into this CustomBox-widget

  proc toLabel(text: string): Widget =
    Widget gui Label(text = text)

  ## The App
  viewable App2:
    discard

  method view(state: App2State): Widget =
    let labels: seq[Widget] = @[
      "I was passed in from the outside".toLabel(),
      "Me too!".toLabel(),
      "Me three!".toLabel()
    ]

    gui:
      Window:
        CustomBox2():
          for widget in labels:
            insert widget

  when not defined(owlkettleNimiDocs):
    brew(gui(App2()))

nbText: """

NOTE: When instantiating the `Label` Widgets we do so using the `gui` macro in `toLabel`.
This can be done without the `gui` macro, but is not advised as you may forget to set the `has<Field>`- fields (see the Internals section).
"""

nbText: """

But what if we want to store child-widgets in a table-field on `CustomBox` ?
We would need to pass the key to store the child-widget under to the adder...

"""

nbSave
