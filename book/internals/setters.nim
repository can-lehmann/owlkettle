import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
## **Setters**
Setters are a convenience mechanism for widgets.
Through them you can hide fields on your `WidgetState`.
Parent-widgets will be able to assign to "pseudo-fields", whose assigned values get converted and then forwarded to the actual field on `WidgetState`.

allow parent-widgets to assign to fields on `WidgetState` with different types of values that get converted to the field on `WidgetState`!

Every setter consists of:
- a `setter <PseudoFieldName>` declaration with the type that the setter receives, e.g. `setter margins: int` defines a setter that will receive an int from a parent-widget
- a `has<PseudoFieldName>=` proc, forwarding booleans that would enable/disable the pseudo-field to the actual field on `WidgetState`
- a `val<PseudoFieldName>=` proc, converting the value received by the pseudo-field as needed and assigning it to the actual field on `WidgetState`

Note: You only need 1 `has<PseudoFieldName>` proc, even if you define multiple setters.

Lets take a look at a code example:
"""

nbCode:
  ## The custom widget
  import owlkettle 
  
  viewable MyViewable:
    internalMargins: array[3, int]

    setter margins: int
    setter margins: array[3, int] 

  proc `hasMargins=`*(widget: MyViewable, has: bool) =
    widget.hasInternalMargins = has

  proc `valMargins=`*(widget: MyViewable, margin: int) =
    widget.valInternalMargins = [margin, margin, margin]

  proc `valMargins=`*(widget: MyViewable, margins: array[3, int]) =
    widget.valInternalMargins = margins

  method view(state: MyViewableState): Widget =
    gui:
      Box():
        Box(orient = OrientY) {.vAlign: AlignStart.}:
          Label(text = "Text1", margin = Margin(bottom: state.internalMargins[0]))
          Label(text = "Text2", margin = Margin(bottom: state.internalMargins[0]))
          Label(text = "Text3", margin = Margin(bottom: state.internalMargins[0]))

  ## The App
  viewable App:
    discard

  method view(app: AppState): Widget =
    result = gui:
      Window:
        Box(orient = OrientX):
          MyViewable(margins = [0, 60, 60])
          MyViewable(margins = 40)

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText: """
This defines a `MyViewable` that has a pseudo-field called `margins`, which hides the "true" field `internalMargins`.
When `margins` gets assigned to, it triggers the `valMargins=` procs, which will convert the received value into the type of `internalMargins` and assign it and assign it via `valInternalMargins`.

With this we can keep `internalMargins` hidden from the user.
They can now assign an `array[3, int]` **and** an `int` to the "margins" field, the int just gets turned into a `array[3, int]`!
This way you can be more concise in the value assignments, when the transformation is obvious.

In fact, setting `margin` on most widgets works the same way as explained here! 
You can either assign a `Margin` object, or an int which will get turned into a `Margin` object using the int as margin for every direction.
"""

nbSave
