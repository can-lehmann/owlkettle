# **Owlkettle Internals**

## **Widget-Basics**

Every widget in owlkettle is either a `renderable` or a `viewable` widget.

`Renderable` widgets provide declarative interfaces to GTK widgets.
For example `Button`, `Window` and `Entry` are renderable widgets.

`Viewable` widgets are abstractions over renderable widgets.
Owlkettle applications and any custom widgets written by you are usually implemented as viewable widgets.

Regardless of that distinction, all widget consists of a `WidgetState` and a `Widget`. The `Widget` represents the actual widget that gets rendered. It receives data from either parent-widgets or user-inputs and is used to update the `WidgetState` with them. The `WidgetState` is the overal internal widget state, that transforms data it receives as necessary and uses that to update the `Widget` instance. By separating the instance that receives new values (`Widget`) from the instance that records internal state (`WidgetState`) and requiring logic that defines how to transfer changes from one to the other, owlkettle manages to preserve the widget's state without unintentionally losing data.

In `Viewable` Widgets the `WidgetState` is used to generate a new `Widget` instance initially and whenever it gets updated via a `view` method. It should be noted that in the `gui` section of a `view` method you are effectively calling `view` methods of whatever widget you use in there until you reach a renderable. 

In `Renderable` widgets the `Widget` is updated, if necessary, via hooks, there is no `view` method that generates new Widgets.

```mermaid
classDiagram
  class Widget {
    build() WidgetState
    update(state: WidgetState) WidgetState
  }
  class WidgetState {
    read()
  }
  class Viewable {
    view() WidgetState
  }
  class Renderable {
  }
  Viewable --> Widget: view
  WidgetState <|-- Viewable
  WidgetState <|-- Renderable
  Widget --> WidgetState: build/update
```

Any field on a `WidgetState` is represented on the generated Widget via the fields `has<Field>` and `val<Field>`.

```mermaid
flowchart LR
  subgraph updater
    direction BT
    Window .->|child| Label
  end
  App -->|build| AppState -->|view| updater
  updater -->|build/update| state
  subgraph state
    direction BT
    WindowState .->|child| LabelState
  end
```

## **Custom Widgets**
To make one, just declare the `Viewable` and the fields on its state, then write a `view` method that creates the `Widget`.

Let's look at a `CustomLabel` widget with a `text`-field that renders the text and another piece of text besides it.

```nim
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

when isMainModule:
  brew(gui(App()))
```

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

## **Adding Widgets with Adders**
### **One Adder**
Not all Widgets have adders. But all Widgets that want to be passed other Widgets from the outside to contain (like `Box` for example) need at least one.

To do this you must:
1) Add a field to your widget-state that can store child-Widgets (e.g. one with type `seq[Widget]`)
2) Define an adder that enables the child-widget-field and adds a given widget to it
3) Define in your `view` method where to put the child-widgets from the widget-state

An adder is a proc that enables the field that stores child-widgets and defines how to add widgets to that field.
It implicitly receives the parameters 1) `widget` of type `Widget` (the custom widget itself) and 2) `child` of type `Widget` (the child-widget to add).

"Enabling" a field of your custom widget means that it allows an "outside"-Widget to mutate it. In this case it allows adding `Widget`s to the child-widget-field. Without that, manipulating the child-widget-field field is not possible. 

Note: Any field you define under `viewable` will be present on `widget` in the form of the boolean field `has<FieldName>` and `val<FieldName>`. `has<FieldName>` controls whether the field is dis/enabled. `val<FieldName>` is the actual field value. 

Let's look at an example for a `CustomBox`:

```nim
import owlkettle

## The custom widget
viewable CustomBox:
  myChildren: seq[Widget] # The child-widget field

  adder add: # Define the default adder `add`
    widget.hasMyChildren = true # Enables mutating `myChildren`
    widget.valMyChildren.add(child) # Adds the child-Widget to `myChildren`

method view(state: CustomBoxState): Widget =
  gui: 
    Box(orient = OrientY):
      for child in state.myChildren:
        insert child # Inserts child-widget into this CustomBox-widget

## The App
viewable App:
  discard

method view(state: AppState): Widget =
  gui:
    Window:
      CustomBox():
        Label(text = "I was passed in from the outside")
        Label(text = "Me too!")
        Label(text = "Me three!")

when isMainModule:
  brew(gui(App()))
```

