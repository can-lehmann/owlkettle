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

import owlkettle

viewable App:
  discard

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Popover Menu Demo"
      defaultSize = (300, 200)
      
      HeaderBar {.addTitlebar.}:
        MenuButton {.addRight.}:
          icon = "open-menu"
          PopoverMenu:
            Box {.name: "main".}:
              orient = OrientY
              margin = 4
              spacing = 3
              
              ModelButton:
                text = "Submenu"
                menuName = "submenu"
                proc clicked() =
                  echo "Open Submenu"
              
              Separator()
              
              ModelButton:
                text = "About"
                proc clicked() =
                  echo "About Clicked"
              
              ModelButton:
                text = "Close"
                proc clicked() =
                  echo "Close Clicked"
            
            Box {.name: "submenu".}:
              orient = OrientY
              margin = 4
              spacing = 3
              
              for it in 0..<3:
                ModelButton:
                  text = "Entry " & $it
                  proc clicked() =
                    echo "Entry " & $it

brew(gui(App()))
