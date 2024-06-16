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
  buttonLabel: string = "Button"
  timeout: int = 3
  useMarkup: bool = true ## Enables using markup in title. Only available for Adwaita version 1.4 or higher. Compile for Adwaita version 1.4 or higher with -d:adwMinor=4.
  toastQueue: ToastQueue = newToastQueue()

proc buildToast(state: AppState,
                title: string = "",
                priority: ToastPriority = ToastPriorityNormal): Toast =
  
  let toast = newToast(
    title = title,
    buttonLabel = state.buttonLabel,
    priority = priority,
    timeout = state.timeout
  )
  
  when AdwVersion >= (1, 2):
    toast.clickedHandler = proc() =
      echo "Click: ", toast.title
  
  when AdwVersion >= (1, 4):
    toast.useMarkup = state.useMarkup
  
  toast.dismissalHandler = proc() = 
    echo "Dismissed: ", toast.title
  
  return toast

method view(app: AppState): Widget =  
  result = gui:
    Window:
      title = "Toast Overlay Example"
      defaultSize = (500, 350)
      
      HeaderBar {.addTitlebar.}:
        insert(app.toAutoFormMenu(ignoreFields = @["toastQueue"], sizeRequest = (400, 250))){.addRight.}
      
      Box:
        orient = OrientY
        
        ToastOverlay:
          toastQueue = app.toastQueue
          
          Box:
            Box {.hAlign: AlignCenter, vAlign: AlignCenter.}:
              orient = OrientX
              spacing = 12
              
              Button:
                style = [ButtonPill]
                text = "Urgent"
                proc clicked() = 
                  let toast = buildToast(app, "Urgent Toast", ToastPriorityHigh)
                  app.toastQueue.add(toast)
                  
              Button:
                style = [ButtonPill, ButtonSuggested]
                text = "Notify"
                proc clicked() = 
                  let toast = buildToast(app, "Toast", ToastPriorityNormal)
                  app.toastQueue.add(toast)

adw.brew(gui(App()))
