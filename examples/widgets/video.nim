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
  fileName: string = "/home/philipp/Videos/Screencasts/test.webm"
  autoplay: bool = false
  loop: bool = false
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)

method view(app: AppState): Widget =
  result = gui:
    Window():
      defaultSize = (800, 600)
      title = "Video Example"
      HeaderBar() {.addTitlebar.}:
        insert(app.toAutoFormMenu()) {.addRight.}
      
      Video:
        fileName = app.fileName
        autoplay = app.autoplay
        loop = app.loop
        sensitive = app.sensitive
        tooltip = app.tooltip
        sizeRequest = app.sizeRequest
        
adw.brew(gui(App()))
