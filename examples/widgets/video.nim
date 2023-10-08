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

import std/[sequtils, os]
import owlkettle, owlkettle/[dataentries, playground, gtk, adw]


viewable App:
  mediaStream: MediaStream
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
        insert(app.toAutoFormMenu(ignoreFields = @["mediaStream"], sizeRequest = (400, 400))) {.addRight.}
      
        Button {.addLeft.}:
          text = "Open"
          style = [ButtonSuggested]
          
          proc clicked() =
            let (res, state) = app.open: gui:
              FileChooserDialog:
                action = FileChooserOpen
                
                DialogButton {.addButton.}:
                  text = "Cancel"
                  res = DialogCancel
                  style = [ButtonSuggested]
                
                DialogButton {.addButton.}:
                  text = "Open"
                  res = DialogAccept
                  style = [ButtonSuggested]
            
            if res.kind == DialogAccept:
              let path = FileChooserDialogState(state).filename
              
              # Load sync
              try:
                app.mediaStream = newMediaStream(path)
              except IoError as err:
                echo err.msg
                app.mediaStream = nil
        
      Box(orient = OrientY):
        Label(text = "Video via FileName") {.expand: false.}
        if not app.mediaStream.isNil():
          Video:
            mediaStream = app.mediaStream
            autoplay = app.autoplay
            loop = app.loop
            sensitive = app.sensitive
            tooltip = app.tooltip
            sizeRequest = app.sizeRequest
        else:
          Label(text = "No file selected")
adw.brew(gui(App()))
