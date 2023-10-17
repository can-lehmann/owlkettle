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
import owlkettle/[playground, adw]

viewable App:
  title: string
  actionName: string
  detailedActionName: string
  actionTarget: string
  buttonLabel: string = "Btn Label"
  priority: ToastPriority = ToastPriorityNormal
  timeout: int = 3
  useMarkup: bool = true ## Enables using markup in title. Only available for Adwaita version 1.4 or higher. Compile for Adwaita version 1.4 or higher with -d:adwMinor=4.
  
  showToast: bool = false

proc buildToast(state: AppState): AdwToast =
  result = newToast(state.title)
  if state.actionName != "":
    result.actionName = state.actionName
    
  if state.actionTarget != "":
    result.actionTarget = state.actionTarget

  if state.buttonLabel != "":
    result.buttonLabel = state.buttonLabel

  if state.detailedActionName != "":
    result.detailedActionName = state.detailedActionName

  result.priority = state.priority
  result.timeout = state.timeout
  result.titleMarkup = state.useMarkup

  result.dismissalHandler = proc(toast: AdwToast) = 
    echo "Dismissed: ", toast.title
    state.showToast = false
  # result.clickedHandler = proc() = echo "Click" # Comment in if you compile with -d:adwminor=2 or higher
  
method view(app: AppState): Widget =
  let toast: AdwToast = buildToast(app)
  result = gui:
    Window():
      defaultSize = (800, 600)
      title = "ToastOverlay Example"
      HeaderBar {.addTitlebar.}:
        insert(app.toAutoFormMenu(sizeRequest = (400, 250))){.addRight.}
      
        Button() {.addRight.}:
          style = [ButtonFlat]
          text = "Urgent"
          proc clicked() = 
            app.showToast = true
            app.priority = ToastPriorityHigh
            app.title = "Urgent Toast Title !!!"
            
        Button() {.addRight.}:
          style = [ButtonFlat]
          text = "Notify"
          proc clicked() = 
            app.showToast = true
            app.priority = ToastPriorityNormal
            app.title = "Toast title"

      
      Box(orient = OrientY):
        ToastOverlay():
          if app.showToast:
            toast = toast
          
          Box():
            Label(text = "A widget within Toast Overlay!")
        
adw.brew(gui(App()))
