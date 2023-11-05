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

import std/[options, times, macros, strformat, sugar, strutils, sequtils, typetraits, tables]
import ./dataentries
import ./adw
import ./widgetutils
import ./guidsl
import ./widgetdef
import ./widgets

type Range = concept r # Necessary as there is no range typeclass *for parameters*. So `field: ptr range` is not a valid parameter.
  r is range

template getIterator*(a: typed): untyped =
  ## Provides a fieldPairs iterator for both ref-types and value-types
  when a is ref:
    a[].fieldPairs
    
  else:
    a.fieldPairs

proc selfAssign[T](v: var T) = v = v
proc isObjectVariantType(Obj: typedesc[object | ref object]): bool =
  ## Checks if a given typedesc is of an object variant
  ## by checking if you can assign to a field. This is a 
  ## compile-time error when doing this with the fieldPairs iterator
  ## to an object variant "kind" field. 
  var obj = default Obj
  for name, field in obj.getIterator():
    when not compiles(selfAssign field):
      return true
  
  return false

type ObjectVariantType = concept type V
  ## A concept covering all object variant types. 
  ## This concept is **not** intended for use with object variant **instances**,
  ## as its implementation relies on type.
  isObjectVariantType(V)

# Forward Declarations so order of procs below doesn't matter
proc toFormField(state: Viewable, field: ptr SomeNumber, fieldName: string): Widget
proc toFormField(state: Viewable, field: ptr Range, fieldName: string): Widget
proc toFormField(state: Viewable, field: ptr string, fieldName: string): Widget
proc toFormField(state: Viewable, field: ptr bool, fieldName: string): Widget
proc toFormField(state: Viewable, field: ptr[enum], fieldName: string): Widget
proc toFormField(state: Viewable, field: ptr DateTime, fieldName: string): Widget
proc toFormField(state: Viewable, field: ptr[distinct], fieldName: string): Widget
proc toFormField(state: Viewable, field: ptr tuple[x, y: int], fieldName: string): Widget
proc toFormField(state: Viewable, field: ptr ScaleMark, fieldName: string): Widget
proc toFormField[T](state: Viewable, field: ptr seq[T], fieldName: string): Widget
proc toFormField(state: Viewable, field: ptr ObjectVariantType, fieldName: string): Widget
proc toFormField(state: Viewable, field: ptr auto, fieldName: string): Widget

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


proc toFormField(state: Viewable, field: ptr[distinct], fieldName: string): Widget =
  ## Provides a form field for any distinct type. 
  ## The form field provided is the same that the base-type of the distinct type would have.
  let baseField = field[].distinctBase.addr
  toFormField(state, baseField, fieldName)

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

proc addDeleteButton(formField: Widget, value: ptr seq[auto], index: int) =
  let button = gui:
    Button():
      icon = "user-trash-symbolic"
      style = [ButtonDestructive]
      proc clicked() =
        value[].delete(index) 

  if formField of ActionRow:
    ActionRow(formField).addSuffix(button)
  elif formField of ExpanderRow:
    ExpanderRow(formField).addRow(button)

proc toFormField[T](state: Viewable, field: ptr seq[T], fieldName: string): Widget =
  ## Provides a form field for any seq type
  ## Enables adding new entries and deleting existing entries.
  ## Note that deletion of an entry is only enabled if the `toFormField` proc for
  ## the given field's type `T` is an ActionRow or ExpanderRow widget.
  let formFields = collect(newSeq):
    for index, value in field[]:
      let formField = toFormField(state, field[][index].addr, fmt"{fieldName} {index}")
      formField.addDeleteButton(field, index)
      formField
  
  return gui:
    ExpanderRow:
      title = fieldName
      
      for index, formField in formFields:
        insert(formField) {.addRow.}

      
      ListBoxRow {.addRow.}:
        Button:
          icon = "list-add-symbolic"
          style = [ButtonFlat]
          proc clicked() =
            field[].add(default(T))

proc toPlaceHolderFormField(state: Viewable, field: ptr[auto], fieldName: string): Widget =
  ## Provides a placeholder form field informing the user to implement their own
  ## `toFormField` proc, as none of the existing `toFormField` overloads could be applied.
  const typeName: string = $field[].type
  return gui:
    ActionRow:
      title = fieldName
      Label():
        text = fmt"Override `toFormField` for '{typeName}'"
        tooltip = fmt"""
          The type '{typeName}' must implement a `toFormField` proc:
          `toFormField(
            state: Viewable, 
            field: ptr {typeName}
            fieldName: string, 
          ): Widget`
          state: The <Widget>State
          field: The field's value to assign to/get the value from
          fieldName: The name of the field on `state` for which the current form field is being generated
          
          Implementing the proc will override this dummy Widget.
          See the playground module for examples.
          Note: You should prefer returning ActionRow, ExpanderRow, EntryRow or other 
          PreferencesRow-based Widgets.
        """

proc toFormField(state: Viewable, field: ptr ObjectVariantType, fieldName: string): Widget =
  ## Provides a form field for any object variant type
  return state.toPlaceHolderFormField(field, fieldName)

proc toFormField(state: Viewable, field: ptr[auto], fieldName: string): Widget =
  ## Provides a fallback form field for any type that does not match any of the other `toFormField` overloads.
  ## If the type has fields (e.g. object or tuple) it will generate a form with a formfield 
  ## for each field on the type.
  ## If the type does not have fields it will generate a dummy-field with text informing the user to 
  ## define their own `toFormField` proc.
  const hasFields = field is ptr object or field is ptr ref object or field is ptr tuple or field is ptr ref tuple
  
  when hasFields:
    var subFieldWidgets: Table[string, Widget] = initTable[string, Widget]()
    for subFieldName, subFieldValue in field[].getIterator():      
      let subField: ptr = subFieldValue.addr
      let subFieldWidget = state.toFormField(subField, subFieldName)
      subFieldWidgets[subFieldName] = subFieldWidget
    
    return gui:
      ExpanderRow:
        title = fieldName
        
        for subFieldName in subFieldWidgets.keys:
          insert(subFieldWidgets[subFieldName]) {.addRow.}

  else:
    return state.toPlaceHolderFormField(field, fieldName)

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
