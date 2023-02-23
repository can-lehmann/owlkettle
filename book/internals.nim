import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
## **Widget-Basics**

Every widget in owlkettle is either a `renderable` or a `viewable` widget.

`Renderable` widgets provide declarative interfaces to GTK widgets.
For example `Button`, `Window` and `Entry` are renderable widgets.

<img alt="Owlkettle Class Diagram" src="../docs/assets/internals/class_diagram.png" width="500px">

`Viewable` widgets are abstractions over renderable widgets.
Owlkettle applications and any custom widgets written by you are usually implemented as viewable widgets.

Regardless of that distinction, all widget consists of a `WidgetState` and a `Widget`. The `Widget` represents the actual widget that gets rendered. It receives data from either parent-widgets or user-inputs and is used to update the `WidgetState` with them. The `WidgetState` is the overal internal widget state, that transforms data it receives as necessary and uses that to update the `Widget` instance. By separating the instance that receives new values (`Widget`) from the instance that records internal state (`WidgetState`) and requiring logic that defines how to transfer changes from one to the other, owlkettle manages to preserve the widget's state without unintentionally losing data.

In `Viewable` Widgets the `WidgetState` is used to generate a new `Widget` instance initially and whenever it gets updated via a `view` method. It should be noted that in the `gui` section of a `view` method you are effectively calling `view` methods of whatever widget you use in there until you reach a renderable. 

In `Renderable` widgets the `Widget` is updated, if necessary, via hooks, there is no `view` method that generates new Widgets.

<img alt="Owlkettle Class Diagram" src="../docs/assets/internals/workflow.png" width="800px">

Any field on a `WidgetState` is represented on the generated Widget via the fields `has<Field>` and `val<Field>`.

"""

nbSave
