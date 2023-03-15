import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **Multiple Adders**

In addition to passing properties to an adder, you can also have multiple different adders.

Let's look at a `CustomBox` widget with 2 `seq[Widget]` fields that you add to with different adders:
"""

nbCode:
  import owlkettle

  viewable CustomBox:
    myChildren1: seq[Widget]
    myChildren2: seq[Widget]

    adder add:
      widget.hasMyChildren1 = true
      widget.valMyChildren1.add child

    adder add2:
      widget.hasMyChildren2 = true
      widget.valMyChildren2.add child

  method view(state: CustomBoxState): Widget =
    gui:
      Box(orient = OrientY):
        Box():
          Label(text = "First Box")
          for widget in state.myChildren1:
            insert widget

        Box():
          Label(text = "Second Box")
          for widget in state.myChildren2:
            insert widget

  ## The App
  viewable App:
    discard

  method view(state: AppState): Widget =
    gui:
      Window:
        CustomBox():
          Label(text = "I was passed in from the outside") # Uses "add"-adder implicitly by default
          Label(text = "Me too!") {.add.} # Uses "add"-adder explicitly
          Label(text = "Me three!") {.add2.} # Uses "add2"-adder explicitly

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText: """
If no adder is specified, `Widget`s will always be added using the `add` adder.
Otherwise the adder defined by the pragma annotation will be used.
"""

nbSave
