import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """
## **Hooks**

Hooks allow you to execute code at different points throughout a widget's lifecycle, or when an action on one of its fields occurs.

Most hooks are defined only for Widgets, some are defined for both and `property` is only available as a hook for fields.

The available hooks are:

|Hook Type | For renderables | For viewables | Name | Description|
|---|---|---|---|---|
|W | Yes | Yes  | BeforeBuild | Executed only once before the `WidgetState` is created.|
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
"""
nbSave
