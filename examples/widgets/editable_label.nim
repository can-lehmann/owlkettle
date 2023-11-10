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

import owlkettle, owlkettle/[dataentries, playground, adw]

viewable App:
  editing: bool = false
  text: string = "Initial Text"
  enableUndo: bool = true
  alignment: 0.0..1.0 = 0.0
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)

method view(app: AppState): Widget =
  result = gui:
    Window():
      title = "Editable Label Example"
      defaultSize = (400, 100)
      HeaderBar() {.addTitlebar.}:
        insert(app.toAutoFormMenu()) {.addRight.}
      
      Box(orient = OrientY, margin = 12, spacing = 6):
        Label(text = "The editable label:") {.expand: false.}
        EditableLabel {.expand: false.}:
          text = app.text
          editing = app.editing
          enableUndo = app.enableUndo
          alignment = app.alignment
          sensitive = app.sensitive
          tooltip = app.tooltip
          sizeRequest = app.sizeRequest
          
          proc changed(newValue: string) =
            app.text = newValue
            echo "New Value: ", $newValue
          
          proc editStateChanged(newEditState: bool) =
            app.editing = newEditState
            echo "New Edit State: ", newEditState

adw.brew(gui(App()))
