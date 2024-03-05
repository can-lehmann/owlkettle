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

import owlkettle, owlkettle/[dataentries, playground, adw]

viewable App:
  fileName: string
  mediaStream: MediaStream
  autoplay: bool = false
  loop: bool = false
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)

method view(app: AppState): Widget =
  const seekTime = 5 * 1000000
  
  result = gui:
    Window():
      defaultSize = (1000, 600)
      title = "Video Example"
      
      HeaderBar() {.addTitlebar.}:
        WindowTitle {.addTitle.}:
          title = "Video Example"
          subtitle = app.filename
        
        insert(app.toAutoFormMenu(
          ignoreFields = @["mediaStream", "fileName"],
          sizeRequest = (400, 400)
        )) {.addRight.}
        
        MenuButton {.addRight.}:
          icon = "view-more-symbolic"
          style = [ButtonFlat]
          sensitive = not app.mediaStream.isNil
          
          PopoverMenu:
            MediaControls:
              margin = 10
              sizeRequest = (300, -1)
              mediaStream = app.mediaStream
        
        Button {.addRight.}:
          icon = "media-seek-forward-symbolic"
          style = [ButtonFlat]
          sensitive = not app.mediaStream.isNil
          proc clicked() =
            app.mediaStream.seekRelative(seekTime)
        
        Button {.addRight.}:
          icon = "media-playback-pause"
          style = [ButtonFlat]
          sensitive = not app.mediaStream.isNil
          proc clicked() =
            app.mediaStream.pause()
        
        Button {.addRight.}:
          icon = "media-playback-start"
          style = [ButtonFlat]
          sensitive = not app.mediaStream.isNil
          proc clicked() =
            app.mediaStream.play()

        Button {.addRight.}:
          icon = "media-seek-backward-symbolic"
          style = [ButtonFlat]
          sensitive = not app.mediaStream.isNil
          proc clicked() =
            app.mediaStream.seekRelative(-seekTime)
        
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
                
                DialogButton {.addButton.}:
                  text = "Open"
                  res = DialogAccept
                  style = [ButtonSuggested]
            
            if res.kind == DialogAccept:
              let path = FileChooserDialogState(state).filenames[0]
              app.filename = path
              try:
                app.mediaStream = newMediaStream(path)
              except IoError as err:
                echo err.msg
                app.mediaStream = nil
          
        Button {.addLeft.}:
          text = "Reset"
          style = [ButtonFlat]
          
          proc clicked() =
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
