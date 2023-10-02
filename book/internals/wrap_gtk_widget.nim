import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## *Wrapping GTK widgets*
This is a small guide on how you can wrap and contribute widgets from GTK to Owlkettle!

### *Best Practices*
When wrapping GTK widgets, keep in mind the best practices and coding conventions of Owlkettle as defined by [CONTRIBUTING.md](https://can-lehmann.github.io/owlkettle/CONTRIBUTING.md).
As a piece of general advice, prefer to stick as close to the original GTK widget as possible.

### *Find the GTK widget docs*
First find the docs belonging to the GTK widget so you know what it can do and what you need to wrap.
Generally searches on the [General GTK docs](https://docs.gtk.org/gtk4/) or a web search with `GTK widget docs <widgetname>` should do it.

### *Setup*
Next let us create the type for the Widget and an example application for it.

Go to `owlkettle/widgets.nim` and add your type as `renderable <GtkWidgetName> of BaseWidget: discard`.
If your Widget shows in the GTKDocs that it inherits from another Widget that was already wrapped (e.g. `Window`) it is strongly encouraged to inherit in nim from that instead.
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
        title = "<GTKWidgetName> Example"
        defaultSize = (400, 200)
        Box(orient = OrientX, spacing = 6, margin = 12):
          Label(text = "REPLACE THIS LABEL WIDGET WITH YOUR NEW WIDGET")

  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText: """
### *Wrap GTK functions*
Now we can look over the GTK docs we found earlier and look for the GTK functions needed.

Add them to GTK.nim to the section for their class, marked by comments of `# GTK.<ClassName>`.
If no such section for a GTK widget exists, add a new one. 
You will need to wrap, at minimum, the constructor for the new widget.

Keep the following things in mind:
  - If a function parameter in the docs inherits from `GtkWidget`, then use `GtkWidget` for the type
  - Use the nim equivalent for any C-type in the docs: `cbool` for `bool`, `cfloat` for `float`, `cdouble` for `double` etc.
  - If the docs of a function mention that the caller needs to free the memory of the return value, then use a managed type for the return-type such as `OwnedGtkString` for cstrings (see e.g. `g_file_get_path`)

For examples of constructor functions, look for procs with the `_new` suffix in [GTK.nim](https://github.com/can-lehmann/owlkettle/blob/main/owlkettle/gtk.nim).

### *Add Initialization to the Widget*
Next we need to tell Owlkettle create the GTK widget during the construction of the Owlkettle widget.
This is done as part of Owlkettle's `beforeBuild` hook.

Add a `beforeBuild` hook to the widget type in `widgets.nim`.
All it needs to do is call the constructor for your widget and assign the created `GtkWidget` to `state.internalWidget`.
If the constructor requires parameters, add fields with their values to your Widget and access the values from the implicitly available `widget` variable and its `val/has<Fieldname>` fields. 

For examples, see the [beforeBuild docs](https://can-lehmann.github.io/owlkettle/book/internals/hooks/before_build_hook.html) or search for `beforeBuild:` in [widgets.nim](https://github.com/can-lehmann/owlkettle/blob/main/owlkettle/widgets.nim).

### *See your example in action!*
Once you're at this step you should be able to compile your example and see your widget in action!
Run it with `nim r --path:. ./examples/path/to/your/example.nim` from the base dir of your Owlkettle repository clone.

Use your example to manually test your widget as you add features to it in the later section.

Remember to add signal-handler procs with bodies to the example, once you have added signal event listeners.
That way you can see your application react more to various inputs.

For a short example, look at Owlkettle's [counter-example](https://github.com/can-lehmann/owlkettle/blob/main/examples/counter.nim).


### *Add fields to the Widget*
Beyond just creating the widget and providing event-listeners, GTK may provide options to further customize a widget.

E.g. you may be able to show or hide values, change their positioning, enable or disable them etc. by updating certain fields at runtime after the widget was constructed.

Take a look at the procs of your widget (and the procs of its parent classes) in the GTK docs, specifically anything that isn't a getter.
If there's procs to add or set a property of the widget, try to add that feature to your wrapped widget.

At minimum, try to wrap all features exposed by your widget directly and possibly its direct parent (e.g. for `Gtk.Scale` everything from there as well as its parent `Gtk.Range`)

Follow and repeat the following steps to add a feature:
- Wrap the GTK functions as explained in earlier sections
- Add a field to your widget for every parameter required by the wrapped GTK functions.
  If a field already exists because you use it during initialization with the constructor, then you don't need to add a new field.
- Add a `property` hook for every field on your widget that you have a wrapped GTK function for.
  The hook should do nothing but call the wrapped GTK function with values from the implicitly available `state` variable.
- Run your example application to test whether the added feature does or does not work.


### *Add Signal Event Listeners*
Now we can enable the Owlkettle widget to react to GTK signals!
Note that this section is irrelevant for a given Widget if the Widget or its parent do not provide any Signals.

##### 1) Add the proc signature of signal-handler procs under the widget fields. 
First we need to define what shall get executed when a signal gets fired. 
What shall get executed are signal-handler procs, which are user-defined callback functions.

To enable defining a signal-handler, simply define the signature of said signal-handler procs.
These procs should never have a return-type.
Also try to name the signal-handler proc like the GTK signal, for easier searchability in the GTK docs.

For examples of signatures for signal-handler procs, go to [widgets.nim](https://github.com/can-lehmann/owlkettle/blob/main/owlkettle/widgets.nim) and look for proc signatures in between widget fields and hook definitions.

##### 2) Add a `connectEvents` hook to the widget type in `widgets.nim`
When the Owlkettle widget gets created, it needs to register its signal-handler procs with the GTK widget.
Only then can GTK trigger their execution whenever it fires a signal corresponding to those handler procs.

For this, add the `connectEvents` hook and in it, call the provided `connect` proc: `state.connect(state.<procName>, "<signalName>", <eventCallback>)`
Where:
  - `<procName>` is the name of the signal-handler proc
  - `<signalName>` is the name of the GTK signal
  - `<eventCallback>` is a proc that connects the signal-handler to the signal and updates the internal state if necessary. 

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
When the Owlkettle widget gets destroyed, it also needs to fully disconnect its signal-handler procs in order to avoid memory leaks.

For this, add the `disconnectEvents` hook and in it, call the provided `disconnect` proc: `state.internalWidget.disconnect(state.<procName>)`

### *Add and update documentation*
Once you are satisfied with your widget, it's time to add a bit more documentation.

##### 1) Add documentation and examples
Add doc comments to properties and event callbacks to explain what they do.

Further you can add examples using Owlkettle's `example` macro to demonstrate usage of the widget.
These will get automatically added to widget.ms in the next step

For examples that use the `example` macro, use the existing widgets in [widgets.nim](https://github.com/can-lehmann/owlkettle/blob/main/owlkettle/widgets.nim) as a guide.


##### 2) Update widgets.md and examples/README.md
Once that is done, run `nimble genDocs` to add your new widgets, doc comments, and examples to widgets.md, the main documentation file for widgets. 
Once finished, commit the updated widgets.md.

Next take a screenshot of your example application and add it to `docs/assets/examples`.
Note that the Screenshot should be:
  - Of the application in light theme
  - Against a white background
  - Taken at 200% resolution (settable in e.g. Gnome under Gnome Settings -> Displays)
  
Lastly, add an entry for your new widget to the widgets table of `examples/README.md` like so (Remember to replace the `<Widgetname>`, `<WidgetExample>` and `<WidgetExampleImage>` placeholders):
```html
    <tr>
    <td>
      <a href="https://github.com/can-lehmann/owlkettle/blob/main/examples/widgets/<WidgetExample>.nim">
        <WidgetName>
      </a>
    </td>
    <td><img alt="<WidgetName>" src="../docs/assets/examples/<WidgetExampleImage>.png" width="757px"></td>
```

With all of that out of the way, you can now open up a pull request to the Owlkettle main repo!
"""

nbSave