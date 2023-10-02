import std/[options, json, times, macros, strutils, sequtils]
import ./dataentries
import ./adw
import ./widgetutils
import ./guidsl
import ./widgetdef
import ./dataentries
import ./widgets

macro getField*(someType: untyped, fieldName: static string): untyped =
  nnkDotExpr.newTree(someType, ident(fieldName))

proc toFormField(state: auto, fieldName: static string, typ: typedesc[SomeFloat]): Widget =
  return gui:
    NumberEntry(value = state.getField(fieldName)):
      proc changed(value: float) =
        state.getField(fieldName) = value

proc toFormField(state: auto, fieldName: static string, typ: typedesc[SomeInteger]): Widget =
  return gui:
    NumberEntry(value = state.getField(fieldName).float):
      proc changed(value: float) =
        state.getField(fieldName) = value.int

proc toFormField(state: auto, fieldName: static string, typ: typedesc[string]): Widget =
  return gui:
    Entry(text = state.getField(fieldName)):
      proc changed(text: string) =
        state.getField(fieldName) = text

proc toFormField(state: auto, fieldName: static string, typ: typedesc[bool]): Widget =
    return gui:
      Box():
        Switch(state = state.getField(fieldName)) {.vAlign: AlignCenter, expand: false.}:
          proc changed(newVal: bool) =
            state.getField(fieldName) = newVal

proc toFormField(state: auto, fieldName: static string, typ: typedesc[object | ref object | tuple | seq]): Widget =
    return gui:
      Entry(text = $ %*state.getField(fieldName)):
        proc changed(text: string) =
          try:
            state.getField(fieldName) = text.parseJson().to(typ)
          except Exception: discard

proc toFormField[T: enum](state: auto, fieldName: static string, typ: typedesc[T]): Widget =
  let options: seq[string] = T.items.toSeq().mapIt($it)
  return gui:
    DropDown:
      items = options
      selected = state.getField(fieldName).int
      proc select(enumIndex: int) =
        state.getField(fieldName) = enumIndex.T

proc toFormField(state: auto, fieldName: static string, typ: typedesc[DateTime]): Widget =
  return gui:
    Calendar:
      date = state.getField(fieldName)
      proc daySelected(date: DateTime) =
        state.getField(fieldName) = date
  
proc toAutoForm*[T](app: T, ignoreFields: static seq[string]): Widget =
  var fieldWidgets: seq[tuple[name: string, field: AlignedChild[Widget]]] = @[]
  for name, value in app[].fieldPairs:
    when name notin ["app", "viewed"] and name notin ignoreFields:
      let fieldWidget = app.toFormField(name, value.type)
      let alignedWidget = AlignedChild[Widget](widget: fieldWidget)
      fieldWidgets.add((name, alignedWidget))

  result = gui:
    Box(orient = OrientY, spacing = 6, margin = 12):
      for field in fieldWidgets:
        ActionRow {.expand: false.}:
          margin = 6
          title = field.name
          suffixes = @[field.field]

proc toAutoForm*[T](app: T): Widget =
  const ignoreFields: seq[string] = @[]
  return toAutoForm[T](app, ignoreFields = ignoreFields)

export AlignedChild