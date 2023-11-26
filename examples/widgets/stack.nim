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

type DummyPage = tuple[
  name: string, 
  title: string, 
  text: string,
  visible: bool,
  useUnderline: bool,
  needsAttention: bool,
  iconName: string
]

let stackPages: seq[DummyPage] = (1..2).mapIt((
  "Widget " & $it, 
  "Title _" & $it, 
  "I am stack page " & $it,
  true,
  true,
  false,
  ""
))

viewable App:
  hhomogenous: bool = true
  interpolateSize: bool = true
  transitionDuration: uint = 500
  transitionType: StackTransitionType = StackTransitionSlideUp
  vhomogenous: bool = true
  visibleChildName: string = "Widget 1"
  pages: seq[DummyPage] = stackPages
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)

var counter = 0
method view(app: AppState): Widget =
  echo "View run #", counter
  counter.inc
  let stack = gui:
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
      
      for page in app.pages:
        StackPage():
          name = page.name
          title = page.title
          iconName = page.iconName
          visible = page.visible
          useUnderline = page.useUnderline
          needsAttention = page.needsAttention
          
          Box():
            Label(text = page.text)

  result = gui:
    Window():
      title = "Stack Example"
      defaultSize = (800, 400)
      HeaderBar() {.addTitlebar.}:
        insert(app.toAutoFormMenu(sizeRequest = (700, 600))) {.addRight.}
      
        for page in app.pages:
          Button(text = page.name) {.addRight.}:
            style = [ButtonFlat]
            proc clicked() =
              app.visibleChildName = page.name
      
      Box(orient = OrientY):
        Label(text = app.pages[0].repr) {.expand: false.}
        Label(text = app.pages[1].repr) {.expand: false.}
          
        StackSidebar():
          insert(stack)
        
        insert(stack)
        
        

adw.brew(gui(App()))
