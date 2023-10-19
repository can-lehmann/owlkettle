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
  enablePopup: bool = true
  groupName: string
  scrollable: bool = true
  showBorder: bool = true
  showTabs: bool = true
  tabPosition: TabPositionType = TabTop
  currentPage: int = 0
  sensitive: bool = true
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)
  
  pages: seq[tuple[tabLabel: string, menuLabel: string, reorderable: bool, detachable: bool]] = (1..3).mapIt(
    ("Tab " & $it, "Some Menu", true, true)
  )

method view(app: AppState): Widget =
  result = gui:
    Window():
      title = "Notebook Example"
      defaultSize = (800, 600)
      HeaderBar() {.addTitlebar.}:
        insert(app.toAutoFormMenu(sizeRequest = (800, 700))) {.addRight.}
      
      Notebook():
        enablePopup = app.enablePopup
        groupName = app.groupName
        scrollable = app.scrollable
        showBorder = app.showBorder
        showTabs = app.showTabs
        tabPosition = app.tabPosition
        currentPage = app.currentPage
        sensitive = app.sensitive
        tooltip = app.tooltip
        sizeRequest = app.sizeRequest
        
        proc switchPage(newPageIndex: int) =
          echo "New Page Index: ", newPageIndex
        
        proc moveFocusOut(direction: DirectionType) =
          ## TODO: Currently not working. How do you trigger?
          echo "Moved Focus out in direction: ", direction
        
        proc pageAdded(newPageIndex: int) =
          ## TODO: Currently not working, maybe page is not removed via the right proc?
          echo "Page ", newPageIndex, " Added"
          
        proc pageRemoved(removedPageIndex: int) =
          ## TODO: Currently not working, maybe page is not removed via the right proc?
          echo "Page ", removedPageIndex, " Removed"

        proc pageReordered(newPageIndex: int) =
          echo "Page moved to new index ", newPageIndex


        for index, page in app.pages:
          Label(text = "Some Content of Page " & $(index+1)) {.tabLabel: page.tabLabel, menuLabel: page.menuLabel, reorderable: page.reorderable, detachable: page.detachable.}
        
adw.brew(gui(App()))
