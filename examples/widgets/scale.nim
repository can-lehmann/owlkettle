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

import std/[options, sequtils, json]
import owlkettle, owlkettle/[dataentries, widgetUtils, autoform, adw]

# proc toFormField(state: auto, fieldName: static string, typ: typedesc[seq[ScaleMark]]): Widget =
#   return gui:
#     ExpanderRow:
#       title = fieldName
      
#       for index, mark in state.marks:
#         ActionRow {.addRow.}:
#           title = fieldName & $index
          
#           NumberEntry {.addSuffix.}:
#             value = mark.value
#             xAlign = 1.0
#             maxWidth = 8
#             proc changed(value: float) =
#               state.marks[index].value = value
          
#           DropDown {.addSuffix.}:
#             items = ScalePosition.items.toSeq().mapIt($it)
#             selected = mark.position.int
#             proc select(enumIndex: int) =
#               state.marks[index].position = enumIndex.ScalePosition
              
#           Button {.addSuffix.}:
#             icon = "user-trash-symbolic"
#             proc clicked() =
#               state.marks.delete(index)
      
#       ListBoxRow {.addRow.}:
#         Button:
#           icon = "list-add-symbolic"
#           style = [ButtonFlat]
#           proc clicked() =
#             state.marks.add(ScaleMark())


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
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)

method view(app: AppState): Widget =
  result = gui:
    WindowSurface:
      defaultSize = (800, 600)
      
      Box(orient = OrientX):
        insert app.toAutoForm()
        
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
            sensitive = app.sensitive
            tooltip = app.tooltip
            sizeRequest = app.sizeRequest
            
            proc valueChanged(newValue: float64) =
              app.value = newValue
              echo "New value from Scale is ", $newValue

adw.brew(gui(App()))