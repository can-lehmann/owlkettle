import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **Read Hook**

The `read` hook is a custom hook solely used by widgets that are renderables and deal with user input.
It is then responsible for propagating the changes done by the user back to the `WidgetState`.

Let's look at a minimal example from the `ColorChooserDialog` widget:
"""

nbCode:
  import owlkettle
  import owlkettle/[gtk, widgetdef]

  # The custom widget
  renderable MyColorChooserDialog of BuiltinDialog:
    color: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0)

    hooks:
      beforeBuild: ## Necessary for renderable to instantiate Widget in general
        state.internalWidget = gtk_color_chooser_dialog_new(
          widget.valTitle.cstring,
          nil.GtkWidget
        )

    hooks color:
      read: ## Will execute after userinput was provided, propagates value to to `WidgetState`
        var color: GdkRgba
        gtk_color_chooser_get_rgba(state.internalWidget, color.addr)
        echo "ReadHook - old state color: ", state.color.repr
        state.color = (color.r.float, color.g.float, color.b.float, color.a.float)
        echo "ReadHook - new state color: ", state.color.repr

  ## The App
  viewable App:
    discard

  method view(app: AppState): Widget =
    result = gui:
      Window:
        HeaderBar {.addTitlebar.}:
          Button {.addLeft.}:
            text = "Open"
            style = [ButtonSuggested]
            proc clicked() =
              let (res, state) = app.open: gui:
                MyColorChooserDialog()

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText: """
The `read` hook will execute after a color was chosen and confirmed.
Only then will it update the state with the chosen color. How to extract the data of the user-interaction will depend on the gtk-widget being wrapped.

Note that during the choosing of the color and when updating `WidgetState` via the `read` hook, no `update` hook is being executed.

"""
nbSave
