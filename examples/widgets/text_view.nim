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

import std/options
import owlkettle
import owlkettle/[adw, playground]

viewable App:
  buffer: TextBuffer
  monospace: bool = false
  cursorVisible: bool = true
  editable: bool = true
  acceptsTab: bool = true
  indent: int = 0
  sensitive: bool = true
  sizeRequest: tuple[x, y: int] = (-1, -1) 
  tooltip: string = "" 

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Text View Example"
      defaultSize = (1100, 600)
      HeaderBar {.addTitlebar.}:
        Button {.addLeft.}:
          style = [ButtonFlat]
          text = "Set Text"
          proc clicked() =
            app.buffer.text = "Hello, world!\n"
        
        Button {.addLeft.}:
          style = [ButtonFlat]
          text = "Get Text"
          proc clicked() =
            if app.buffer.hasSelection:
              echo app.buffer.text(app.buffer.selection)
            else:
              echo app.buffer.text
        
        Button {.addLeft.}:
          style = [ButtonFlat]
          text = "Insert"
          proc clicked() =
            app.buffer.insert(app.buffer.selection.a, "Hello, world!")
        
        Button {.addLeft.}:
          style = [ButtonFlat]
          text = "Delete"
          proc clicked() =
            app.buffer.delete(app.buffer.selection)
        
        insert(app.toAutoFormMenu(ignoreFields = @["buffer"], sizeRequest = (300, 520))) {.addRight.}
        
        Button {.addRight.}:
          style = [ButtonFlat]
          text = "Unmark"
          proc clicked() =
            app.buffer.removeTag("marker", app.buffer.selection)
        
        Button {.addRight.}:
          style = [ButtonFlat]
          text = "Mark"
          proc clicked() =
            app.buffer.applyTag("marker", app.buffer.selection)
        
        Button {.addRight.}:
          style = [ButtonFlat]
          text = "Next Tag"
          proc clicked() =
            let tag = app.buffer.lookupTag("marker")
            var iter = app.buffer.selection.a
            while true:
              if not iter.forwardToTagToggle(tag):
                break
              if iter.startsTag(tag):
                var stop = iter
                discard stop.forwardToTagToggle(tag)
                app.buffer.select(stop, iter)
                iter = stop
                break
  
      ScrolledWindow:
        TextView:
          margin = 12
          buffer = app.buffer
          monospace = app.monospace
          cursorVisible = app.cursorVisible
          editable = app.editable
          acceptsTab = app.acceptsTab
          indent = app.indent
          sensitive = app.sensitive
          tooltip = app.tooltip
          sizeRequest = app.sizeRequest

proc main() =
  # TODO: Not using a main function causes memory management issues. Probably a Nim ARC/ORC problem.
  let buffer = newTextBuffer()
  discard buffer.registerTag("marker", TagStyle(
    background: some("#ffff77"),
    weight: some(700)
  ))
  let event = buffer.connectChanged(
    proc(isUserChange: bool) =
      echo "[", isUserChange, "] ", buffer.text
  )
  adw.brew(gui(App(buffer = buffer)))

when isMainModule:
  main()
