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

import std/sequtils
import owlkettle, owlkettle/[adw, dataentries]

type GridItem = ref object
  name: string
  x, y: int
  width, height: int
  hExpand, vExpand: bool
  hAlign, vAlign: Align

viewable GridItemEditor:
  item: GridItem

method view(editor: GridItemEditorState): Widget =
  let item = editor.item
  result = gui:
    Box:
      orient = OrientY
      spacing = 12
      margin = 12
      
      PreferencesGroup {.expand: false.}:
        title = "General"
        
        ActionRow:
          title = "Name"
          
          Entry {.addSuffix.}:
            text = item.name
            proc changed(text: string) =
              item.name = text
    
      PreferencesGroup {.expand: false.}:
        title = "Region"
        
        ActionRow:
          title = "Position"
          
          Box {.addSuffix.}:
            style = [BoxLinked]
            
            NumberEntry {.expand: false.}:
              value = float(item.x)
              xAlign = 1.0
              maxWidth = 6
              proc changed(value: float) =
                item.x = int(value)
            
            NumberEntry {.expand: false.}:
              value = float(item.y)
              xAlign = 1.0
              maxWidth = 6
              proc changed(value: float) =
                item.y = int(value)
        
        ActionRow:
          title = "Size"
          
          Box {.addSuffix.}:
            style = [BoxLinked]
            
            NumberEntry {.expand: false.}:
              value = float(item.width)
              xAlign = 1.0
              maxWidth = 6
              proc changed(value: float) =
                if value >= 1:
                  item.width = int(value)
            
            NumberEntry {.expand: false.}:
              value = float(item.height)
              xAlign = 1.0
              maxWidth = 6
              proc changed(value: float) =
                if value >= 1:
                  item.height = int(value)
      
      PreferencesGroup {.expand: false.}:
        title = "Expand"
        
        ActionRow:
          title = "Horizontal"
          
          Switch {.addSuffix.}:
            state = item.hExpand
            proc changed(state: bool) =
              item.hExpand = state
        
        ActionRow:
          title = "Vertical"
          
          Switch {.addSuffix.}:
            state = item.vExpand
            proc changed(state: bool) =
              item.vExpand = state
      
      PreferencesGroup {.expand: false.}:
        title = "Alignment"
        
        ComboRow:
          title = "Horizontal"
          
          items = mapIt(low(Align)..high(Align), $it)
          selected = ord(item.hAlign)
          proc select(index: int) =
            item.hAlign = Align(index)
        
        ComboRow:
          title = "Vertical"
          
          items = mapIt(low(Align)..high(Align), $it)
          selected = ord(item.vAlign)
          proc select(index: int) =
            item.vAlign = Align(index)

viewable AddGridItemDialog:
  item: GridItem

method view(dialog: AddGridItemDialogState): Widget =
  result = gui:
    Dialog:
      title = "Add Grid Item"
      defaultSize = (400, 500)
      
      DialogButton {.addButton.}:
        text = "Cancel"
        res = DialogCancel
      
      DialogButton {.addButton.}:
        text = "Add"
        res = DialogAccept
        style = [ButtonSuggested]
      
      ScrolledWindow:
        GridItemEditor:
          item = dialog.item

viewable App:
  items: seq[GridItem]
  selected: int

method view(app: AppState): Widget =
  result = gui:
    WindowSurface:
      Box:
        orient = OrientX
        
        Box {.expand: true.}:
          orient = OrientY
          
          HeaderBar {.expand: false.}:
            showTitleButtons = false
            
            WindowTitle {.addTitle.}:
              title = "Grid"
              subtitle = $app.items.len & " items"
            
            Button {.addLeft.}:
              icon = "list-add-symbolic"
              style = [ButtonFlat]
              
              proc clicked() =
                let (res, state) = app.open: gui:
                  AddGridItemDialog:
                    item = GridItem(
                      name: "Grid Item " & $app.items.len,
                      width: 1,
                      height: 1
                    )
                
                if res.kind == DialogAccept:
                  let dialog = AddGridItemDialogState(state)
                  app.items.add(dialog.item)
          
          
          Grid:
            spacing = 6
            margin = 12
            
            for it, item in app.items:
              ToggleButton {.x: item.x,
                             y: item.y,
                             width: item.width,
                             height: item.height,
                             hExpand: item.hExpand,
                             vExpand: item.vExpand,
                             hAlign: item.hAlign,
                             vAlign: item.vAlign.}:
                text = item.name
                state = it == app.selected
                
                proc clicked() =
                  app.selected = it
        
        Separator() {.expand: false.}
        
        Box {.expand: false.}:
          orient = OrientY
          sizeRequest = (300, -1)
          
          let validSelection = app.selected < app.items.len
          
          HeaderBar {.expand: false.}:
            Button {.addLeft.}:
              icon = "user-trash-symbolic"
              style = [ButtonFlat]
              sensitive = validSelection
              
              proc clicked() =
                if validSelection:
                  app.items.delete(app.selected)
          
          if validSelection:
            ScrolledWindow:
              GridItemEditor:
                item = app.items[app.selected]
          else:
            Label:
              text = "No Item Selected"

adw.brew(gui(App()))
