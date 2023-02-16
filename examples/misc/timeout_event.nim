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

import owlkettle

viewable App:
  timeout: EventDescriptor
  count: int

method view(app: AppState): Widget =
  proc eventHandler(): bool =
    app.count += 1
    discard app.redraw()
    result = true # Do not remove event
  
  result = gui:
    Window:
      title = "Timeout Example"
      defaultSize = (300, 100)
      
      Box:
        orient = OrientX
        margin = 12
        spacing = 6
        
        if app.timeout.isNil:
          Button:
            text = "Add Global Timeout"
            
            proc clicked() =
              app.timeout = addGlobalTimeout(1000, eventHandler)
          
          Button:
            text = "Add Global Idle"
            
            proc clicked() =
              app.timeout = addGlobalIdleTask(eventHandler)
        else:
          Button:
            text = "Remove Event"
            
            proc clicked() =
              app.timeout.remove()
              app.timeout = EventDescriptor(0)
        
        Label:
          text = $app.count


brew(gui(App()))

