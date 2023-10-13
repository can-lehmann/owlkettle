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
# SOFTWARE

import owlkettle, owlkettle/[playground, adw, dataentries]

viewable App:
  searchDelay: uint = 100
  text: string = ""
  placeholderText: string = "Search"
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)
  
method view(app: AppState): Widget =
  result = gui:
    Window():
      defaultSize = (400, 120)
      title = "Search Entry Example"
      HeaderBar() {.addTitlebar.}:
        insert(app.toAutoFormMenu()) {.addRight.}
      
      Box(orient = OrientY):
        Label(text = "Search something") {.expand: false.}
        SearchEntry() {.expand: false.}:
          searchDelay = app.searchDelay
          placeholderText = app.placeholderText
          sensitive = app.sensitive
          tooltip = app.tooltip
          sizeRequest = app.sizeRequest
          text = app.text
          
          proc activate(searchString: string) =
            app.text = searchString
            echo "Search triggered: ", searchString
          
          proc nextMatch() = echo "Next Match"
          proc previousMatch() = echo "Prior Match"
          proc searchStarted(searchString: string) = echo "Search Started: ", searchString
          proc changed(searchString: string) = 
            app.text = searchString
            echo "Search Changed: ", searchString
          proc stopSearch(searchString: string) = echo "Search Stopped: ", searchString

adw.brew(gui(App()))