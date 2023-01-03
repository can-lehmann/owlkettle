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

import std/sequtils
import owlkettle, owlkettle/adw

const APP_NAME = "Drop Down Example"

viewable App:
  selected: int = 0
  items: seq[string] = mapIt(0..<100, "Option " & $it)

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = APP_NAME
      defaultSize = (350, 200)
      
      HeaderBar {.addTitlebar.}:
        WindowTitle {.addTitle.}:
          title = APP_NAME
          subtitle = "Selected: " & $app.selected
      
      Box(orient = OrientY, spacing = 6, margin = 12):
        Box(spacing = 6) {.expand: false.}:
          Label:
            text = "Drop Down"
            xAlign = 0
          
          DropDown {.expand: false.}:
            items = app.items
            selected = app.selected
            proc select(item: int) =
              app.selected = item
        
        Box(spacing = 6) {.expand: false.}:
          Label:
            text = "Searchable Drop Down"
            xAlign = 0
          
          DropDown {.expand: false.}:
            items = app.items
            selected = app.selected
            enableSearch = true
            proc select(item: int) =
              app.selected = item

owlkettle.brew(gui(App()))
