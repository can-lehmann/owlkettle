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

import std/[options, times, macros, strformat, strutils, sequtils, typetraits]
import ./dataentries
import ./adw
import ./widgetutils
import ./guidsl
import ./widgetdef
import ./widgets

macro getField*(someType: untyped, fieldName: static string): untyped =
  nnkDotExpr.newTree(someType, ident(fieldName))

# Default `toFormField` implementations
proc toFormField[T: SomeNumber](state: auto, fieldName: static string, typ: typedesc[T]): Widget =
  ## Provides a form field for all number times in SomeNumber
  return gui:
    ActionRow:
      title = fieldName
      FormulaEntry() {.addSuffix.}:
        value = state.getField(fieldName).float
        xAlign = 1.0
        maxWidth = 8
        proc changed(value: float) =
          state.getField(fieldName) = value.T

proc toFormField(state: auto, fieldName: static string, typ: typedesc[string]): Widget =
  ## Provides a form field for string
  return gui:
    ActionRow:
      title = fieldName
      Entry() {.addSuffix.}:
        text = state.getField(fieldName)
        proc changed(text: string) =
          state.getField(fieldName) = text

proc toFormField(state: auto, fieldName: static string, typ: typedesc[bool]): Widget =
  ## Provides a form field for bool
  return gui:
    ActionRow:
      title = fieldName
      Box() {.addSuffix.}:
        Switch() {.vAlign: AlignCenter, expand: false.}:
          state = state.getField(fieldName)
          proc changed(newVal: bool) =
            state.getField(fieldName) = newVal

proc toFormField(state: auto, fieldName: static string, typ: typedesc[auto]): Widget =
  ## Provides a dummy field as a fallback for any type without a `toFormField`.
  return gui:
    ActionRow:
      title = fieldName
      Label():
        text = fmt"Override `toFormField` for '{$typ.type}'"
        tooltip = fmt"""
          The type '{$typ.type}' must implement a `toFormField` proc:
          `toFormField(
            state: auto, 
            fieldName: static string, 
            typ: typedesc[{$typ.type}]
          ): Widget`
          state: The <Widget>State
          fieldName: The name of the field on `state` for which the current form field is being generated
          typ: The type for which `toListFormField` shall function.
          
          Implementing the proc will override this dummy Widget.
          See the autoform module for examples.
        """

proc toFormField[T: enum](state: auto, fieldName: static string, typ: typedesc[T]): Widget =
  ## Provides a form field for enums
  let options: seq[string] = T.items.toSeq().mapIt($it)
  return gui:
    ComboRow:
      title = fieldName
      items = options
      selected = ord(state.getField(fieldName))
      proc select(enumIndex: int) =
        state.getField(fieldName) = enumIndex.T

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
          proc daySelected(date: DateTime) =
            state.date = date

proc toFormField(state: auto, fieldName: static string, typ: typedesc[DateTime]): Widget =
  ## Provides a form field for DateTime
  return gui:
    ActionRow:
      title = fieldName & ": " & $state.getField(fieldName).inZone(local())
      Button {.addSuffix.}:
        icon = "x-office-calendar-symbolic"
        text = "Select"
        proc clicked() =
          let (res, dialogState) = state.open(gui(DateDialog()))
          if res.kind == DialogAccept:
            state.getField(fieldName) = DateDialogState(dialogState).date

proc toFormField(state: auto, fieldName: static string, typ: typedesc[tuple[x,y: int]]): Widget =
  ## Provides a form field for the tuple type of sizeRequest
  return gui:
    ActionRow:
      title = fieldName
      NumberEntry() {.addSuffix.}:
        value = state.getField(fieldName)[0].float
        xAlign = 1.0
        maxWidth = 8
        proc changed(value: float) =
          state.getField(fieldName)[0] = value.int
        
      NumberEntry() {.addSuffix.}:
        value = state.getField(fieldName)[1].float
        xAlign = 1.0
        maxWidth = 8
        proc changed(value: float) =
          state.getField(fieldName)[1] = value.int


## Default `toListFormField` implementations
proc toListFormField[T: SomeNumber](state: auto, fieldName: static string, index: int, typ: typedesc[T]): Widget =
  ## Provides a form to display a single entry of any number in a list of number entries.
  return gui:
    ActionRow:
      title = fieldName & $index
      
      FormulaEntry() {.addSuffix.}:
        value = state.getField(fieldName)[index].float
        xAlign = 1.0
        maxWidth = 8
        proc changed(value: float) =
          state.getField(fieldName)[index] = value.T

proc toListFormField(state: auto, fieldName: static string, index: int, typ: typedesc[string]): Widget =
  ## Provides a form to display a single entry of type `string` in a list of `string` entries.
  return gui:
    ActionRow:
      title = fieldName
      Entry() {.addSuffix.}:
        text = state.getField(fieldName)[index]
        proc changed(text: string) =
          state.getField(fieldName)[index] = text

