import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
## **Custom Widgets**

To create a custom widget, just declare a new `viewable` and then write a `view` method for it.
The `viewable` defines all fields of the widget and the `view` method specifies how to render the custom widget.

Let's look at a `CustomLabel` widget with a `text`-field that renders the text with another piece of text besides it.

"""

nbCode:
  import owlkettle

  ## Custom Label Widget
  viewable CustomLabel:
    text: string

  method view*(state: CustomLabelState): Widget =
    echo state.repr
    gui:
      Box():
        Label(text = "I was passed the value: ")
        Label(text = state.text)

  ## The App
  viewable App:
    discard

  method view*(state: AppState): Widget =
    gui:
      Window:
        CustomLabel(text = "test")

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbSave