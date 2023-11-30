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
  rows: int = 1000
  columns: seq[ColumnViewColumn] = @[
    initColumnViewColumn(title = "Column 1"),
    initColumnViewColumn(title = "Column 2", resizable = true),
    initColumnViewColumn(title = "Column 3", expand = true),
    initColumnViewColumn(title = "Column 4", fixedWidth = 200)
  ]
  
  selected: HashSet[int]
  
  selectionMode: SelectionMode
  showRowSeparators: bool = false
  showColumnSeparators: bool = false
  singleClickActivate: bool = false
  enableRubberband: bool = false
  reorderable: bool = false

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Column View Example"
      
      HeaderBar {.addTitlebar.}:
        insert(app.toAutoFormMenu(sizeRequest = (400, 600), ignoreFields = @["selected"])) {.addRight.}
        
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
            app.rows += 100
      
      ScrolledWindow:
        ColumnView:
          rows = app.rows
          columns = app.columns
          
          selected = app.selected
          selectionMode = app.selectionMode
          showRowSeparators = app.showRowSeparators
          showColumnSeparators = app.showColumnSeparators
          singleClickActivate = app.singleClickActivate
          enableRubberband = app.enableRubberband
          reorderable = app.reorderable
          
          proc select(selected: HashSet[int]) =
            app.selected = selected
            echo selected
          
          proc activate(index: int) =
            echo "Activate ", index
          
          proc viewItem(row, column: int): Widget =
            result = gui:
              Label:
                text = $row & ", " & $column

adw.brew(gui(App()))
