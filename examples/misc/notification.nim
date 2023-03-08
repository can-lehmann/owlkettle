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

import std/[sequtils]
import owlkettle

# This example requires that a .desktop file for the example application
# exists. The default directory for desktop files is usually /usr/share/applications/.
# The file must have the same name as the application id.
# In this case the file therefore has to be named "com.example.NotificationExample.desktop".
# I used the following file:
#
#   [Desktop Entry]
#   Name=Notification Example
#   Comment=My application
#   Icon=open-menu-symbolic
#   Terminal=false
#   Exec=PATH_TO_THE_EXAMPLE
#   Type=Application
# 
# For more details see https://docs.gtk.org/gio/class.Notification.html

viewable App:
  title: string = "Notification"
  body: string = "I am the notification body"
  icon: string = "preferences-system-notifications"
  category: string = "im.received"
  priority: NotificationPriority = NotificationNormal

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Notification Example"
      defaultSize = (400, 200)
      
      HeaderBar {.addTitlebar.}:
        Button {.addLeft.}:
          text = "Send"
          style = [ButtonSuggested]
          
          proc clicked() =
            sendNotification("my-notification",
              title = app.title,
              body = app.body,
              icon = app.icon,
              category = app.category,
              priority = app.priority
            )
        
        Button {.addLeft.}:
          text = "Withdraw"
          
          proc clicked() =
            withdrawNotification("my-notification")
      
      Box(orient = OrientY, margin = 12, spacing = 6):
        Box(orient = OrientX, spacing = 6) {.expand: false.}:
          Label(text = "Title", xAlign=0)
          Entry {.expand: false.}:
            text = app.title
            width = 32
            proc changed(text: string) =
              app.title = text
        
        Box(orient = OrientX, spacing = 6) {.expand: false.}:
          Label(text = "Body", xAlign=0)
          Entry {.expand: false.}:
            text = app.body
            width = 32
            proc changed(text: string) =
              app.body = text
        
        Box(orient = OrientX, spacing = 6) {.expand: false.}:
          Label(text = "Icon", xAlign=0)
          Entry {.expand: false.}:
            text = app.icon
            width = 32
            proc changed(text: string) =
              app.icon = text
        
        Box(orient = OrientX, spacing = 6) {.expand: false.}:
          Label(text = "Category", xAlign=0)
          Entry {.expand: false.}:
            text = app.category
            width = 32
            proc changed(text: string) =
              app.category = text
        
        Box(orient = OrientX, spacing = 6) {.expand: false.}:
          Label(text = "Priority", xAlign=0)
          DropDown {.expand: false.}:
            items = mapIt(low(NotificationPriority)..high(NotificationPriority), $it)
            selected = ord(app.priority)
            proc select(item: int) =
              app.priority = NotificationPriority(item)

# We need an application id to send notifications
brew("com.example.NotificationExample", gui(App()))
