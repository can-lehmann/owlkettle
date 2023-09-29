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

import owlkettle
import std/options

viewable App:
  value: float64 = 100.0
  orient: Orient = OrientX

method view(app: AppState): Widget =
  result = gui:
    Window:
      HeaderBar {.addTitlebar.}:  
        Button {.addRight.}:
          text = "Flip it"
          icon = "object-flip-horizontal-symbolic"
          proc clicked() =
            app.orient = case app.orient
              of OrientX: OrientY
              of OrientY: OrientX
              
      title = "Scale Example"
      defaultSize = (600, 100)
      Box(orient = OrientX, spacing = 6, margin = 12):
        Scale:
          value = app.value
          showFillLevel = true
          precision = 0
          orient = app.orient
          marks = @[
            (some("top position"), 25.0, ScaleTop),
            (some("bottom position"), 75.0, ScaleBottom),
          ]
          
          proc valueChanged(newValue: float64) =
            app.value = newValue
            echo "New value from Scale is ", $newValue
        
brew(gui(App()))
