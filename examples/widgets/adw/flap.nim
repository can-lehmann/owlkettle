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

import std/[strutils, sets]
import owlkettle, owlkettle/adw

viewable App:
  showFlap: bool = true
  folded: bool = false
  page: int = 0

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Flap Example"
      defaultSize = (500, 300)
      
      HeaderBar {.addTitlebar.}:
        ToggleButton {.addLeft.}:
          text = "Sidebar"
          state = app.showFlap
          proc changed(state: bool) =
            app.showFlap = state
      
      Flap:
        revealed = app.showFlap
        transitionType = FlapTransitionOver
        
        proc changed(revealed: bool) =
          app.showFlap = revealed
        
        proc fold(folded: bool) =
          app.folded = folded
        
        ScrolledWindow {.addFlap, width: 200.}:
          ListBox:
            selectionMode = SelectionSingle
            selected = toHashSet([app.page])
            style = [ListBoxNavigationSidebar]
            
            proc select(pages: HashSet[int]) =
              for page in pages:
                app.page = page
                if app.folded:
                  app.showFlap = false
            
            for it in 0..<3:
              Label:
                text = "Page " & $it
                xAlign = 0.0
        
        Separator() {.addSeparator.}
        
        Box:
          Label:
            text = repeat("Page " & $app.page & " ", 5)
            wrap = true

adw.brew(gui(App()))
