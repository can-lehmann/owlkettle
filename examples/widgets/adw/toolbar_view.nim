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

import owlkettle, owlkettle/[playground, adw]

viewable App:
  bottomBarStyle: ToolbarStyle = ToolbarFlat
  extendContentToBottomEdge: bool = false
  extendContentToTopEdge: bool = false
  revealBottomBars: bool = true
  revealTopBars: bool = true
  topBarStyle: ToolbarStyle = ToolbarFlat
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)

method view(app: AppState): Widget =
  result = gui:
    Window():
      defaultSize = (800, 600)
      title = "Toolbar View Example"
      HeaderBar {.addTitlebar.}:
        insert(app.toAutoFormMenu(sizeRequest = (400, 250))){.addRight.}

      ToolbarView():
        bottomBarStyle = app.bottomBarStyle
        extendContentToBottomEdge = app.extendContentToBottomEdge
        extendContentToTopEdge = app.extendContentToTopEdge
        revealBottomBars = app.revealBottomBars
        revealTopBars = app.revealTopBars
        topBarStyle = app.topBarStyle
        sensitive = app.sensitive
        tooltip = app.tooltip
        sizeRequest = app.sizeRequest
        
        Box():
          Label(text = "I am a child of a Toolbar View")
          Icon(name = "face-cool-symbolic")
        
        ActionBar() {.addTop.}:
          revealed = true
          Label(text = "Top bar")
          Button(text = "Toggle Top") {.addStart.}:
            proc clicked() =
              app.revealTopBars = not app.revealTopBars
          
          Button(text = "Toggle Bottom"){.addEnd.}:
            proc clicked() =
              app.revealBottomBars = not app.revealBottomBars
        
        ActionBar() {.addBottom.}:
          revealed = true
          Label(text = "Bottom Bar")
          Button(text = "Toggle Bottom") {.addStart.}:
            proc clicked() =
              app.revealBottomBars = not app.revealBottomBars
          
          Button(text = "Toggle Top"){.addEnd.}:
            proc clicked() =
              app.revealTopBars = not app.revealTopBars
              

adw.brew(gui(App()))
