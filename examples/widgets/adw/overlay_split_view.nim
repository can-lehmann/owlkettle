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
  collapsed: bool = false
  enableHideGesture: bool = true
  enableShowGesture: bool = true
  maxSidebarWidth: float = 280.0
  minSidebarWidth: float = 180.0
  pinSidebar: bool = false
  showSidebar: bool = true
  sidebarPosition: PackType = PackStart
  widthFraction: float = 0.25
  widthUnit: LengthUnit = LengthScaleIndependent
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)

method view(app: AppState): Widget =
  result = gui:
    Window():
      defaultSize = (800, 600)
      title = "Overlay Split View Example"
      HeaderBar {.addTitlebar.}:
        insert(app.toAutoFormMenu(sizeRequest = (400, 250))){.addRight.}

      OverlaySplitView():
        collapsed = app.collapsed
        enableHideGesture = app.enableHideGesture
        enableShowGesture = app.enableShowGesture
        maxSidebarWidth = app.maxSidebarWidth
        minSidebarWidth = app.minSidebarWidth
        pinSidebar = app.pinSidebar
        showSidebar = app.showSidebar
        sidebarPosition = app.sidebarPosition
        widthFraction = app.widthFraction
        widthUnit = app.widthUnit
        tooltip = app.tooltip
        sensitive = app.sensitive
        sizeRequest = app.sizeRequest
        
        Label(text = "I am the content of overlay Split view")
        
        Box(orient = OrientY) {.addSidebar.}:
          for num in 0..4:
            Button(text = $num)

adw.brew(gui(App()))
