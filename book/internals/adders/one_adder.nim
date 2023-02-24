import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **One Adder**

The simplest way to use adders is just to have one.

To create a widget that can contain other widgets, you must:
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

  when not defined(owlkettleDocs):
    brew(gui(App()))

nbText: """
We define `myChildren` and "enable" it in the `add` adder via `widget.hasMyChildren = true`.
Then we define how to add the `child` Widget to it, which in this case is simply us adding it to the seq.

But what if we want to store child-widgets in a table-field on `CustomBox` ? We would need to pass the key to store the child-widget under to the adder...

"""
nbSave
