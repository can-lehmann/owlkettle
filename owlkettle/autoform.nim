import std/[options, times, macros, strformat, strutils, sequtils, typetraits]
import ./dataentries
import ./adw
import ./widgetutils
import ./guidsl
import ./widgetdef
import ./widgets

macro getField*(someType: untyped, fieldName: static string): untyped =
  nnkDotExpr.newTree(someType, ident(fieldName))

proc toFormField[T: SomeNumber](state: auto, fieldName: static string, typ: typedesc[T]): Widget =
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

proc toFormField(state: auto, fieldName: static string, typ: typedesc[auto]): Widget =
  return gui:
    ActionRow:
      title = fieldName
      Label():
        text = fmt"Override `toFormField` for '{$typ.type}'"
        tooltip = fmt"""
          The type '{$typ.type}' must implement a `toFormField` proc.
          `toFormField(
            state: auto, 
            fieldName: static string, 
            typ: typedesc[{$typ.type}]
          ): Widget`
          
          This will override this dummy Widget.
          See other widget example applications for examples.
        """

proc toFormField[T: enum](state: auto, fieldName: static string, typ: typedesc[T]): Widget =
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
  
proc toAutoFormMenu*[T](app: T, sizeRequest: tuple[x,y: int] = (400, 700), ignoreFields: static seq[string]): Widget =
  var fieldWidgets: seq[Widget] = @[]
  for name, value in app[].fieldPairs:
    when name notin ["app", "viewed"] and name notin ignoreFields:
      let fieldWidget = app.toFormField(name, value.type)
      fieldWidgets.add(fieldWidget)
      
  result = gui:
    MenuButton:
      icon = "open-menu"
      Popover():
        Box(orient = OrientY):
          sizeRequest = (400, 700)
          ScrolledWindow:
            PreferencesGroup:
              title = "Fields"
              margin = 12
              
              for field in fieldWidgets:
                insert field


proc toAutoFormMenu*[T](app: T, sizeRequest: tuple[x,y: int] = (400, 700)): Widget =
  const ignoreFields: seq[string] = @[]
  return toAutoFormMenu[T](app, ignoreFields = ignoreFields)