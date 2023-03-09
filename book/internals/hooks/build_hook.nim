import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **Build Hook**

The `build` hook runs once just before any values are assigned to the `WidgetState`.

### **For Widgets**


`build` hooks on widgets should be used when additional logic is necessary that sets multiple fields on `WidgetState` during widget instantiation.
Note that such fields should not have assigned default values, as they will be overwritten when default values get applied after the build phase.

Example: A Widget may need to load data from elsewhere, via a file or HTTP request for one field, and a second field must be inferred from a value of the first field.

Here a simple example that uses the `build` hook to load a configuration file for the application:

example.json

```json
{"name":"example"}
```
"""

nbCode:
  # main.nim
  import std/json
  import owlkettle
  import owlkettle/gtk

  type Config = object
    name: string

  viewable App:
    config: Config

    hooks:
      build:
        state.config = "./src/example.json".readFile().parseJson().to(Config)

  method view(state: AppState): Widget =
    result = gui:
      Window:
        Label:
          text = state.config.name

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText: """
`build` hooks on widgets also are inherited from the parent-widget. In those scenarios, during the build-phase owlkettle will first execute the `build` hook of the parent and then the `build` hook of the child.

To demonstrate this, here a small example:
"""

nbCode:
  import owlkettle

  viewable Parent:
    hooks:
      build:
        echo "Parent.build"
      beforeBuild:
        echo "Parent.beforeBuild"
      afterBuild:
        echo "Parent.afterBuild"

  method view(state: ParentState): Widget =
    gui:
      Label(text="Parent")

  viewable Child of Parent:
    hooks:
      build:
        echo "Child.build"
      beforeBuild:
        echo "Child.beforeBuild"
      afterBuild:
        echo "Child.afterBuild"

  method view(state: ChildState): Widget =
    gui:
      Label(text="Child")

  viewable App2:
    discard

  method view(app: App2State): Widget =
    result = gui:
      Window:
        Child()

  when not defined(owlkettleNimiDocs):
    brew(gui(App2()))

nbText: """
This will print:
```txt
Child.beforeBuild
Parent.build
Child.build
Child.afterBuild
```

This makes sense, as only the purpose of the `build` hook (handling instantiating data not provided elsewhere) is also useful for any child-widgets.

Given that the purpose of `beforeBuild` is to handle instantiating renderables and `afterBuild` is about doing any extra handling of transforming of data given to the widget, both of which are very specific for their respective widget, it makes sense that they are "overwritten" instead of inherited.

For more info on the purpose of `beforeBuild` and `afterBuild` hooks, consult their respective sections in this file.

### **For Fields**

A `build` hook is responsible for transfering the value of a field from the `Widget` to the `WidgetState` during the build-phase.
Owlkettle provides default `build` hooks for every field, that simply assign the value of the field in the `Widget` to the field in the `WidgetState` if it is set.
Overwriting the `build` hook is useful if you need to define custom behaviour, such as modifying the input slightly before initially assigning it to a field.

`build` hooks on fields should be used when additional logic is necessary that sets this single field on `WidgetState`.

Here an example for how a `build` hook on a field can be used:

"""
nbCode:
  import owlkettle

  ## The custom widget
  viewable MyViewable:
    text: string

    hooks text:
      build:
        echo "Received via Widget:    ", widget.valText
        state.text = widget.valText & " build hook addition"
        echo "Applied to WidgetState: ", state.text

  method view(state: MyViewableState): Widget =
    gui:
      Button(text = state.text):
        proc clicked() =
          echo "\nEvent triggering update"

  ## The App
  viewable App3:
    discard

  method view(app: App3State): Widget =
    result = gui:
      Window:
        MyViewable(text = "Example")

  when not defined(owlkettleNimiDocs):
    brew(gui(App3()))

nbText: """
Note that this hook is not run during updates, so any changes here may be lost if an update overwrites them. Look at the `update` hook if you need that behaviour, or `property` hook if you need both.
"""
nbSave
