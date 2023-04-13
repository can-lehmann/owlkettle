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

import std/sequtils
import owlkettle

viewable MyDialog:
  res: DialogResponseKind = DialogAccept

method view(dialog: MyDialogState): Widget =
  result = gui:
    Dialog:
      title = "My Dialog"
      defaultSize = (300, 200)
      
      Box:
        orient = OrientY
        margin = 12
        spacing = 12
        
        Box {.expand: false.}:
          orient = OrientX
          spacing = 6
          
          DropDown:
            items = mapIt(low(DialogResponseKind)..high(DialogResponseKind), $it)
            selected = ord(dialog.res)
            
            proc select(index: int) =
              dialog.res = DialogResponseKind(index)
          
          Button {.expand: false.}:
            text = "Respond"
            style = [ButtonSuggested]
            
            proc clicked() =
              dialog.respond(DialogResponse(kind: dialog.res))
          
        Button {.vAlign: AlignEnd.}:
          text = "Close"
          
          proc clicked() =
            dialog.closeWindow()

viewable App:
  discard

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Dialog Respond Example"
      defaultSize = (500, 350)
      
      Box:
        Button {.hAlign: AlignCenter, vAlign: AlignCenter.}:
          text = "Open Dialog"
          
          proc clicked() =
            let (res, state) = app.open: gui:
              MyDialog()
            
            echo res

brew(gui(App()))
