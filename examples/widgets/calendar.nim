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

import std/[times]
import owlkettle, owlkettle/[adw, dataentries, autoform]

viewable App:
  date: DateTime = now()
  markedDays: seq[int] = @[]
  showDayNames: bool = true
  showHeading: bool = true
  showWeekNumbers: bool = true
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)

method view(app: AppState): Widget =
  result = gui:
    Window:
      defaultSize = (500, 500)
      
      Box(orient = OrientY):
        
        HeaderBar {.expand: false.}:
          WindowTitle {.addTitle.}:
            title = "Calendar Example"
            subtitle = $app.date.inZone(local())
            
          insert(app.toAutoFormMenu(sizeRequest=(550, 520))) {.addRight.}
      
          Button {.addLeft.}:
            icon = "go-previous"
            style = [ButtonFlat]
            tooltip = "Previous Day"
            
            proc clicked() =
              app.date -= 1.days
          
          Button {.addLeft.}:
            icon = "go-next"
            style = [ButtonFlat]
            tooltip = "Next Day"
            
            proc clicked() =
              app.date += 1.days
    
        Calendar:
          date = app.date
          markedDays = app.markedDays
          showDayNames = app.showDayNames
          showHeading = app.showHeading
          showWeekNumbers = app.showWeekNumbers
          sensitive = app.sensitive
          tooltip = app.tooltip
          sizeRequest = app.sizeRequest
          
          proc select(date: DateTime) =
            ## Shortcut for handling all calendar events (daySelected,
            ## nextMonth, prevMonth, nextYear, prevYear)
            app.date = date


adw.brew(gui(App()), stylesheets=[
  loadStylesheet("calendar.css")
])
