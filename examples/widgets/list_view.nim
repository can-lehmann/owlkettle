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

import std/[sets, sequtils]
import owlkettle, owlkettle/[adw, playground]

viewable App:
  size: int = 1000
  selected: HashSet[int]
  
  selectionMode: SelectionMode
  showSeparators: bool = false
  singleClickActivate: bool = false
  enableRubberband: bool = false

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "List View Example"
      
      HeaderBar {.addTitlebar.}:
        insert(app.toAutoFormMenu(sizeRequest = (300, 400), ignoreFields = @["selected"])) {.addRight.}
        
        Button {.addRight.}:
          icon = "go-down-symbolic"
          style = [ButtonFlat]
          
          proc clicked() =
            app.selected = toHashSet(mapIt(app.selected, it + 1))
        
        Button {.addRight.}:
          icon = "go-up-symbolic"
          style = [ButtonFlat]
          
          proc clicked() =
            app.selected = toHashSet(mapIt(app.selected, it - 1))
        
        Button {.addLeft.}:
          icon = "list-add-symbolic"
          style = [ButtonFlat]
          
          proc clicked() =
            app.size += 100
      
      ScrolledWindow:
        ListView:
          size = app.size
          
          selected = app.selected
          selectionMode = app.selectionMode
          showSeparators = app.showSeparators
          singleClickActivate = app.singleClickActivate
          enableRubberband = app.enableRubberband
          
          proc select(selected: HashSet[int]) =
            app.selected = selected
            echo selected
          
          proc activate(index: int) =
            echo "Activate ", index
          
          proc viewItem(index: int): Widget =
            result = gui:
              LevelBar:
                value = float(index mod 1000)
                min = 0
                max = 1000

adw.brew(gui(App()))