We define `myChildren` and "enable" it in the `add` adder via `widget.hasMyChildren = true`.
Then we define how to add the `child` Widget to it, which in this case is simply us adding it to the seq.

But what if we want to store child-widgets in a table-field on `CustomBox` ? We would need to pass the key to store the child-widget under to the adder...
### **Adders with properties**
Let's make a custom widget that stores Widgets in a `Table[string, Widget]` and displays the widget next to the key it was stored with.

First we need to modify our adder, telling it that there will be additional parameters. 

```nim
...
viewable CustomBox:
  myChildren: Table[string, Widget] # The child-widget field

  adder add {.key: none(string).}: 
...
``` 

Additional parameters passed to adders like that are called "properties". Properties **must** have a default value, their type is inferred based on that value. If you do not want to provide a default value, you can use an `Option` type.

Let's assert that anyone using `CustomBox` also passes a key and doesn't accidentally reuse a key that has already been used to store a Widget that in the table:

```nim
viewable CustomBox:
  myChildren: Table[string, Widget] # The child-widget field

  adder add {.key: none(string).}: 
    assert key.isSome(), "CustomBox requires you to tell it under which key to store child widgets. Add a 'key' property"
    
    let keyIsFree = not widget.valMyChildren.hasKey(key.get()) 
    assert keyIsFree, fmt"A widget with the key '{key.get()} has already been added to CustomBox. Use a different name"

    widget.hasMyChildren = true 
    widget.valMyChildren[key.get()] = child

method view(state: CustomBoxState): Widget =
  gui: 
    Box(orient = OrientY):
      for key in state.myChildren.keys:
        Box():
          Label(text = key)
          insert state.myChildren[key]

## The App
viewable App:
  discard

method view(state: AppState): Widget =
  gui:
    Window:
      CustomBox():
        Label(text = "I was passed in from the outside") {.key: some("key1").}
        Label(text = "Me too!") {.key: some("key2").}
        Label(text = "Me three!") {.key: some("key3").}
        # Label(text = "Me four!") {.key: some("key3").} # Will cause a runtime error because key3 is already in use

when isMainModule:
  brew(gui(App()))
```

If we were to remove the "#" in front of the last Label, we would be facing a runtime error produced by the application, since "key3" was already used.

Note: When using optionals, due to the macros involved, you can only use the `some(<value>)`/`none(<typedesc>)` syntax.

### **Multiple Adders**
In addition to passing properties to an adder, you can naturally also have multiple different adders. They just need different names.

Let's look at a `CustomBox` widget with 2 `seq[Widget]` fields that you add to with different adders:

```nim
import owlkettle

viewable CustomBox:
  myChildren1: seq[Widget]
  myChildren2: seq[Widget]

  adder add: 
    widget.hasMyChildren1 = true 
    widget.valMyChildren1.add child
  
  adder add2:
    widget.hasMyChildren2 = true
    widget.valMyChildren2.add child

method view(state: CustomBoxState): Widget =
  gui: 
    Box(orient = OrientY):
      Box():
        Label(text = "First Box")
        for widget in state.myChildren1:
          insert widget
        
      Box():
        Label(text = "Second Box")
        for widget in state.myChildren2:
          insert widget

## The App
viewable App:
  discard

method view(state: AppState): Widget =
  gui:
    Window:
      CustomBox():
        Label(text = "I was passed in from the outside") # Uses "add"-adder implicitly by default 
        Label(text = "Me too!") {.add.} # Uses "add"-adder explicitly
        Label(text = "Me three!") {.add2.} # Uses "add2"-adder explicitly

when isMainModule:
  brew(gui(App()))
```

If no adder is specified, `Widget`s will always be added using the `add` adder. Otherwise the adder defined by the pragma annotation will be used.

## **Hooks**
Hooks are a concept introduced by owlkettle that allows you to execute code throughout a widget's lifecycle, or when an action on one of its fields occurs.

Most hooks are defined only for Widgets, some are defined for both and `property` is only available as a hook for fields.

The available hooks are:

