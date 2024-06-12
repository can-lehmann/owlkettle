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
  
  hasDataset: bool = true

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "ActionBar Example"
      defaultSize = (400, 200)
      
      HeaderBar {.addTitlebar.}:
        style = [HeaderBarFlat]
        insert(app.toAutoFormMenu(ignoreFields = @["hasDataset"], sizeRequest = (400, 300))) {.addRight.}
      
      Box:
        orient = OrientY
        
        Button:
          if app.hasDataset:
            text = "Dataset"
          else:
            text = "Reset"
          
          style = [ButtonFlat]
          
          proc clicked() =
            if app.hasDataset:
              app.revealed = true
            else:
              app.hasDataset = true
        
        ActionBar {.expand: false.}:
          revealed = app.revealed
          sensitive = app.sensitive
          tooltip = app.tooltip
          sizeRequest = app.sizeRequest
          
          Label:
            text = "Delete Dataset?"
          
          Button {.addStart.}:
            icon = "process-stop-symbolic"
            
            proc clicked() = 
              echo "Keep Dataset"
              app.revealed = false
          
          Button {.addEnd.}:
            icon = "user-trash-symbolic"
            style = [ButtonDestructive]
            
            proc clicked() =
              echo "Delete Dataset"
              app.hasDataset = false
              app.revealed = false

adw.brew(gui(App()))