proc toListFormField(state: auto, fieldName: static string, index: int, typ: typedesc[bool]): Widget =
  ## Provides a form to display a single entry of type `bool` in a list of `bool` entries.
  return gui:
    ActionRow:
      title = fieldName
      Box() {.addSuffix.}:
        Switch() {.vAlign: AlignCenter, expand: false.}:
          state = state.getField(fieldName)[index]
          proc changed(newVal: bool) =
            state.getField(fieldName)[index] = newVal

proc toListFormField(state: auto, fieldName: static string, index: int, typ: typedesc[DateTime]): Widget =
  ## Provides a form to display a single entry of type `DateTime` in a list of `DateTime` entries.
  return gui:
    ActionRow:
      title = fieldName & ": " & $state.getField(fieldName)[index].inZone(local())
      Button {.addSuffix.}:
        icon = "x-office-calendar-symbolic"
        text = "Select"
        proc clicked() =
          let (res, dialogState) = state.open(gui(DateDialog()))
          if res.kind == DialogAccept:
            state.getField(fieldName)[index] = DateDialogState(dialogState).date

proc toListFormField[T: enum](state: auto, fieldName: static string, index: int, typ: typedesc[T]): Widget =
  ## Provides a form to display a single entry of an enum in a list of enum entries.
  let options: seq[string] = T.items.toSeq().mapIt($it)
  return gui:
    ComboRow:
      title = fieldName
      items = options
      selected = ord(state.getField(fieldName)[index])
      proc select(enumIndex: int) =
        state.getField(fieldName)[index] = enumIndex.T

proc toListFormField(state: auto, fieldName: static string, index: int, typ: typedesc[auto]): Widget =
  ## Provides a dummy row widget for displaying an entry in a list of any type without its own `toListFormField`
  return gui:
    ActionRow:
      title = fieldName
      Label():
        text = fmt"Override `toListFormField` for '{$typ.type}'"
        tooltip = fmt"""
          The type '{$typ.type}' must implement a `toListFormField` proc:
          `toListFormField(
            state: auto, 
            fieldName: static string, 
            index: int,
            typ: typedesc[{$typ.type}]
          ): Widget`
          state: The <Widget>State
          fieldName: The name of the field on `state` that contains the seq for which the current form-row is being generated
          index: The index on the list of entries in `state.<fieldName>`
          typ: The type for which `toListFormField` shall function.
          
          Implementing the proc will override this dummy Widget.
          See the autoform module for examples.
        """

proc toListFormField(state: auto, fieldName: static string, index: int, typ: typedesc[ScaleMark]): Widget =
  ## Provides a form to display a single entry of type `ScaleMark` in a list of `ScaleMark` entries.
  let mark: ScaleMark = state.getField(fieldName)[index]
  return gui:
    ActionRow:
      title = fieldName & $index
      
      FormulaEntry {.addSuffix.}:
        value = mark.value
        xAlign = 1.0
        maxWidth = 8
        proc changed(value: float) =
          state.getField(fieldName)[index].value = value
      
      DropDown {.addSuffix.}:
        items = ScalePosition.items.toSeq().mapIt($it)
        selected = mark.position.int
        proc select(enumIndex: int) =
          state.getField(fieldName)[index].position = enumIndex.ScalePosition
          
      Button {.addSuffix.}:
        icon = "user-trash-symbolic"
        proc clicked() =
          state.getField(fieldName).delete(index)

proc toFormField[T](state: auto, fieldName: static string, typ: typedesc[seq[T]]): Widget =
  ## Provides a form field for any field on `state` with a seq type.
  ## Displays a dummy widget if there is no `toListFormField` implementation for type T.
  return gui:
    ExpanderRow:
      title = fieldName
      
      for index, num in state.getField(fieldName):
        insert(toListFormField(state, fieldName, index, T)){.addRow.}
      
      ListBoxRow {.addRow.}:
        Button:
          icon = "list-add-symbolic"
          style = [ButtonFlat]
          proc clicked() =
            state.getField(fieldName).add(default(T))

proc toAutoFormMenu*[T](app: T, sizeRequest: tuple[x,y: int] = (400, 700), ignoreFields: static seq[string]): Widget =
  ## Provides a form for every field in a given `app` instance.
  ## The form is provided as a Popover that can be activated via a Menu-Button
  ## `ignoreFields` defines a list of field names to ignore for the form generation.
  ## `sizeRequest` defines the requested size for the popover. 
  ## Displays a dummy widget if there is no `toFormField` implementation for a field with a custom type.
  var fieldWidgets: seq[Widget] = @[]
  for name, value in app[].fieldPairs:
    when name notin ["app", "viewed"] and name notin ignoreFields:
      let fieldWidget = app.toFormField(name, value.type)
      fieldWidgets.add(fieldWidget)
      
  result = gui:
    MenuButton:
      icon = "document-properties"
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
