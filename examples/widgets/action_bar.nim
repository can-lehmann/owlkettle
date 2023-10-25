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
  revealed: bool = false
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)
  
  dummyText: string = "Some Data"

method view(app: AppState): Widget =
  result = gui:
    Window():
      title = "ActionBar Example"
      defaultSize = (400, 200)
      HeaderBar() {.addTitlebar.}:
        insert(app.toAutoFormMenu(ignoreFields = @["dummyText"], sizeRequest = (400, 300))) {.addRight.}
        
        Button(text = "Reset") {.addRight.}:
          style = [ButtonFlat]
          proc clicked() =
            app.dummyText = "Some Data"
      
      Box(orient = OrientY):
        Button(text = app.dummyText):
          style = [ButtonFlat]
          proc clicked() = app.revealed = not app.revealed
          
        Separator() {.expand: false.}
        ActionBar {.expand: false.}:
          revealed = app.revealed
          sensitive = app.sensitive
          tooltip = app.tooltip
          sizeRequest = app.sizeRequest
          
          Label(text = "Delete Dataset?")
          Button(icon = "process-stop-symbolic") {.addEnd.}:
            proc clicked() = 
              echo "Keep Dataset"
              app.revealed = false
              
          Button(icon = "user-trash-symbolic", style = [ButtonDestructive]) {.addEnd.}:
            style = [ButtonDestructive]
            proc clicked() =
              echo "Delete Dataset"
              app.dummyText = ""
              app.revealed = false
        
adw.brew(gui(App()))
