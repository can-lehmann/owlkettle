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

import std/[sequtils]
import owlkettle, owlkettle/[autoform, adw]

const APP_NAME = "Drop Down Example"

viewable App:
  selected: int = 0
  items: seq[string] = mapIt(0..<100, "Option " & $it)
  enableSearch: bool = false
  showArrow: bool = true
  sensitive: bool = true
  sizeRequest: tuple[x, y: int] = (-1, -1) 
  tooltip: string = "" 
  
method view(app: AppState): Widget =
  result = gui:
    Window:
      defaultSize = (400, 500)
      
      Box(orient = OrientY):
        HeaderBar {.expand: false.}:
          WindowTitle {.addTitle.}:
            title = "Dropdown Example"
            subtitle = "Selected: " & $app.selected & " '" & app.items[app.selected] & "'"
          
          insert(app.toAutoFormMenu(sizeRequest = (500, 470))) {.addRight.}

        DropDown {.expand: false.}:
          items = app.items
          selected = app.selected
          enableSearch = app.enableSearch
          showArrow = app.showArrow
          sensitive = app.sensitive
          tooltip = app.tooltip
          sizeRequest = app.sizeRequest
        
          proc select(item: int) =
            app.selected = item

adw.brew(gui(App()))
