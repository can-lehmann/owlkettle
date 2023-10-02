import std/[options, json, times, macros, strutils, sequtils]
import ./dataentries
import ./adw
import ./widgetutils
import ./guidsl
import ./widgetdef
import ./widgets

macro getField*(someType: untyped, fieldName: static string): untyped =
  nnkDotExpr.newTree(someType, ident(fieldName))

proc `%`*(t: tuple): JsonNode =
  result = newJObject()
  for field, value in t.fieldPairs:
    result.add(field, %value)

## General Fields

proc toFormField(state: auto, fieldName: static string, typ: typedesc[SomeFloat]): Widget =
  return gui:
    ActionRow:
      title = fieldName
      NumberEntry() {.addSuffix.}:
        value = state.getField(fieldName)
        xAlign = 1.0
        maxWidth = 8
        proc changed(value: float) =
          state.getField(fieldName) = value

proc toFormField(state: auto, fieldName: static string, typ: typedesc[SomeInteger]): Widget =
  return gui:
    ActionRow:
      title = fieldName
      NumberEntry() {.addSuffix.}:
        value = state.getField(fieldName).float
        xAlign = 1.0
        maxWidth = 8
        proc changed(value: float) =
          state.getField(fieldName) = value.int

proc toFormField(state: auto, fieldName: static string, typ: typedesc[string]): Widget =
  return gui:
    ActionRow:
      title = fieldName
      Entry() {.addSuffix.}:
        text = state.getField(fieldName)
        proc changed(text: string) =
          state.getField(fieldName) = text

proc toFormField(state: auto, fieldName: static string, typ: typedesc[bool]): Widget =
    return gui:
      ActionRow:
        title = fieldName
        Box() {.addSuffix.}:
          Switch() {.vAlign: AlignCenter, expand: false.}:
            state = state.getField(fieldName)
            proc changed(newVal: bool) =
              state.getField(fieldName) = newVal

proc toFormField(state: auto, fieldName: static string, typ: typedesc[object | ref object | tuple | seq]): Widget =
    return gui:
      ActionRow:
        title = fieldName
        Entry(text = $ %*state.getField(fieldName)) {.addSuffix.}:
          proc changed(text: string) =
            try:
              state.getField(fieldName) = text.parseJson().to(typ)
            except Exception: discard

proc toFormField[T: enum](state: auto, fieldName: static string, typ: typedesc[T]): Widget =
  let options: seq[string] = T.items.toSeq().mapIt($it)
  return gui:
    ComboRow:
      title = "orient"
      items = options
      selected = ord(state.getField(fieldName))
      proc select(enumIndex: int) =
        state.getField(fieldName) = enumIndex.T

proc toFormField(state: auto, fieldName: static string, typ: typedesc[DateTime]): Widget =
  return gui:
    ActionRow:
      title = fieldName
      Calendar {.addSuffix.}:
        date = state.getField(fieldName)
        proc daySelected(date: DateTime) =
          state.getField(fieldName) = date

## Seq Rows
proc toSeqField(state: auto, seqFieldName: static string, index: int, fieldName: static string, typ: typedesc[SomeFloat]): Widget =
  return gui:
    NumberEntry():
      value = state.getField(seqFieldName)[index].getField(fieldName)
      xAlign = 1.0
      maxWidth = 8
      proc changed(value: float) =
        state.getField(seqFieldName)[index].getField(fieldName) = value

proc toSeqField(state: auto, seqFieldName: static string, index: int, fieldName: static string, typ: typedesc[SomeInteger]): Widget =
  return gui:
    NumberEntry():
      value = state.getField(seqFieldName)[index].getField(fieldName).float
      xAlign = 1.0
      maxWidth = 8
      proc changed(value: float) =
        state.getField(seqFieldName)[index].getField(fieldName) = value.int

proc toSeqField(state: auto, seqFieldName: static string, index: int, fieldName: static string, typ: typedesc[string]): Widget =
  return gui:
    Entry():
      text = state.getField(seqFieldName)[index].getField(fieldName)
      proc changed(text: string) =
        state.getField(seqFieldName)[index].getField(fieldName) = text

