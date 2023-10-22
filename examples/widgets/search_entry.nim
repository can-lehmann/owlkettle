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
import std/[strutils, sets, sequtils]

viewable App:
  searchDelay: uint = 100
  text: string = ""
  placeholderText: string = "Search List"
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)
  
  items: seq[string] = mapIt(0..<100, "Item " & $it)
  filteredItems: seq[string] = mapIt(0..<100, "Item " & $it)
  selected: int = 0
  
method view(app: AppState): Widget =
  let isInActiveSearch = app.text != ""
  result = gui:
    Window():
      defaultSize = (600, 400)
      HeaderBar() {.addTitlebar.}:
        insert(app.toAutoFormMenu(ignoreFields = @["filteredItems"])) {.addRight.}
      
        SearchEntry() {.addTitle, expand: true.}:
          margin = Margin(top:0, left: 48, bottom:0, right: 48)
          text = app.text
          searchDelay = app.searchDelay
          placeholderText = app.placeholderText
          sensitive = app.sensitive
          tooltip = app.tooltip
          sizeRequest = app.sizeRequest
          
          proc nextMatch() = 
            if app.selected < app.filteredItems.high:
              app.selected += 1
          
          proc previousMatch() = 
            if app.selected > 0:
              app.selected -= 1
          
          proc activate() =
            echo "activated search for entry: ": $app.filteredItems[app.selected]
          
          proc changed(searchString: string) = 
            app.text = searchString
            app.selected = 0
            app.filteredItems = app.items.filterIt(searchString in it)
          
          proc stopSearch() = 
            echo "Search Stopped"
            app.text = ""
            app.filteredItems = app.items
          
      ScrolledWindow:
        ListBox:
          selected = [app.selected].toHashSet()
          selectionMode = SelectionSingle
          
          proc select(rows: Hashset[int]) =
            for num in rows:
              app.selected = num
          
          for index, item in app.filteredItems:
            Box():
              Label(text = item, margin = 6) {.hAlign: AlignStart, expand: false.}
        

adw.brew(gui(App()))