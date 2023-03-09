import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
## **Setters**
Setters are a convenience mechanism for creating widgets.
During creation, setters act like any other field on the widget, in the sense that they can be assigned to. 
When doing this assignment, the setter is executed and can decide how the assigned value should be handled.

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
This defines a `MyViewable` that has a setter called `margins`.
When `margins` gets assigned to, it triggers the `valMargins=` procs.
This will convert the received value into the type of `internalMargins` and assign to it via `valInternalMargins`.

Thus, via the setter the widget can now accept an `array[3, int]` **and** an `int` for the "internalMargins" field, the int just gets turned into a `array[3, int]`!
"""

nbSave
