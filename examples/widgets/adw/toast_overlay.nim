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
  title: string = "Toast title"
  actionName: string
  detailedActionName: string
  actionTarget: string
  buttonLabel: string = "Btn Label"
  priority: ToastPriority = ToastPriorityNormal
  timeout: int = 1000
  useMarkup: bool = false ## Enables using markup in title. Only available for Adwaita version 1.4 or higher. Compile for Adwaita version 1.4 or higher with -d:adwMinor=4.

  showToast: bool = true

proc buildToast(state: AppState): AdwToast =
  result = newToast(state.title)
  if state.actionName != "":
    result.setActionName(state.actionName)
  if state.actionTarget != "":
    result.setActionTarget(state.actionTarget)
  result.setButtonLabel(state.buttonLabel)
  if state.detailedActionName != "":
    result.setDetailedActionName(state.detailedActionName)
  result.setPriority(state.priority)
  result.setTimeout(state.timeout)
  result.setTitleMarkup(state.useMarkup)
  
  # proc dismissalHandler(toast: AdwToast) =
  #   echo "Dismissed"
  # result.setDismissalHandler(dismissalHandler)
  
method view(app: AppState): Widget =
  let toast: AdwToast = buildToast(app)
  assert not toast.isNil()
  result = gui:
    Window():
      defaultSize = (800, 600)
      title = "ToastOverlay Example"
      HeaderBar {.addTitlebar.}:
        insert(app.toAutoFormMenu(sizeRequest = (400, 250))){.addRight.}
      
      Box(orient = OrientY):
        Label(text = "Toast Overlay!")
        ToastOverlay():
          toast = toast
          Label(text = "Toast Overlay Child")
        
adw.brew(gui(App()))
