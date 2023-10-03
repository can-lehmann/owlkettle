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

proc toFormField(state: auto, fieldName: static string, typ: typedesc[tuple[x,y: int]]): Widget =
  ## toFormField proc specifically for the tuple type of sizeRequest
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