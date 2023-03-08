import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **One Adder**

You will be able to add widgets to your current widget simply by virtue of having the "default" adder.

To do so you must:
  1) Add a field to your widget that can store child-Widgets (e.g. one with type `seq[Widget]`)
  2) Define an adder that enables the child-widget-field and adds a given widget to it
  3) Define in your `view` method how to display the child-widgets

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

### Using adders

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


### **Using direct assignment**
Another way to pass multiple Widgets to another Widget is handing them over directly.

This is somewhat discouraged, as it may side-step additional logic defined in the adder of the other Widget.
However, in some circumstances it is the only way, e.g. when you need to pass on a structure of `seq[seq[Widget]]`.
"""

nbCode:
  import owlkettle

  ## The custom widget
  viewable CustomBox3:
    myChildren: seq[Widget] # The child-widget field

    adder add: # Define the default adder `add`
      widget.hasMyChildren = true # Enables mutating `myChildren`
      widget.valMyChildren.add(child) # Adds the child-Widget to `myChildren`

  method view(state: CustomBox3State): Widget =
    gui:
      Box(orient = OrientY):
        for child in state.myChildren:
          insert child # Inserts child-widget into this CustomBox-widget

  proc toLabel2(text: string): Widget =
    Widget gui Label(text = text)

  ## The App
  viewable App3:
    discard

  method view(state: App3State): Widget =
    let labels: seq[Widget] = @[
      "I was passed in from the outside".toLabel2(),
      "Me too!".toLabel2(),
      "Me three!".toLabel2()
    ]

    gui:
      Window:
        CustomBox3():
          myChildren = labels

  when not defined(owlkettleNimiDocs):
    brew(gui(App3()))

nbText: """

But what if we want to store child-widgets in a table-field on `CustomBox` ? We would need to pass the key to store the child-widget under to the adder...

"""
nbSave
