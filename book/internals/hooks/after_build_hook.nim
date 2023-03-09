import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **AfterBuild Hook**
The `afterBuild`-hook runs once after initial values (default-values or values propagated from the `Widget`) have been assigned to the `WidgetState`.

They are useful if any processing on the initial data that is passed in must happen. Example are validating data, inferring data from passed in data, or fetching other data based on what was passed in.
In renderables they are also useful to update the GTK widget once with data from the initial `WidgetState`.

It should be noted that unlike `build` hooks, `afterBuild` hooks are not inherited by any child-widget. For more information, see the `build` hooks section.

Let's return to our earlier renderable example and write it so that the parent-widget can decide what text the `MyRenderable` should display:
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
        state.internalWidget = gtk_label_new("")

      afterBuild:
        gtk_label_set_text(state.internalWidget, state.text.cstring)

  viewable App:
    discard

  method view(app: AppState): Widget =
    result = gui:
      Window:
        MyRenderable(text = "Defined by App")

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText: """
Note: The value of the Label is set only *once*  during build-time and never updated afterwards!
If you want this section to be updated when the input from the parent-widget changes, you may want to look into `property` hooks.

"""
nbSave
