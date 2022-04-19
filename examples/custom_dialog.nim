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

type User = object
  name: string
  password: string

viewable Property:
  name: string
  child: Widget

method view(property: PropertyState): Widget =
  result = gui:
    Box:
      orient = OrientX
      spacing = 6
      
      Label:
        text = property.name
        x_align = 0
      
      insert(property.child) {.expand: false.}

proc add(property: Property, child: Widget) =
  property.has_child = true
  property.val_child = child

viewable UserDialog:
  user: User

method view(dialog: UserDialogState): Widget =
  result = gui:
    Dialog:
      title = "New User"
      
      DialogButton {.add_button.}:
        text = "Create"
        style = {ButtonSuggested}
        res = DialogAccept
      
      DialogButton {.add_button.}:
        text = "Cancel"
        res = DialogCancel
      
      Box:
        orient = OrientY
        spacing = 6
        border_width = 12
        
        Property {.expand: false.}:
          name = "Name"
          Entry:
            text = dialog.user.name
            proc changed(name: string) =
              dialog.user.name = name
        
        Property {.expand: false.}:
          name = "Password"
          Entry:
            text = dialog.user.password
            visibility = false
            proc changed(password: string) =
              dialog.user.password = password

viewable App:
  users: seq[User]

method view(app: AppState): Widget =
  result = gui:
    Window:
      proc close() = quit()
      
      HeaderBar {.add_titlebar.}:
        title = "Users"
        
        Button {.add_left.}:
          icon = "list-add-symbolic"
          style = {ButtonSuggested}
          proc clicked() =
            let (res, state) = app.open(gui(UserDialog()))
            if res.kind == DialogAccept:
              app.users.add(UserDialogState(state).user)
      
      ScrolledWindow:
        ListBox:
          for user in app.users:
            ListBoxRow:
              Label:
                text = user.name
                x_align = 0

brew(gui(App()))
