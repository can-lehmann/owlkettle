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

import std/[sequtils]
import owlkettle, owlkettle/[dataentries, playground, adw]

viewable App:
  hhomogenous: bool = true
  interpolateSize: bool = true
  transitionDuration: uint = 500
  transitionType: StackTransitionType = StackTransitionSlideUp
  vhomogenous: bool = true
  visibleChildName: string = "Widget 1"
  labelChildren: seq[tuple[name: string, title: string, text: string]] = (1..3).mapIt(("Widget " & $it, "Title " & $it, "I am stack page " & $it))
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)

method view(app: AppState): Widget =
  result = gui:
    Window():
      title = "Stack Example"
      defaultSize = (800, 400)
      HeaderBar() {.addTitlebar.}:
        insert(app.toAutoFormMenu(sizeRequest = (700, 600))) {.addRight.}
      
        for labelChild in app.labelChildren:
          Button(text = labelChild.name) {.addRight.}:
            style = [ButtonFlat]
            proc clicked() =
              app.visibleChildName = labelChild.name
        
      Stack():
        hhomogenous = app.hhomogenous
        interpolateSize = app.interpolateSize
        transitionDuration = app.transitionDuration
        transitionType = app.transitionType
        vhomogenous = app.vhomogenous
        visibleChildName = app.visibleChildName
        sensitive = app.sensitive
        tooltip = app.tooltip
        sizeRequest = app.sizeRequest
        
        for labelChild in app.labelChildren:
          Label(text = labelChild.text) {.name: labelChild.name, title: labelChild.title.}

adw.brew(gui(App()))
