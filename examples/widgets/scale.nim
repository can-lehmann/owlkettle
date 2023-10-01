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
import owlkettle/[dataentries, adw]
import std/[json, options]

proc `%`(t: ScaleMark): JsonNode =
  result = newJObject()
  result.add("label", %t.label)
  result.add("value", %t.value)
  result.add("position", %t.position)

viewable App:
  min: float = 0
  max: float = 100            
  value: float = 50          
  marks: seq[ScaleMark] = @[] 
  inverted: bool = false      
  showValue: bool = true      
  stepSize: float = 5         
  pageSize: float = 10        
  orient: Orient = OrientX    
  showFillLevel: bool = true  
  precision: int64 = 1        
  valuePosition: ScalePosition
  
method view(app: AppState): Widget =
  result = gui:
    Window:              
      title = "Scale Example"
      defaultSize = (600, 100)
      Box(orient = OrientY, spacing = 6, margin = 12):
        Scale:
          min = app.min
          max = app.max
          value = app.value
          marks = app.marks
          inverted = app.inverted
          showValue = app.showValue
          stepSize = app.stepSize
          pageSize = app.pageSize
          orient = app.orient
          showFillLevel = app.showFillLevel
          precision = app.precision
          
          proc valueChanged(newValue: float64) =
            app.value = newValue
            echo "New value from Scale is ", $newValue
        
        Box(orient = OrientY, spacing = 6, margin = 12):
          Label(text = "Widget Fields")
          ActionRow:
            title = "min"
            NumberEntry {.addSuffix.}:
              value = app.min
              proc changed(value: float) =
                app.min = value
                
          ActionRow:
            title = "max"
            NumberEntry {.addSuffix.}:
              value = app.max
              proc changed(value: float) =
                app.max = value
          
          ActionRow:
            title = "value"
            NumberEntry {.addSuffix.}:
              value = app.value
              proc changed(value: float) =
                app.value = value
                  
          ActionRow:
            title = "inverted"
            Switch {.addSuffix.}:
              state = app.inverted
              proc changed(state: bool) =
                app.inverted = state
          
          ActionRow:
            title = "showValue"
            Switch {.addSuffix.}:
              state = app.showValue
              proc changed(state: bool) =
                app.showValue = state
          
          ActionRow:
            title = "stepSize"
            NumberEntry {.addSuffix.}:
              value = app.stepSize
              proc changed(value: float) =
                app.stepSize = value 
          
          ActionRow:
            title = "pageSize"
            NumberEntry {.addSuffix.}:
              value = app.pageSize
              proc changed(value: float) =
                app.pageSize = value
          
          ActionRow:
            title = "showFillLevel"
            Switch {.addSuffix.}:
              state = app.showFillLevel
              proc changed(state: bool) =
                app.showFillLevel = state
          
          ActionRow:
            title = "precision"
            NumberEntry {.addSuffix.}:
              value = app.precision.float
              proc changed(value: float) =
                app.precision = value.int

owlkettle.brew(gui(App()))
