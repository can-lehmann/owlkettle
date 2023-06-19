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
  paths: seq[string]

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "File Dialog Example"
      defaultSize = (400, 300)
      
      HeaderBar {.addTitlebar.}:
        Button {.addLeft.}:
          text = "Open"
          style = [ButtonSuggested]
          proc clicked() =
            let (res, state) = app.open: gui:
              FileChooserDialog:
                title = "Open a File"
                action = FileChooserOpen
                selectMultiple = true
                
                DialogButton {.addButton.}:
                  text = "Cancel"
                  res = DialogCancel
                
                DialogButton {.addButton.}:
                  text = "Open"
                  res = DialogAccept
                  style = [ButtonSuggested]
            
            if res.kind == DialogAccept:
              app.paths = FileChooserDialogState(state).filenames
      
      ScrolledWindow:
        ListBox:
          for path in app.paths:
            Label:
              text = path
              margin = 6
              xAlign = 0

brew(gui(App()))
