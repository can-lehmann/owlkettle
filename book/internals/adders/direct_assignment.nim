import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
## **Using direct assignment**

Another way to pass multiple Widgets to another Widget is handing them over directly.

This is discouraged, as it may side-step additional logic defined in the adder of the other Widget.
However, in some circumstances it is the only option, e.g. when you need to pass on a structure of `seq[seq[Widget]]`.
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


nbSave
