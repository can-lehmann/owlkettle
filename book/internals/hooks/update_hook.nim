import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **Update Hook**
`update` hooks runs every time the `Widget` updates the `WidgetState`. In other words, whenever the application is redrawn, which occurs every time an event is thrown and every time the `WidgetState.redraw` method is called.

### **For Widgets**
On widgets the `update` hook is for cases where you want to update fields, but using an `update` hook on a single field is not a clean solution, e.g. where fields share an expensive operation that you do not want to repeat unnecessarily. For simpler cases, consider the `property`-hook (see the `property`-hook for more) or an `update` hook on that specific field.

Here an example demonstrating how the `update`-hook on a widget can be used:
"""

nbCode:
  import owlkettle

  ## The custom widget
  viewable MyViewable:
    text: string

    hooks:
      update:
        echo "Original Value: ", state.text
        state.text = state.text & " - Addition"
        echo "New Value     : ", state.text

  method view(state: MyViewableState): Widget =
    gui:
      Button(text = state.text):
        proc clicked() =
          echo "Event triggering update"

  ## The App
  viewable App:
    discard

  method view(app: AppState): Widget =
    result = gui:
      Window:
        MyViewable(text = "Defined by App")

  # brew(gui(App())) # Uncomment to execute app

nbText: """
### **For Fields**
Owlkettle provides default `update` hooks for every field. They are useful if you need simple custom behaviour, such as modifying the input slightly before updating a field with it. It is their responsibility to transfer data from `Widget` to their field in `WidgetState` as desired.

Here an example for how an `update` hook on a field can be used:
"""
nbCode:
  import owlkettle

  ## The custom widget
  viewable MyViewable2:
    text: string
        
    hooks text:
      update:
        echo "Received via Widget:    ", widget.valText
        if widget.hasText:
          state.text = widget.valText & " update hook addition"
        echo "Applied to WidgetState: ", state.text

  method view(state: MyViewable2State): Widget =
    gui:
      Button(text = state.text):
        proc clicked() =
          echo "\nEvent triggering update"

  ## The App
  viewable App2:
    discard

  method view(app: App2State): Widget =
    result = gui:
      Window:
        MyViewable2(text = "Example")

  # brew(gui(App2())) # Uncomment to execute app

nbText: """
Note that this hook is not run initially, so when the widget is first being built these changes are likely not applied yet. Look at the `build` hook if you need that behaviour, or `property` hook if you need both.

Also note that we checked if the `Widget.hasText` value is true before assigning values to that field. This check is useful as widgets may disable their field, in which case their updates should not be propagated back to the `WidgetState`.
"""
nbSave
