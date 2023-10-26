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

import std/[options, times, macros, strformat, sugar, strutils, sequtils, typetraits]
import ./dataentries
import ./adw
import ./widgetutils
import ./guidsl
import ./widgetdef
import ./widgets

proc toFormField(state: Viewable, field: ptr SomeNumber, fieldName: string): Widget =
  ## Provides a form field for all number types in SomeNumber
  return gui:
    ActionRow:
      title = fieldName
      FormulaEntry() {.addSuffix.}:
        value = field[].float
        xAlign = 1.0
        maxWidth = 8
        proc changed(value: float) =
          field[] = type(field[])(value)

proc toFormField(state: Viewable, field: ptr Range, fieldName: string): Widget =
  ## Provides a form field for all range types
  return gui:
    ActionRow:
      title = fieldName
      FormulaEntry() {.addSuffix.}:
        value = field[]
        xAlign = 1.0
        maxWidth = 8
        proc changed(value: float) =
          field[] = value

proc toFormField(state: Viewable, field: ptr string, fieldName: string): Widget =
  ## Provides a form field for strings
  return gui:
    ActionRow:
      title = fieldName
      Entry() {.addSuffix.}:
        text = field[]
        proc changed(text: string) =
          field[] = text

proc toFormField(state: Viewable, field: ptr bool, fieldName: string): Widget =
  ## Provides a form field for booleans
  return gui:
    ActionRow:
      title = fieldName
      Box() {.addSuffix.}:
        Switch() {.vAlign: AlignCenter, expand: false.}:
          state = field[]
          proc changed(newVal: bool) =
            field[] = newVal

proc toFormField(state: Viewable, field: ptr[enum] , fieldName: string): Widget =
  ## Provides a form field for all enum types
  let options: seq[string] = type(field[]).items.toSeq().mapIt($it)
  return gui:
    ComboRow:
      title = fieldName
      items = options
      selected = ord(field[])
      proc select(enumIndex: int) =
        field[] = type(field[])(enumIndex)

viewable DateDialog:
  date: DateTime = now()
  title: string = "Select DateTime"

method view (state: DateDialogState): Widget =
  result = gui:
    Dialog:
      title = state.title
      defaultSize = (520, 0)
      
      DialogButton {.addButton.}:
        text = "Select"
        style = [ButtonSuggested]
        res = DialogAccept
        
      DialogButton {.addButton.}:
        text = "Cancel"
        res = DialogCancel
        
      Box(orient = OrientY):
        Calendar:
          date = state.date
          proc select(date: DateTime) =
            state.date = date

proc toFormField(state: Viewable, field: ptr DateTime, fieldName: string): Widget =
  ## Provides a form field for DateTimes
  return gui:
    ActionRow:
      title = fieldName
      subtitle =  $(field[]).inZone(local())
      Button {.addSuffix.}:
        icon = "x-office-calendar-symbolic"
        text = "Select"
        proc clicked() =
          let (res, dialogState) = state.open(gui(DateDialog()))
          if res.kind == DialogAccept:
            field[] = DateDialogState(dialogState).date

proc toFormField(state: Viewable, field: ptr tuple[x, y: int], fieldName: string): Widget =
  ## Provides a form field for the tuple type of sizeRequest
  let tup = field[]
  return gui:
    ActionRow:
      title = fieldName
      NumberEntry() {.addSuffix.}:
        value = tup[0].float
        xAlign = 1.0
        maxWidth = 8
        proc changed(value: float) =
          field[][0] = value.int
        
      NumberEntry() {.addSuffix.}:
        value = tup[1].float
        xAlign = 1.0
        maxWidth = 8
        proc changed(value: float) =
          field[][1] = value.int

proc toFormField(state: Viewable, field: ptr ScaleMark, fieldName: string): Widget =
  ## Provides a form field for the type ScaleMark
  return gui:
    ActionRow:
      title = fieldName
      
      FormulaEntry {.addSuffix.}:
        value = field[].value
        xAlign = 1.0
        maxWidth = 8
        proc changed(value: float) =
          field[].value = value
      
      DropDown {.addSuffix.}:
        items = ScalePosition.items.toSeq().mapIt($it)
        selected = field[].position.int
        proc select(enumIndex: int) =
          field[].position = enumIndex.ScalePosition

proc toFormField[T](state: Viewable, field: ptr seq[T], fieldName: string): Widget =
  ## Provides a form field for any seq type
  let formFields = collect(newSeq):
    for index, value in field[]:
      toFormField(state, field[][index].addr, fmt"{fieldName} {index}")
      
  return gui:
    ExpanderRow:
      title = fieldName
      
      for index, formField in formFields:
        Box(orient = OrientX) {.addRow.}:
          insert(formField)
          Button() {.expand: false.}:
            icon = "user-trash-symbolic"
            style = [ButtonDestructive]
            proc clicked() =
              field[].delete(index) 
      
      ListBoxRow {.addRow.}:
        Button:
          icon = "list-add-symbolic"
          style = [ButtonFlat]
          proc clicked() =
            field[].add(default(T))

proc toAutoFormMenu*[T](app: T, sizeRequest: tuple[x,y: int] = (400, 700), ignoreFields: static seq[string]): Widget =
  ## Provides a form for every field in a given `app` instance.
  ## The form is provided as a Popover that can be activated via a Menu-Button
  ## `ignoreFields` defines a list of field names to ignore for the form generation.
  ## `sizeRequest` defines the requested size for the popover. 
  ## Displays a dummy widget if there is no `toFormField` implementation for a field with a custom type.
  var fieldWidgets: seq[Widget] = @[]
  for name, value in app[].fieldPairs:
    when name notin ["app", "viewed"] and name notin ignoreFields:
      let field: ptr = value.addr
      let fieldWidget = app.toFormField(field, name)
      fieldWidgets.add(fieldWidget)
      
  result = gui:
    MenuButton:
      icon = "document-properties"
      style = [ButtonFlat]
      
      Popover():
        Box(orient = OrientY):
          sizeRequest = sizeRequest
          ScrolledWindow:
            PreferencesGroup:
              title = "Fields"
              margin = 12
              
              for field in fieldWidgets:
                insert field
            
proc toAutoFormMenu*[T](app: T, sizeRequest: tuple[x,y: int] = (400, 700)): Widget =
  const ignoreFields: seq[string] = @[]
  return toAutoFormMenu[T](app, ignoreFields = ignoreFields, sizeRequest = sizeRequest)
