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
  label: string = "_Button Text"
  iconName: string = "go-home-symbolic"
  useUnderline: bool = true
  canShrink: bool = true

method view(app: AppState): Widget =
  result = gui:
    Window:
      defaultSize = (500, 150)
      title = "ButtonContent Example"
      
      HeaderBar {.addTitlebar.}:
        insert(app.toAutoFormMenu(sizeRequest = (400, 250))) {.addRight.}
      
      Box:
        orient = OrientY
        margin = 12
        spacing = 6
        
        Button {.hAlign: AlignCenter, vAlign: AlignCenter.}:
          ButtonContent:
            label = app.label
            iconName = app.iconName
            useUnderline = app.useUnderline
            canShrink = app.canShrink
          
          proc clicked() =
            echo "Button clicked"
        
        Label {.expand: false.}:
          text = "Press Alt + B to activate the Button!"

adw.brew(gui(App()))