proc toSeqField(state: auto, seqFieldName: static string, index: int, fieldName: static string, typ: typedesc[bool]): Widget =
  return gui:
    Box():
      Switch() {.vAlign: AlignCenter, expand: false.}:
        state = state.getField(seqFieldName)[index].getField(fieldName)
        proc changed(newVal: bool) =
          state.getField(seqFieldName)[index].getField(fieldName) = newVal

proc toSeqField[T: enum](state: auto, seqFieldName: static string, index: int, fieldName: static string, typ: typedesc[T]): Widget =
  let options: seq[string] = T.items.toSeq().mapIt($it)
  return gui:
    DropDown:
      items = options
      selected = state.getField(seqFieldName)[index].getField(fieldName).int
      proc select(enumIndex: int) =
        state.getField(seqFieldName)[index].getField(fieldName) = enumIndex.T
        
proc toSeqField(state: auto, seqFieldName: static string, index: int, fieldName: static string, typ: typedesc[DateTime]): Widget =
  return gui:
    Calendar:
      date = state.getField(seqFieldName)[index].getField(fieldName)
      proc daySelected(date: DateTime) =
        state.getField(seqFieldName)[index].getField(fieldName) = date

template myFieldPairs(x: auto) =
  static: echo $x.type, " ", x is ref object," ",  x is object," ",  x is tuple, " ", x is ref tuple
  when x is ref object:
    x[].fieldPairs
  elif x is object:
    x.fieldPairs
  elif x is tuple:
    x.fieldPairs
  elif x is ref tuple:
    x[].fieldPairs
  else:
    const t = $x.type
    {.error: "Not sure what iterator to apply to '" & $t &"'".}

proc createEntryRow[T: object | ref object](state: auto, fieldName: static string, index: int): Widget =
  var fieldWidgets: seq[AlignedChild[Widget]] = @[]
  for entryFieldName, entryFieldValue in state.getField(fieldName)[index].fieldPairs:
    when entryFieldValue.type isnot Option:
      let fieldWidget: Widget = state.toSeqField(fieldName, index, entryFieldName, entryFieldValue.type)
      fieldWidgets.add(AlignedChild[Widget](widget: fieldWidget))

  echo "For ", state.getField(fieldName)[index].type, ": ", fieldWidgets.repr
  
  return gui:
    ActionRow:
      title = fieldName
      suffixes = fieldWidgets

proc toFormField[T: object | ref object](state: auto, fieldName: static string, typ: typedesc[seq[T]]): Widget =
  var fieldWidgets: seq[AlignedChild[Widget]] = @[]
  for index, entry in state.getField(fieldName):
    let entryRow = createEntryRow[T](state, fieldName, index)
    fieldWidgets.add(AlignedChild[Widget](widget: entryRow))
  
  let adderRow = gui:
    ListBoxRow:
      Button:
        icon = "list-add-symbolic"
        style = [ButtonFlat]
        proc clicked() =
          state.getField(fieldName).add(T())
  fieldWidgets.add(AlignedChild[Widget](widget: adderRow))
  
  return gui:
    ExpanderRow:
      title = fieldName
      rows = fieldWidgets
  
proc toAutoForm*[T](app: T, ignoreFields: static seq[string]): Widget =
  var fieldWidgets: seq[Widget] = @[]
  for name, value in app[].fieldPairs:
    when name notin ["app", "viewed"] and name notin ignoreFields:
      let fieldWidget = app.toFormField(name, value.type)
      fieldWidgets.add(fieldWidget)
      
  result = gui:
    Box(orient = OrientY):
      sizeRequest = (300, -1)
      
      HeaderBar {.expand: false.}:
        showTitleButtons = false
      
      ScrolledWindow:
        PreferencesGroup:
          title = "Fields"
          margin = 12
          
          for field in fieldWidgets:
            insert field


proc toAutoForm*[T](app: T): Widget =
  const ignoreFields: seq[string] = @[]
  return toAutoForm[T](app, ignoreFields = ignoreFields)

export AlignedChild