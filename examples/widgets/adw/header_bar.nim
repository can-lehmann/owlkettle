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
  centeringPolicy: CenteringPolicy = CenteringPolicyLoose
  leftButtons: seq[WindowControlButton] = @[WindowControlMenu, WindowControlMinimize, WindowControlMaximize]
  rightButtons: seq[WindowControlButton] = @[WindowControlClose, WindowControlIcon]
  showRightButtons: bool = true
  showLeftButtons: bool = true
  showBackButton: bool = true
  showTitle: bool = true
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)

method view(app: AppState): Widget =
  result = gui:
    Window():
      title = "AdwHeaderBar Example"
      defaultSize = (600, 100)
      iconName = "go-home-symbolic" # Used by WindowControlIcon
      
      AdwHeaderBar() {.addTitlebar.}:
        centeringPolicy = app.centeringPolicy
        leftButtons = app.leftButtons
        rightButtons = app.rightButtons
        showLeftButtons = app.showLeftButtons
        showRightButtons = app.showRightButtons
        showBackButton = app.showBackButton
        showTitle = app.showTitle
        sensitive = app.sensitive
        tooltip = app.tooltip
        sizeRequest = app.sizeRequest
        
        insert(app.toAutoFormMenu(sizeRequest = (400, 400))) {.addRight.}
        
        Button(text = "1") {.addRight.}:
          style = [ButtonFlat]
          proc clicked() = echo "Clicked 1"
          
        Button(text = "2") {.addLeft.}:
          style = [ButtonFlat]
          proc clicked() = echo "Clicked 2"
        
        
        Box() {.addTitle.}:
          Label(text = "Title Widget")
          Icon(name="go-home-symbolic") {.expand: false.}
adw.brew(gui(App()))