# MIT License
# 
# Copyright (c) 2023 Can Joshua Lehmann
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

import owlkettle, owlkettle/[adw, autoform]

viewable App:
  options: seq[string] = @["Option 0", "Option 1", "Option 2"]
  selected: int = 1
  sensitive: bool = true
  sizeRequest: tuple[x, y: int] = (-1, -1) 
  tooltip: string = "" 
  spacing: int = 3 
  rowSpacing: int = 6 
  orient: Orient = OrientY 

method view(app: AppState): Widget =
  result = gui:
    Window:
      defaultSize = (800, 600)
      
      Box(orient = OrientY):
        HeaderBar {.expand: false.}:
          WindowTitle {.addTitle.}:
            title = "Radio Group Example"
            if app.selected in 0..<app.options.len:
              subtitle = app.options[app.selected]
            else:
              subtitle = "Invalid Item"
            
          insert(app.toAutoFormMenu(ignoreFields = @["pixbuf", "loading"], sizeRequest = (500, 520))) {.addRight.}

        Box:
          orient = OrientY
          margin = 12
          
          RadioGroup {.expand: false.}:
            selected = app.selected
            sensitive = app.sensitive
            sizeRequest = app.sizeRequest
            tooltip = app.tooltip
            spacing = app.spacing
            rowSpacing = app.rowSpacing
            orient = app.orient
            
            proc select(index: int) =
              app.selected = index
            
            for option in app.options:
              Label:
                text = option
                xAlign = 0


adw.brew(gui(App()))
