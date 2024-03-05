import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
# Application Architecture

When building applications using owlkettle, it is good practice to separate the model and view of the application.
The aim is to encapsulate and separate the application logic from the graphical user interface.
Lets look at a contrived example of using this pattern in a simple counter application.

The model implements the functionality of the application.
In this case it stores the current value of the counter and provides functions for incrementing and displaying the current value.
"""

nbCode:
  type CounterModel* = ref object
    counter: int
  
  proc increment*(model: CounterModel) =
    model.counter += 1
  
  proc `$`*(model: CounterModel): string =
    result = $model.counter
  
  proc newCounterModel*(): CounterModel =
    result = CounterModel(counter: 1)

nbText: """
The view displays the current state of the model to the user.
It is also responsible for forwarding user input to the model.
"""

nbCode:
  import owlkettle
  
  const APP_NAME = "Counter"
  
  viewable App:
    model: CounterModel = newCounterModel()
  
  method view(app: AppState): Widget =
    result = gui:
      Window:
        title = APP_NAME
        defaultSize = (200, 100)
        
        Box:
          margin = 12
          spacing = 6
          orient = OrientX
          
          Label:
            text = $app.model
          
          Button {.expand: false.}:
            text = "+"
            style = [ButtonSuggested]
            
            proc clicked() =
              app.model.increment()
  
  when not defined(owlkettleNimiDocs):
    brew(gui(App()))

nbText: """
## Using Viewables

As your application grows, you may want to separate the view into multiple components.
Let's introduce a `CounterView` viewable to encapsulate the view logic for displaying the counter.
"""

nbCode:
  viewable CounterView:
    model: CounterModel
  
  method view(view: CounterViewState): Widget =
    result = gui:
      Box:
        margin = 12
        spacing = 6
        orient = OrientX
        
        Label:
          text = $view.model
        
        Button {.expand: false.}:
          text = "+"
          style = [ButtonSuggested]
          
          proc clicked() =
            view.model.increment()

nbText: """
We can then use `CounterView` to display the counter inside the main application.
The model needs to be passed to the `CounterView`.
"""

nbCode:
  viewable CounterApp:
    model: CounterModel = newCounterModel()
  
  method view(app: CounterAppState): Widget =
    result = gui:
      Window:
        title = APP_NAME
        defaultSize = (200, 100)
        CounterView:
          model = app.model
  
  when not defined(owlkettleNimiDocs):
    brew(gui(CounterApp()))

nbText: """
## Larger Examples

Check out the [owlkettle-crud example](https://github.com/can-lehmann/owlkettle-crud) for a larger example of using the model/view architecture with owlkettle.

[Graphing](https://github.com/can-lehmann/Graphing) also uses this pattern:
The model is represented by the [`Project`](https://github.com/can-lehmann/Graphing/blob/main/src/graphing.nim#L753) type, which contains multiple `Graph` objects.
The `Project` and its individual `Graph`s are then passed to viewables such as `GraphView` for displaying them to the user.
"""

nbSave
