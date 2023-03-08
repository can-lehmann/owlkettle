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
# SOFTWARE

import std/sequtils
import owlkettle

type TodoItem = object
  text: string
  done: bool

viewable App:
  todos: seq[TodoItem]
  newItem: string

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Todo"
      defaultSize = (400, 250)
      
      HeaderBar {.addTitlebar.}:  
        MenuButton {.addRight.}:
          icon = "open-menu-symbolic"
          Popover:
            Box(orient=OrientY, spacing=6, margin=6):
              Button:
                icon = "user-trash-symbolic"
                style = [ButtonDestructive]
                proc clicked() =
                  app.todos = app.todos.filterIt(not it.done)
      
      Box(orient = OrientY, spacing = 6, margin = 12):
        Box(orient = OrientX, spacing = 6) {.expand: false.}:
          Entry:
            text = app.newItem
            proc changed(newItem: string) =
              app.newItem = newItem
            proc activate() =
              app.todos.add(TodoItem(text: app.newItem))
              app.newItem = ""
          Button {.expand: false.}:
            icon = "list-add-symbolic"
            style = [ButtonSuggested]
            proc clicked() =
              app.todos.add(TodoItem(text: app.newItem))
              app.newItem = ""
        
        Frame:
          ScrolledWindow:
            ListBox:
              selectionMode = SelectionNone
              for it, todo in app.todos:
                Box:
                  spacing = 6
                  CheckButton {.expand: false.}:
                    state = todo.done
                    proc changed(state: bool) =
                      app.todos[it].done = state
                  Label:
                    xAlign = 0
                    text = todo.text

brew(gui(App(todos = @[
  TodoItem(text: "First Item", done: true),
  TodoItem(text: "Second Item")
])))
