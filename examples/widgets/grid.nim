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
# SOFTWARE

import owlkettle

viewable App:
  discard

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Grid"
      
      Grid:
        spacing = 6
        margin = 12
        
        Button {.x: 1, y: 1, hExpand: true, vExpand: true.}:
          text = "(1, 1), hExpand, vExpand"
        
        Button {.x: 2, y: 1.}:
          text = "(2, 1)"
        
        Button {.x: 1, y: 2, width: 2, hAlign: AlignCenter.}:
          text = "(1-2, 2), hAlign: AlignCenter"

brew(gui(App()))
