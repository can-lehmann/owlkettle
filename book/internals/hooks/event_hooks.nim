import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **ConnectEvents/DisconnectEvents Hook**
The `connectEvents` hook runs during the build-phase as well as during every update-phase after the `disconnectEvents` hook.
The `disconnectEvents` hook meanwhile only runs at the start of the update phase.
It should be noted that triggering an event also causes an update phase to run.

These hooks are only relevant for renderables, as their task is to attach/detach event-listeners passed to `WidgetState` to/from the underlying GTK-widget.

Here a minimal example of a custom button widget that provides a `clicked` event:
"""
nbCode:
  import owlkettle
  import std/tables
  import owlkettle/[widgetutils, gtk]

  renderable MyButton of BaseWidget:
    proc clicked()

    hooks:
      beforeBuild:
        state.internalWidget = gtk_button_new()

      connectEvents:
        echo "Connect"
        state.connect(state.clicked, "clicked", eventCallback)

      disconnectEvents:
        echo "Disconnect"
        state.internalWidget.disconnect(state.clicked)

  viewable App:
    discard

  method view(app: AppState): Widget =
    result = gui:
      Window:
        MyButton():
          proc clicked() = echo "Potato"

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))


nbSave
