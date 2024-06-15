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
import std/[sequtils, sugar]

viewable App:
  buttonLabel: string = "Btn Label"
  timeout: int = 3
  useMarkup: bool = true ## Enables using markup in title. Only available for Adwaita version 1.4 or higher. Compile for Adwaita version 1.4 or higher with -d:adwMinor=4.
  toastQueue: ToastQueue = newToastQueue()

proc buildToast(
  state: AppState,
  title: string = "",
  priority: ToastPriority = ToastPriorityNormal,
): Toast =
  let dismissalHandler = proc(toast: Toast) = 
    echo "Dismissed: ", toast.title
  
  let clickedHandler = proc() = echo "Click"
  result = newToast(
    title = title,
    buttonLabel = state.buttonLabel,
    priority = priority,
    dismissalHandler = dismissalHandler,
    timeout = state.timeout,
    clickedHandler = clickedHandler,# Comment in if you compile with -d:adwminor=2 or higher 
    useMarkup = state.useMarkup # Comment in if you compile with -d:adwminor=2 or higher
  )

method view(app: AppState): Widget =  
  result = gui:
    Window():
      defaultSize = (800, 600)
      title = "ToastOverlay Example"
      HeaderBar {.addTitlebar.}:
        insert(app.toAutoFormMenu(ignoreFields = @["toastQueue"], sizeRequest = (400, 250))){.addRight.}
      
        Button() {.addRight.}:
          style = [ButtonFlat]
          text = "Urgent"
          proc clicked() = 
            let toast = buildToast(app, "Urgent Toast Title !!!", ToastPriorityHigh)
            app.toastQueue.add(toast)
            
        Button() {.addRight.}:
          style = [ButtonFlat]
          text = "Notify"
          proc clicked() = 
            let toast = buildToast(app, "Toast title", ToastPriorityNormal)
            app.toastQueue.add(toast)

        Button() {.addRight.}:
          style = [ButtonFlat]
          text = "Notify*3"
          proc clicked() = 
            let toasts = (0..2).mapIt(buildToast(app, "Toast title", ToastPriorityNormal))
            app.toastQueue.add(toasts)
                  
        Button() {.addRight.}:
          text = "Redraw"
          proc clicked() =
            discard app.redraw()
      
      Box(orient = OrientY):
        ToastOverlay():
          toastQueue = app.toastQueue
            
          Box():
            Label(text = "A widget within Toast Overlay!")

adw.brew(gui(App()))
