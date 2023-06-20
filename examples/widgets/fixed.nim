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
# SOFTWARE

import std/random
import owlkettle, owlkettle/[adw, dataentries]

type FixedItem = ref object
  name: string
  x: float
  y: float

viewable FixedItemView:
  item: FixedItem
  
  proc remove()

method view(view: FixedItemViewState): Widget =
  let item = view.item
  result = gui:
    Box:
      style = [StyleClass("card")]
      orient = OrientY
      
      Box:
        orient = OrientY
        margin = 12
        spacing = 6
        
        Box:
          orient = OrientX
          
          Label:
            text = item.name
            xAlign = 0
          
          Button {.expand: false.}:
            icon = "window-close"
            style = [ButtonFlat]
            
            proc clicked() =
              if not view.remove.isNil:
                view.remove.callback()
        
        SpinButton:
          value = item.x
          min = -100
          max = 1000
          digits = 0
          stepIncrement = 1
          pageIncrement = 10
          
          proc valueChanged(value: float) =
            item.x = value
        
        SpinButton:
          value = item.y
          min = -100
          max = 1000
          digits = 0
          stepIncrement = 1
          pageIncrement = 10
          
          proc valueChanged(value: float) =
            item.y = value
        

viewable App:
  items: seq[FixedItem]

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Fixed Example"
      
      HeaderBar {.addTitlebar.}:
        Button {.addLeft.}:
          icon = "list-add-symbolic"
          style = [ButtonFlat]
          
          proc clicked() =
            app.items.add(FixedItem(
              name: "Item " & $app.items.len,
              x: float(rand(0..400)),
              y: float(rand(0..400))
            ))
      
      Fixed:
        for it, item in app.items:
          FixedItemView {.x: item.x, y: item.y.}:
            item = item
            
            proc remove() =
              app.items.delete(it)

adw.brew(gui(App()))
