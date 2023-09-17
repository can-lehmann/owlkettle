import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
## **Setters**

Setters are a convenience mechanism for creating widgets.
During creation, setters act like any other field on the widget, in the sense that they can be assigned to. 
When a setter is assigned to, it is executed and can decide how the assigned value should be handled.

One example is the `Button.icon` setter. 
When assigning to it, the setter creates an `Icon` widget with the given name and adds it to the `Button`.

Another usecase is converting the type assigned to a field before storing it. 
For example, the `BaseWidget.margin` setter has overloads for both the `Margin` object and `int`. 
When you assign an `int` to the `margin` setter, it first converts it to a `Margin` object with the same margin on all sides. 
When you assign a `Margin` object, it gets stored directly.

To create a setter you need:
- a `setter <SetterName>` declaration with the type that the setter receives, e.g. `setter margins: int` defines a setter that will receive an int from a parent-widget
- a `has<SetterName>=` proc, forwarding booleans that would enable/disable the "field" represented by the setter to the actual field on `WidgetState`
- a `val<SetterName>=` proc, converting the value received by the setter as needed and assigning it to the actual field on `WidgetState`

Note: You only need 1 `has<SetterName>` proc, even if you define multiple setters.

Lets take a look at a code example:
"""

nbCode:
  ## The custom widget
  import owlkettle, sequtils
  
  viewable LabelList:
    labelTexts {.private.}: seq[string]
    
    setter texts: openArray[string] 
    setter texts: openArray[int]

  proc `hasTexts=`*(widget: LabelList, has: bool) =
    widget.hasLabelTexts = has

  proc `valTexts=`*(widget: LabelList, texts: openArray[string]) =
    widget.valLabelTexts = @texts

  proc `valTexts=`*(widget: LabelList, slice: openArray[int]) =
    widget.valLabelTexts = mapIt(slice, $it)

  method view(state: LabelListState): Widget =
    result = gui:
      Box(orient = OrientY):
        for text in state.labelTexts:
          Label(text = text)

  ## The App
  viewable App:
    discard

  method view(app: AppState): Widget =
    result = gui:
      Window:
        Box(orient = OrientX):
          LabelList(texts = ["Hello", "World"])
          LabelList(texts = [1, 2, 3])

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText: """
This defines a `LabelList` that has a setter called `texts`.
When `texts` gets assigned to, it triggers the `valTexts=` procs.
This will convert the received value into the type of `labelTexts` and assign to it via `valLabelTexts`.

Thus, via the setter the widget can now accept an `openArray[string]` **and** an `openArray[int]` for the "texts" field!
"""

nbSave
