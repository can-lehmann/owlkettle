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
  fileName: string
  mediaStream: MediaStream
  autoplay: bool = false
  loop: bool = false
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)

proc seek(mediaStream: MediaStream, intervalInSeconds: int) =
  let currentTimestampInMicroS: cint = gtk_media_stream_get_timestamp(mediaStream.gtk)
  let intervalInMicroS = intervalInSeconds * 1000000
  gtk_media_stream_seek(mediaStream.gtk, cint(currentTimestampInMicroS + intervalInMicroS))

method view(app: AppState): Widget =
    
  result = gui:
    Window():
      defaultSize = (1000, 600)
      title = "Video Example"
      HeaderBar() {.addTitlebar.}:
        WindowTitle {.addTitle.}:
          title = "Video Example"
          subtitle = app.filename
        insert(app.toAutoFormMenu(ignoreFields = @["mediaStream"], sizeRequest = (400, 400))) {.addRight.}
        
        Button {.addRight.}:
          icon = "media-seek-forward-symbolic"
          proc clicked() = 
            app.mediaStream.seek(5)  
        Button {.addRight.}:
          icon = "media-playback-start"
          proc clicked() = 
            gtk_media_stream_set_playing(app.mediaStream.gtk, true.cbool)
        
        Button {.addRight.}:
          icon = "media-playback-pause"
          proc clicked() = 
            gtk_media_stream_set_playing(app.mediaStream.gtk, false.cbool)
        Button {.addRight.}:
          icon = "media-seek-backward-symbolic"
          proc clicked() = 
            app.mediaStream.seek(-5)    

        
        Button {.addLeft.}:
          text = "Reset"
          style = [ButtonFlat]
          
          proc clicked() =
            app.mediaStream = nil
            
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
              app.filename = path
              # Load sync
              try:
                app.mediaStream = newMediaStream(path)
              except IoError as err:
                echo err.msg
                app.mediaStream = nil
        
      Box(orient = OrientY):
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
