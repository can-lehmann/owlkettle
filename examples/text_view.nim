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
  buffer: TextBuffer

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Text View Example"
      
      HeaderBar {.addTitlebar.}:
        Button {.addLeft.}:
          text = "Set Text"
          proc clicked() =
            app.buffer.text = "Hello, world!\n"
        
        Button {.addLeft.}:
          text = "Get Text"
          proc clicked() =
            if app.buffer.hasSelection:
              echo app.buffer.text(app.buffer.selection)
            else:
              echo app.buffer.text
        
        Button {.addLeft.}:
          text = "Insert"
          proc clicked() =
            app.buffer.insert(app.buffer.selection.a, "Hello, world!")
        
        Button {.addLeft.}:
          text = "Delete"
          proc clicked() =
            app.buffer.delete(app.buffer.selection)
      
      ScrolledWindow:
        TextView:
          buffer = app.buffer
          proc changed() = discard

brew(gui(App(buffer = newTextBuffer())))
