import nimib, nimibook
import owlkettle

type Page = enum
  PageWelcome, PageUser

viewable App:
  counter: int
  shownPage: Page
  condition: bool
  items: seq[string]

viewable UserPage: discard

let app = AppState()

nbInit(theme = useNimibook)

nbText: """
# `gui` Macro

In owlkettle, graphical user interfaces are described using the `gui` macro.
It provides a domain-specific language for specifying widget trees.

You can set fields on each widget in the widget tree.
Fields may either be set in the argument list of a widget...
"""

block:
  nbCode:
    let widget = gui:
      Label(text = "Hello, world!", xAlign = 0.0)

nbText: """
...or in the body of the widget:
"""

block:
  nbCode:
    let widget = gui:
      Label:
        text = "Hello, world!"
        xAlign = 0.0

nbText: """
Each widget may also have a series of events.
Events are triggered when the user interacts with the widget.
"""

block:
  nbCode:
    let widget = gui:
      Button:
        proc clicked() =
          app.counter += 1

nbText: """
## Control Flow

You can use `if` and `case` statements to conditionally show and hide different widgets.
"""

block:
  nbCode:
    let widget = gui:
      case app.shownPage:
        of PageWelcome:
          Label:
            text = "Welcome!"
        of PageUser:
          UserPage()

nbText: """
`if` and `case` can also be used on fields:
"""

block:
  nbCode:
    let widget = gui:
      Label:
        if app.condition:
          text = "Hello"
        else:
          text = "World"

nbText: """
`for` statements can be used to generate lists of widgets.
"""

block:
  nbCode:
    let widget = gui:
      ListBox:
        for item in app.items:
          Label(text = item)

nbText: """
## Adders

Adders specify how a widget is added to its parent.
For example, the `HeaderBar.addLeft` adder places the given widget on the left side of the header bar, while the `addRight` adder places it on the right.
Adders are specified using pragma expressions (e.g. `{.add, expand: false.}`).
Which adders are available at any place in the widget tree depends on the parent widget.
If no adder is specified, the `add` adder is used by default.

Each adder may receive a series of properties.
For example, you can use the `expand` property of the `Box.add` adder to specify whether the given child widget should expand to fill up remaining space in the box.

"""

block:
  nbCode:
    let widget = gui:
      Box:
        Label {.expand: false.}:
          text = "no expand"
        Label {.expand: true.}:
          text = "expand"

nbText: """
## `insert` Statement

The `gui` macro returns a `Widget` object.
The `insert` statement inserts a `Widget` object previously returned by another `gui` macro into the current widget tree.
It is commonly used to implement container widgets.
"""

block:
  nbCode:
    let childWidget = gui:
      Label(text = "Inserted widget")
    
    let widget = gui:
      Box:
        insert(childWidget)

nbText: """
You can also specify an adder and set properties for the inserted widget.
"""

block:
  nbCode:
    let childWidget = gui:
      Label(text = "Inserted widget")
    
    let widget = gui:
      Box:
        insert(childWidget) {.expand: false.}

nbSave
