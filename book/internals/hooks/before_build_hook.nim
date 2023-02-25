import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **BeforeBuild Hook**

The `beforeBuild` hook runs once before the build-hook and thus also before any values are assigned to the `WidgetState`.
They are mainly used in `renderables` to instantiate the GTK-Widget and assign it to `internalWidget` on `WidgetState`.

It should be noted that unlike `build` hooks, `beforeBuild` hooks are not inherited by any child-widget. For more information, see the `build` hooks section.

Here a simple code-example for writing a `beforeBuild` hook:
"""

nbCode:
  import owlkettle
  import owlkettle/gtk
  import std/json

  renderable MyRenderable:
    text: string

    hooks:
      beforeBuild:
        echo state.repr
        state.internalWidget = gtk_label_new("ExampleText")

  viewable App:
    discard

  method view(app: AppState): Widget =
    result = gui:
      Window:
        MyRenderable()

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText: """
We set the label-text to render directly via the `gtk_label_new` proc.
But what if we want to have a parent widget decide the text to render once and then never update it again?

That leads us to what `afterBuild` hooks are...
"""
nbSave
