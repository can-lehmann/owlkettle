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

import owlkettle, owlkettle/[dataentries, adw]
import std/[options, sequtils]

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
    WindowSurface:
      defaultSize = (800, 600)
      
      Box(orient = OrientX):
        Box(orient = OrientY) {.expand: false.}:
          sizeRequest = (300, -1)
          
          HeaderBar {.expand: false.}:
            showTitleButtons = false
          
          ScrolledWindow:
            PreferencesGroup:
              title = "Fields"
              margin = 12
              
              ActionRow:
                title = "min"
                NumberEntry {.addSuffix.}:
                  value = app.min
                  xAlign = 1.0
                  maxWidth = 8
                  proc changed(value: float) =
                    app.min = value
              
              ActionRow:
                title = "max"
                NumberEntry {.addSuffix.}:
                  value = app.max
                  xAlign = 1.0
                  maxWidth = 8
                  proc changed(value: float) =
                    app.max = value
              
              ActionRow:
                title = "value"
                NumberEntry {.addSuffix.}:
                  value = app.value
                  xAlign = 1.0
                  maxWidth = 8
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
                  xAlign = 1.0
                  maxWidth = 8
                  proc changed(value: float) =
                    app.stepSize = value 
              
              ActionRow:
                title = "pageSize"
                NumberEntry {.addSuffix.}:
                  value = app.pageSize
                  xAlign = 1.0
                  maxWidth = 8
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
                  xAlign = 1.0
                  maxWidth = 8
                  proc changed(value: float) =
                    app.precision = value.int
              
              ComboRow:
                title = "orient"
                items = mapIt(low(Orient)..high(Orient), $it)
                selected = ord(app.orient)
                proc select(index: int) =
                  app.orient = Orient(index)
              
              ComboRow:
                title = "valuePosition"
                items = mapIt(low(ScalePosition)..high(ScalePosition), $it)
                selected = ord(app.valuePosition)
                proc select(index: int) =
                  app.valuePosition = ScalePosition(index)
              
              ExpanderRow:
                title = "marks"
                
                for it, mark in app.marks:
                  ActionRow {.addRow.}:
                    title = "Mark " & $it
                    
                    NumberEntry {.addSuffix.}:
                      value = mark.value
                      xAlign = 1.0
                      maxWidth = 8
                      proc changed(value: float) =
                        app.marks[it].value = value
                    
                    Button {.addSuffix.}:
                      icon = "user-trash-symbolic"
                      proc clicked() =
                        app.marks.delete(it)
                
                ListBoxRow {.addRow.}:
                  Button:
                    icon = "list-add-symbolic"
                    style = [ButtonFlat]
                    proc clicked() =
                      app.marks.add(ScaleMark())
        
        Separator() {.expand: false.}
        
        Box(orient = OrientY):
          HeaderBar {.expand: false.}:
            WindowTitle {.addTitle.}:
              title = "Scale Example"
              subtitle = "Value: " & $app.value
          
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
            valuePosition = app.valuePosition
            
            proc valueChanged(newValue: float64) =
              app.value = newValue
              echo "New value from Scale is ", $newValue

adw.brew(gui(App()))
