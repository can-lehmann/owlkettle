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

import std/[sequtils]
import owlkettle, owlkettle/[dataentries, playground, adw]

viewable App:
  activatesDefault: bool = true
  placeholderText: string = "Password"
  showPeekIcon: bool = true
  sensitive: bool = true
  tooltip: string = ""
  text: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)

method view(app: AppState): Widget =
  result = gui:
    Window():
      defaultSize = (600, 150)
      HeaderBar() {.addTitlebar.}:
        WindowTitle {.addTitle.}:
          title = "Password Entry Example"
          subtitle = "Password length: " & $app.text.len()
        
        insert(app.toAutoFormMenu()) {.addRight.}
        
        Button {.addLeft.}:
          style = [ButtonFlat]
          text = "Reset"
          proc clicked() = app.text = ""
      
      Box(orient = OrientY):
        Label(text = "Enter a Password") {.expand: false.}
        PasswordEntry{.expand: false.}: 
          activatesDefault = app.activatesDefault
          placeholderText = app.placeholderText
          showPeekIcon = app.showPeekIcon
          sensitive = app.sensitive
          tooltip = app.tooltip
          sizeRequest = app.sizeRequest
          text = app.text
        
          proc activate() =
            echo "User confirmed new password"
            
          proc changed(pw: string) =
            echo "Change in Password: ", pw
            app.text = pw
            
adw.brew(gui(App()))
