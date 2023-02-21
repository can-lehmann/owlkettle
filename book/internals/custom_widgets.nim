import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
## **Custom Widgets**
To make one, just declare the `Viewable` and the fields on its state, then write a `view` method that creates the `Widget`.

Let's look at a `CustomLabel` widget with a `text`-field that renders the text and another piece of text besides it.

"""
nbCode:
  import owlkettle 

  ### Custom Label Widget
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

  # brew(gui(App())) # Uncomment to execute gui

nbText: """

And that's your CustomLabel. Note though, that you can't write:

```nim
...
method view*(state: AppState): Widget =
  gui:
    Window:
      CustomLabel(text = "test"):
        Label(text = "Also render me!")
...
```

because CustomLabel doesn't have the ability to store or render child-Widgets!
For that we need adders!
""""