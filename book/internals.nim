import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
<style>
.coal img.invertable-image,
.navy img.invertable-image,
.ayu img.invertable-image {
  filter: invert(100%);
}
</style>
"""

nbText: """
## **Widget-Basics**

### **Viewables vs. Renderables**
Every widget in owlkettle is a child of `Widget` and either a `renderable` or a `viewable` widget.

`Renderable` widgets provide declarative interfaces to GTK widgets.
For example `Button`, `Window` and `Entry` are renderable widgets.

<img alt="Owlkettle Class Diagram" class="invertable-image" src="../docs/assets/internals/class_diagram.png" width="500px">

`Viewable` widgets are abstractions over renderable widgets.
Owlkettle applications and any custom widgets written by you are usually implemented as viewable widgets.

### **Widget and WidgetState**

Every widget consists of a `WidgetState` and a `Widget`, independent of whether it is `renderable` or `viewable`.
The `WidgetState` represents the internal state of the widget which is persistent between redraws.
Its state is updated on every redraw by the `Widget`.
The `Widget` records which fields are set (`has<FieldName>`) and what their values are (`val<FieldName>`).

By separating the instance that receives new values (`Widget`) from the instance that records internal state (`WidgetState`) and requiring logic that defines how to transfer changes from one to the other, owlkettle manages to preserve the widget's state between redraws.

<img alt="Owlkettle Class Diagram" class="invertable-image" src="../docs/assets/internals/workflow.png" width="800px">

`viewable` widgets are abstractions over `renderable` or other `viewable` widgets.
Their `view` method returns a widget tree which is used to update the `WidgetState` of their expansion.
When you return another `viewable` widget from the `view` method owlkettle recursively calls `view` on it until `renderable` is reached.

When the state of a `renderable` widget is updated, it not only copies the set values from the `Widget`, but also applies any changes to the underlying GTK widget.
"""

nbSave
