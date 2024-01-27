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

import owlkettle, owlkettle/[adw, playground]

viewable App:
  label: string = "A String Label"
  expanded: bool = false
  resizeToplevel: bool = false
  useMarkup: bool = false
  useUnderline: bool = false
  sensitive: bool = true
  sizeRequest: tuple[x, y: int] = (-1, -1) 
  tooltip: string = "" 

method view(app: AppState): Widget =
  result = gui:
    Window():
      defaultSize = (450, 250)
      title = "Expander Example"
      
      HeaderBar {.addTitlebar.}:
        style = [HeaderBarFlat]
        insert(app.toAutoFormMenu(sizeRequest = (400, 520))) {.addRight.}
      
      Box:
        orient = OrientY
        spacing = 6
        margin = 12
        
        Expander {.expand: false.}:
          label = app.label
          resizeTopLevel = app.resizeTopLevel
          useMarkup = app.useMarkup
          useUnderline = app.useUnderline
          sensitive = app.sensitive
          sizeRequest = app.sizeRequest
          tooltip = app.tooltip
          
          expanded = app.expanded
          
          proc activate(activated: bool) =
            app.expanded = activated
          
          Label:
            text = "I am a child widget inserted into the Expander"
        
        Expander {.expand: false.}:
          Label {.addLabel.}:
            text = "A Widget Label"
          
          Label:
            text = "I am a child widget inserted into the Expander"
  
adw.brew(gui(App()))
