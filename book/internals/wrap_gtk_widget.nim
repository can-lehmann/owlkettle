import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## *Wrapping GTK Widgets*
This is a small guide on how you can wrap and contribute widgets directly provided by Gtk yourself!

### *Best Practices*
Owlkettle has coding conventions. 
Read about them in [CONTRIBUTING.md](https://can-lehmann.github.io/owlkettle/CONTRIBUTING.md).
As a piece of general advice, it is preferred to stick as close to the original Gtk Widget as possible.

### *Find the GTK Widget docs*
First find the docs belonging to the Gtk Widget so you know what it can do and what you need to wrap.
Generally searches on the [General Gtk docs](https://docs.gtk.org/gtk4/) or a web search with `gtk widget docs <widgetname>` should do it.

### *Setup*
Next lets create the type for the Widget and an example application for it.
Go to `owlkettle/widgets.nim` and add your type as `renderable <GtkWidgetName> of BaseWidget: discard`.
If your Widget shows in the GtkDocs that it inherits from another Widget that was already wrapped (e.g. `Window`) it is strongly encouraged to inherit in nim from that instead.
Then add an explicit export statement at the bottom of the file.

With the type available, we need an example application so we can see the widget in action.
Copy this example application to `examples/widgets` with the filename <widgetName>.nim` and adjust it to your needs:
"""

nbCode:
  # MIT License
  # 
  # Copyright (c) 2022 Can Joshua Lehmann
  # 
  # Permission is hereby granted, free of charge, to any person obtaining a copy
  # of this software and associated documentation files (the "Software"), to deal
  # in the Software without restriction, including without limitation the rights
  # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  # copies of the Software, and to permit persons to whom the Software is
  # furnished to do so, subject to the following conditions:
  # 
  # The above copyright notice and this permission notice shall be included in all
  # copies or substantial portions of the Software.
  # 
  # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  # SOFTWARE.

  import owlkettle

  viewable App: discard

  method view(app: AppState): Widget =
    result = gui:
      Window:
        title = "<GtkWidgetName> Example"
        defaultSize = (400, 200)
        Box(orient = OrientX, spacing = 6, margin = 12):
          Label(text = "REPLACE THIS LABEL WIDGET WITH YOUR NEW WIDGET")

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText: """
### *Wrap gtk functions*
Now we can look over the gtk docs we found earlier and look for the gtk-procs we need.

Add them to gtk.nim to the section for their class, maked by comments of `# Gtk.<ClassName>`.
If no such section a gtk-proc exists, add a new one. 
You will need to wrap, at minimum, the constructor for the new widget.

Keep the following things in mind:
  - If a proc-parameter in the docs inherits from `GtkWidget`, then use `GtkWidget` for the type
  - Use the nim equivalent for any C-type in the docs: `cbool` for `bool`, `cfloat` for `float`, `cdouble` for `double` etc.
  - If the docs of a proc mention that the caller needs to free the memory of the return value, then use a managed type for the return-type such as `OwnedGtkString` for cstrings (see e.g. `g_file_get_path`)

For examples of constructor procs, look for procs with the `_new` suffix in [gtk.nim](https://github.com/can-lehmann/owlkettle/blob/main/owlkettle/gtk.nim).

### *Add Initialization to the Widget*
Next we can add logic to construct the gtk widget.

Add a `beforeBuild` hook to the widget type in `widgets.nim`.
All it needs to do is call the constructor for your widget and assign the created GtkWidget to `state.internalWidget`.
If the constructor requires parameters, add fields with their values to your Widget and access the values from the implicitly available `widget` variable and its `val/has<Fieldname>` fields. 

For examples, search for `beforeBuild:` in [widgets.nim](https://github.com/can-lehmann/owlkettle/blob/main/owlkettle/widgets.nim).

### *Add Signal Event Listeners*
Now we can enable the gtk widget to call user-provided functions whenever a specific signal is fired by gtk.

##### 1) Add the proc signature of a signal-handler procs under the widget fields. 
These procs can be defined by users and get executed whenever signal they're connected to is fired.
You do not need to define a proc-body, definitions such as `proc clicked()` suffice. 
They should never have a return-type.
Try to name the signal-handler proc like the gtk signal.

For examples of such signatures, go to [widgets.nim](https://github.com/can-lehmann/owlkettle/blob/main/owlkettle/widgets.nim) and look for proc signatures in between widget fields and hook definitions.

##### 2) Add a `connectEvents` hook to the widget type in `widgets.nim`
In it, call the provided `connect` proc: `state.connect(state.<procName>, "<signalName>", <eventCallback>)`
Where:
  - <procName> is the name of the signal-handler proc
  - <signalName> is the name of the gtk signal
  - <eventCallback> is a proc that connects the signal-handler to the signal and updates the internal state if necessary. 

If a signal does not require the state of the widget to be updated (e.g. `clicked`), you can use the default `eventCallback` proc for <eventCallback>.
If a signal does require the state of the widget to be updated (e.g. `select`), you will need to define your own <eventCallback> proc.

A custom eventCallback proc will always need to:
  - Read back any state changes from GTK
  - Call the signal-handler proc (and pass any arguments it might have)
  - Call redraw to update the UI after the event was handled

For general examples of `connectEvents` hooks, search for `connectEvents:` in [widgets.nim](https://github.com/can-lehmann/owlkettle/blob/main/owlkettle/widgets.nim).
For examples that use the default eventCallback, search for `, eventCallback` in [widgets.nim](https://github.com/can-lehmann/owlkettle/blob/main/owlkettle/widgets.nim).
For examples that use custom eventCallbacks, enable regex search in your IDE and search for `connectEvents:\n.*?proc` in [widgets.nim](https://github.com/can-lehmann/owlkettle/blob/main/owlkettle/widgets.nim).

##### 3) Add a disconnectEvents hook to the widget type in `widgets.nim`
In it, call the provided `disconnect` proc: `state.internalWidget.disconnect(state.<procName>)`

### *See your example in action!*
Once you're at this step you should be able to compile your example and see your widget in action!
Run it with `nim r --path:. ./examples/path/to/your/example.nim` from the base dir of your owlkettle repository clone.

Add event callbacks in order to also see when signals get fired.


### *Add features to the Widget*
Beyond just creating the widget and providing event-listeners, Gtk may provide options to further customize a widget.
E.g. you may be able to show or hide values, change their positioning, enable or disable them etc. by updating certain fields at runtime after the widget was constructed.

Take a look at the procs of your widget (and the procs of its parent classes) in the gtk docs, specifically anything that isn't a getter.
If there's procs to add or set a property of the widget, try to add that feature to your wrapped widget.
At minimum, try to wrap all features exposed by your widget directly and possibly its direct parent (e.g. for `Gtk.Scale` everything from there as well as its parent `Gtk.Range`)

To do so, wrap the function as explained in an earlier section.
Add a field to your widget for every parameter required by the wrapped gtk procs.
If a field already exists because you use it during initialization with the constructor, then you don't need to add a new field.

Then add a `property` hook for every field on your widget that you have a wrapped gtk proc for.
The hook should do nothing but call the wrapped gtk proc with values from the implicitly available `state` variable.

Run your example to test whether the added feature does or does not work.

### *Add and update documentation*
Once you are satisfied with your widget, it's time to add a bit more documentation.

##### 1) Add documentation and examples
Add doc comments to properties and event callbacks to explain what they do.

Further you can add examples using owlkettle's `example` macro to demonstrate useage of the widget.
These will get automatically added to widget.ms in the next step

For examples that use the `example` macro, search for `, example:` in [widgets.nim](https://github.com/can-lehmann/owlkettle/blob/main/owlkettle/widgets.nim).


##### 2) Update widgets.md and examples/README.md
Once that is done run `nimble genDocs`.
This will add your new widgets, doc comments and examples to `widgets.md`, the main documentation file for widgets.
Once finished, commit the updated widgets.md.

Next take a screenshot of your example application against a white background and put it in `docs/assets/examples`.
Lastly, add an entry for your new widget to the widgets table of `examples/README.md`.

With all of that out of the way, you can now open up a pull request to the owlkettle main repo!
"""

nbSave