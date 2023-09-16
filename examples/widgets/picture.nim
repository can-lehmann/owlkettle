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

import std/[asyncfutures]
import owlkettle, owlkettle/adw

const APP_NAME = "Image Example"

viewable App:
  loading: bool
  pixbuf: Pixbuf

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = APP_NAME
      
      HeaderBar {.addTitlebar.}:
        WindowTitle {.addTitle.}:
          title = APP_NAME
          
          if app.pixbuf.isNil:
            subtitle = ""
          else:
            subtitle = $app.pixbuf.width & "x" &
                       $app.pixbuf.height & "x" &
                       $app.pixbuf.channels & " (" &
                       $app.pixbuf.bitsPerSample & "bits/sample, " &
                       (if app.pixbuf.hasAlpha: "Has Alpha" else: "No Alpha") & ")"
        
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
              
              when defined(pixbufAsync):
                # Load async
                let future = loadPixbufAsync(path)
                
                proc callback(pixbuf: Future[Pixbuf]) =
                  app.loading = false
                  app.pixbuf = pixbuf.read()
                  discard app.redraw()
                
                future.addCallback(callback)
                app.loading = true
                app.pixbuf = nil
              else:
                # Load sync
                try:
                  app.pixbuf = loadPixbuf(path)
                except IoError as err:
                  echo err.msg
                  app.pixbuf = nil
        
        Button {.addLeft.}:
          text = "Save"
          sensitive = not app.pixbuf.isNil
          
          proc clicked() =
            let (res, state) = app.open: gui:
              FileChooserDialog:
                action = FileChooserSave
                
                DialogButton {.addButton.}:
                  text = "Cancel"
                  res = DialogCancel
                  style = [ButtonSuggested]
                
                DialogButton {.addButton.}:
                  text = "Save"
                  res = DialogAccept
                  style = [ButtonSuggested]
            
            if res.kind == DialogAccept:
              try:
                let path = FileChooserDialogState(state).filename
                app.pixbuf.save(path, "png", {"tEXt::myKey": "Hello, world!"})
              except IoError as err:
                echo err.msg
        
        Button {.addRight.}:
          icon = "object-flip-horizontal-symbolic"
          sensitive = not app.pixbuf.isNil
          proc clicked() =
            app.pixbuf = app.pixbuf.flipHorizontal()
        
        Button {.addRight.}:
          icon = "object-flip-vertical-symbolic"
          sensitive = not app.pixbuf.isNil
          proc clicked() =
            app.pixbuf = app.pixbuf.flipVertical()
        
        Button {.addRight.}:
          text = "Crop"
          sensitive = not app.pixbuf.isNil
          proc clicked() =
            # Crop center
            app.pixbuf = app.pixbuf.crop(
              app.pixbuf.width div 4,
              app.pixbuf.height div 4,
              app.pixbuf.width div 2,
              app.pixbuf.height div 2
            )
        
        Button {.addRight.}:
          text = "2x"
          sensitive = not app.pixbuf.isNil
          proc clicked() =
            app.pixbuf = app.pixbuf.scale(app.pixbuf.width * 2, app.pixbuf.height * 2)
        
        Button {.addRight.}:
          icon = "object-rotate-right-symbolic"
          sensitive = not app.pixbuf.isNil
          proc clicked() =
            app.pixbuf = app.pixbuf.rotate270()
        
        Button {.addRight.}:
          icon = "object-rotate-left-symbolic"
          sensitive = not app.pixbuf.isNil
          proc clicked() =
            app.pixbuf = app.pixbuf.rotate90()
        
      
      if app.pixbuf.isNil:
        if app.loading:
          Label(text = "Loading...")
        else:
          Label(text = "No image")
      else:
        Picture:
          pixbuf = app.pixbuf

owlkettle.brew(gui(App()))
