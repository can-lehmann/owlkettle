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
  maxSidebarWidth: float = 300.0
  minSidebarWidth: float = 250.0
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
    AdwWindow:
      defaultSize = (600, 400)

      OverlaySplitView:
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
        
        proc toggle(shown: bool) =
          echo shown
          app.showSidebar = shown
        
        Box:
          orient = OrientY
          
          AdwHeaderBar {.expand: false.}:
            style = HeaderBarFlat
            
            insert(app.toAutoFormMenu(sizeRequest = (400, 500))){.addRight.}
            
            Button {.addLeft.}:
              icon = "sidebar-show-symbolic"
              style = ButtonFlat
              
              proc clicked() =
                app.showSidebar = not app.showSidebar
          
          Label:
            text = "Content"
            style = LabelTitle2
        
        Box {.addSidebar.}:
          orient = OrientY
          spacing = 4
          
          AdwHeaderBar {.expand: false.}:
            style = HeaderBarFlat
            
            WindowTitle {.addTitle.}:
              title = "Overlay Split View Example"
          
          Label:
            text = "Sidebar"
            style = LabelTitle2

adw.brew(gui(App()))