|Hook Type | For renderables | For viewables | Name | Description|
|---|---|---|---|---|
|W | Yes | No  | BeforeBuild | Executed only once before the `WidgetState` is created.|
|WF | Yes | Yes | Build       | Executed only once after `WidgetState` is instantiated from `Widget`. Default values have not yet been applied and will overwrite any values set within this hook.|
| W | Yes | Yes | AfterBuild  |  Executed only once after the `WidgetState` was created. Is executed *after* all default values have been applied.|
| W | Yes | No  | ConnectEvents  | Only relevant for renderables. Executed every time a callback is supposed to be attached to the underlying GTK widget. It defines how to do so.|
| W | Yes | No  | DisconnectEvents  | Only relevant for renderables. Executed every time a callback is supposed to be removed from the underlying GTK widget. It defines how to do so.|
| WF | Yes | Yes | Update | Executed every time `WidgetState` is updated by `Widget`.  |
| F | Yes | Yes | Property  | Executed every time the hook-field changed its value during the update or build phases.|
| F | Yes | No  | Read  | Used in `Dialog`. Executes every time the state of the underlying GTK-Widget changes. |

W: Can act as hook for Widgets
F: Can act as hook for fields

All hooks have implicit access to a variable called `state`, which contains the `WidgetState`-instance of your particular widget.

With the exception of `read`, all hooks also have implicit access to a variable called `widget`, which is the `Widget` instance.

Generally the `build`, `property` and `update` hooks are likely to have the highest utility for you. Consult their individual sections for more information.

### **Build Hook**
The `build` hook runs once just before any values are assigned to the `WidgetState`.

#### **For Widgets**
`build` hooks on widgets should be used when additional logic is necessary that sets multiple fields on `WidgetState` during widget instantiation. Note that such fields should not have assigned default values, as they will be overwritten when default values get applied after the build phase.

Example: A Widget may need to load data from elsewhere, via a file or HTTP request for one field, and a second field must be inferred from a value of the first field.

Here a simple code-example:

```nim
# example.json
{"name":"example"}

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

brew(gui(App()))
```

`build` hooks on widgets also are inherited from the parent-widget. In those scenarios, during the build-phase owlkettle will first execute the `build` hook of the parent and then the `build` hook of the child.

To demonstrate this, here a small example:

```nim
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

viewable App:
  discard

method view(app: AppState): Widget =
  result = gui:
    Window:
      Child()

brew(gui(App()))
```
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

#### **For Fields**
Owlkettle provides default `build` hooks for every field. They are useful if you need simple custom behaviour, such as modifying the input slightly before initially assigning it to a field. It is their responsibility to transfer data from `Widget` to their field in `WidgetState` during the build-phase.

`build` hooks on fields should be used when additional logic is necessary that sets this single field on `WidgetState`. 

Here an example for how a `build` hook on a field can be used:

```nim
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
viewable App:
  discard

method view(app: AppState): Widget =
  result = gui:
    Window:
      MyViewable(text = "Example")

brew(gui(App()))
```

Note that this hook is not run during updates, so any changes here may be lost if an update overwrites them. Look at the `update` hook if you need that behaviour, or `property` hook if you need both.

### **BeforeBuild Hook**
The `beforeBuild` hook runs once before the build-hook and thus also before any values are assigned to the `WidgetState`.

Their main usecase is renderables, where they are used to instantiate the GTK-Widget and assign it to `internalWidget` on `WidgetState`.

It should be noted that unlike `build` hooks, `beforeBuild` hooks are not inherited by any child-widget. For more information, see the `build` hooks section.

Here a simple code-example for writing a `beforeBuild` hook:

```nim
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

brew(gui(App()))
```

We set the label-text to render directly via the `gtk_label_new` proc.
But what if we want to have a parent widget decide the text to render once and then never update it again?  

That leads us to what `afterBuild` hooks are...

### **AfterBuild Hook**
The `afterBuild`-hook runs once after initial values (default-values, values passed in by other widgets during instantiation) have been assigned to the `WidgetState`.

They are useful if any processing on the initial data that is passed in must happen. Example are validating data, inferring data from passed in data, or fetching other data based on what was passed in. In renderables they are also useful to update the GTK widget once with data from the initial `WidgetState`.

