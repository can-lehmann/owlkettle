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

import owlkettle, owlkettle/[autoform, adw]

viewable App:
  description: string = "Some Description"
  iconName: string = "weather-clear-symbolic"
  title: string = "Some Title"
method view(app: AppState): Widget =
  result = gui:
    WindowSurface:
      defaultSize = (800, 600)
      
      Box(orient = OrientX):
        insert app.toAutoForm()
        
        Separator() {.expand: false.}
        
        Box(orient = OrientY):
          HeaderBar {.expand: false.}:
            WindowTitle {.addTitle.}:
              title = "Status Page Example"
        
          StatusPage():
            description = app.description
            iconName = app.iconName
            title = app.title
            
            Label(text = "I am a child of a status page")
          

adw.brew(gui(App()))
