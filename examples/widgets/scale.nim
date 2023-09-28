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
  invertScale: bool = false

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Scale"
      defaultSize = (600, 400)
      Box(orient = OrientX, spacing = 6, margin = 12):
        Scale:
          value = app.value
          inverted = app.invertScale
          showFillLevel = true
          marks = @[
            (some "left", 25, ScaleMarkLeft),
            (some "right", 50, ScaleMarkRight),
            (some "top", 75, ScaleMarkTop),
            (some "bottom", 100, ScaleMarkBottom),
          ]
          proc valueChanged(newValue: float64) =
            echo "New value from Scale is ", $newValue
        
        Button:
          proc clicked() =
            app.invertScale = not app.invertScale
            
            echo "\nclicked button. New Values: ", app.value, " - ", app.invertScale

brew(gui(App()))
