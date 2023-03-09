import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **Property Hook**
`property` hooks run every time the hook-field changed its value during either the update or build phases.
They are called by the default `build` and `update` field hooks near the end of their runtime and exist mostly for convenience.
If you want to have the same additional behaviour during build and update phases, you can define a `property` hook instead of a `build` and `update` hook.

They require some consideration when writing renderables, which very often do define explicit `build` and `update` hooks instead when dealing with child-widgets.
This is required because we need to access the current state of the widget before the update is performed, to correctly add/remove child widgets of the underlying GTK widget.

Let's take the examples of the `update` and `build` hook sections and unify them using the property hook:
"""

nbCode:
  import owlkettle
  import std/[sysrand, base64]

  ## The custom widget
  viewable MyViewable:
    text: string

    hooks text:
      property:
        echo "Property Hook"
        state.text = widget.valText & "Addition by property hook"

  method view(state: MyViewableState): Widget =
    gui:
      Button(text = state.text):
        proc clicked() =
          echo "\nEvent triggering update"

  ## The App
  viewable App:
    discard

  method view(app: AppState): Widget =
    result = gui:
      Window:
        MyViewable(text = "Example-" & urandom(2).encode())

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText: """
Note that there is no `update` or `build` hook defined for the `text` field. If we had defined those, they would need to include sections that call each individual `property` hook like their default implementations would.
"""
nbSave
