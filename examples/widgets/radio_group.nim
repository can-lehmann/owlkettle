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

import owlkettle, owlkettle/adw

viewable App:
  options: seq[string] = @["Option 0", "Option 1"]
  selected: int = 1

method view(app: AppState): Widget =
  result = gui:
    Window:
      defaultSize = (400, 300)
      
      HeaderBar {.addTitlebar.}:
        WindowTitle {.addTitle.}:
          title = "Radio Group Example"
          if app.selected in 0..<app.options.len:
            subtitle = app.options[app.selected]
          else:
            subtitle = "Invalid Item"
        
        Button {.addLeft.}:
          icon = "list-add-symbolic"
          tooltip = "Add Option"
          style = [ButtonFlat]
          
          proc clicked() =
            app.options.add("Option " & $app.options.len)
        
        Button {.addLeft.}:
          icon = "user-trash-symbolic"
          tooltip = "Remove Last Option"
          style = [ButtonFlat]
          
          sensitive = app.options.len > 2
          
          proc clicked() =
            discard app.options.pop()
        
        Button {.addRight.}:
          icon = "go-down-symbolic"
          tooltip = "Select Next"
          style = [ButtonFlat]
          
          proc clicked() =
            app.selected += 1
        
        Button {.addRight.}:
          icon = "go-up-symbolic"
          tooltip = "Select Previous"
          style = [ButtonFlat]
          
          proc clicked() =
            app.selected -= 1
      
      ScrolledWindow:
        Box:
          orient = OrientY
          margin = 12
          
          RadioGroup {.expand: false.}:
            selected = app.selected
            
            proc select(index: int) =
              app.selected = index
            
            for option in app.options:
              Label:
                text = option
                xAlign = 0

adw.brew(gui(App()))