It should be noted that unlike `build` hooks, `afterBuild` hooks are not inherited by any child-widget. For more information, see the `build` hooks section.

Let's return to our earlier renderable example and write it so that the parent-widget can decide what text the `MyRenderable` should display: 

```nim
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

brew(gui(App()))
```

Note: The value of the Label is set only *once*  during build-time and never updated afterwards!
If you want this section to be updated when the input from the parent-widget changes, you may want to look into `property` hooks.

### **ConnectEvents/DisconnectEvents Hook**
The `connectEvents` hook runs during the build-phase as well as during every update-phase after the `disconnectEvents` hook. The `disconnectEvents` hook meanwhile only runs during the update phase. It should be noted that triggering an event also causes an update phase to run.

These hooks are only relevant for renderables, as their task is to attach/detach event-listeners stored in `WidgetState` to/from the underlying GTK-widget. 

Here a minimal example of a custom button widget that connects an event-listener proc to the gtk click event and disconnects it on update:

```nim
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

brew(gui(App()))
```

### **Update Hook**
`update` hooks runs every time the `Widget` updates the `WidgetState`. In other words, whenever the application is redrawn, which occurs every time an event is thrown and every time the `WidgetState.redraw` method is called.

#### **For Widgets**
On widgets the `update` hook is for cases where you want to update fields, but using an `update` hook on a single field is not a clean solution, e.g. where fields share an expensive operation that you do not want to repeat unnecessarily. For simpler cases, consider the `property`-hook (see the `property`-hook for more) or an `update` hook on that specific field.

Here an example demonstrating how the `update`-hook on a widget can be used:

```nim
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

brew(gui(App()))
```

#### **For Fields**
Owlkettle provides default `update` hooks for every field. They are useful if you need simple custom behaviour, such as modifying the input slightly before updating a field with it. It is their responsibility to transfer data from `Widget` to their field in `WidgetState` as desired.

Here an example for how an `update` hook on a field can be used:

```nim
import owlkettle

## The custom widget
viewable MyViewable:
  text: string
      
  hooks text:
    update:
      echo "Received via Widget:    ", widget.valText
      if widget.hasText:
        state.text = widget.valText & " update hook addition"
      echo "Applied to WidgetState: ", state.text

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
      MyViewable(text = "Example")

brew(gui(App()))
```

Note that this hook is not run initially, so when the widget is first being built these changes are likely not applied yet. Look at the `build` hook if you need that behaviour, or `property` hook if you need both.

Also note that we checked if the `Widget.hasText` value is true before assigning values to that field. This check is useful as widgets may disable their field, in which case their updates should not be propagated back to the `WidgetState`.

### **Property Hook**
`property` hooks run every time the hook-field changed its value during either the update or build phases. They are called by the default `build` and `update` field hooks near the end of their runtime and exist mostly for convenience. If you want to have the same additional behaviour during build and update phases, you can define a `property` hook instead of a `build` and `update` hook.

They require some consideration when writing renderables, which very often do define explicit `build` and `update` hooks instead when dealing with child-widgets. This is required because we need to access the current state of the widget before the update is performed, to correctly add/remove child widgets of the underlying GTK widget.

Let's take the examples of the `update` and `build` hook sections and unify them using the property hook:

```nim
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

brew(gui(App()))
```

Note that there is no `update` or `build` hook defined for the `text` field. If we had defined those, they would need to include sections that call each individual `property` hook like their default implementations would. 

### **Read Hook**
The `read` hook is a custom hook solely used by widgets that are renderables and deal with user input. They may need a hook at times that sends back the current state within a `Widget` whenever the user changes said state through interaction. This hook is then responsible for propagating the changes done by the user from the state of `Widget` to `WidgetState`.

Let's look at a minimal example of the `ColorChooserDialog`:

```nim

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
          style = {ButtonSuggested}
          proc clicked() =
            let (res, state) = app.open: gui:
              MyColorChooserDialog()

brew(gui(App()))
```

The `read` hook will execute after a color was chosen and confirmed.
Only then will it update the state with the chosen color. How to extract the data of the user-interaction will depend on the gtk-widget being wrapped.

Note that during the choosing of the color and when updating `WidgetState` via the `read` hook, no `update` hook is being executed.

