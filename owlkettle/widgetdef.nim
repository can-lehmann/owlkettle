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

# Macros used to define new widgets

import std/[macros, strutils, tables]
when defined(nimPreviewSlimSystem):
  import std/assertions
import gtk, common

type
  Widget* = ref object of RootObj
    app*: Viewable
  
  WidgetState* = ref object of RootObj
    app*: Viewable
  
  Viewable* = ref object of WidgetState
    viewed: WidgetState
  
  Renderable* = ref object of WidgetState
    internalWidget*: GtkWidget
  
  EventObj*[T] = object
    app*: Viewable
    callback*: T
    handler*: culong
    widget*: Renderable
  
  Event*[T] = ref EventObj[T]

method build*(widget: Widget): WidgetState {.base.} = discard
method update*(widget: Widget, state: WidgetState): WidgetState {.base.} = discard
method view*(viewable: Viewable): Widget {.base.} = discard
method read*(state: WidgetState) {.base.} = discard
method assignApp*(widget: Widget, app: Viewable) {.base.} = discard

method read(state: Viewable) =
  if not state.viewed.isNil:
    state.viewed.read()

proc assignApp*[T](items: seq[T], app: Viewable) =
  mixin assignApp
  for item in items:
    item.assignApp(app)

proc unwrapRenderable*(state: WidgetState): Renderable =
  var cur = state
  while cur of Viewable:
    cur = Viewable(cur).viewed
  result = Renderable(cur)

proc unwrapInternalWidget*(state: WidgetState): GtkWidget =
  result = state.unwrapRenderable().internalWidget

proc redraw*(viewable: Viewable): bool =
  ## Redraws the given viewable. Returns true if viewable.viewed changed.
  let widget = viewable.view()
  widget.assignApp(viewable.app)
  let newWidget = widget.update(viewable.viewed)
  if not newWidget.isNil:
    viewable.viewed = newWidget
    result = true

type
  WidgetKind = enum WidgetRenderable, WidgetViewable
  
  HookKind = enum
    HookProperty, HookAfterBuild, HookUpdate,
    HookBuild, HookBeforeBuild,
    HookConnectEvents, HookDisconnectEvents,
    HookRead
  
  Field = object
    name: string
    typ: NimNode
    default: NimNode
    hooks: array[HookKind, NimNode]
    isInternal: bool
    lineInfo: NimNode
    doc: string
  
  EventDef = object
    name: string
    signature: NimNode
    doc: string
  
  Property = object
    name: string
    typ: NimNode
    default: NimNode
    doc: string
  
  Adder = object
    name: string
    props: seq[Property]
    body: NimNode
    doc: string
  
  WidgetDef = object
    name: string
    kind: WidgetKind
    base: string
    events: seq[EventDef]
    fields: seq[Field]
    hooks: array[HookKind, seq[NimNode]]
    setters: seq[Property]
    adders: seq[Adder]
    types: seq[NimNode]
    examples: seq[NimNode]
    doc: string

proc has(field: Field): NimNode =
  result = ident("has" & capitalizeAscii(field.name))
  result.copyLineInfo(field.lineInfo)

proc value(field: Field): NimNode =
  result = ident("val" & capitalizeAscii(field.name))
  result.copyLineInfo(field.lineInfo)

proc stateName(def: WidgetDef): string = def.name & "State"

proc widgetBase(def: WidgetDef): NimNode =
  if def.base.len == 0:
    result = bindSym("Widget")
  else:
    result = ident(def.base)

proc stateBase(def: WidgetDef): NimNode =
  if def.base.len == 0:
    result = [
      WidgetRenderable: bindSym("Renderable"),
      WidgetViewable: bindSym("Viewable")
    ][def.kind]
  else:
    result = ident(def.base & "State")

proc parseName(name: NimNode, def: var WidgetDef) =
  template invalidName() =
    error(name.repr & " is not a valid widget name")
  
  case name.kind:
    of nnkIdent, nnkSym:
      def.name = name.strVal
    of nnkInfix:
      if name[0].eqIdent("of"):
        name[1].parseName(def)
        if not name[2].isName:
          error("Expected identifier after of in widget name, but got " & $name[2].kind)
        def.base = name[2].strVal
      else:
        invalidName()
    else: invalidName()

proc parseHookKind(name: string): HookKind =
  case nimIdentNormalize(name):
    of "property": HookProperty
    of "build": HookBuild
    of "update": HookUpdate
    of "beforebuild": HookBeforeBuild
    of "afterbuild": HookAfterBuild
    of "connectevents": HookConnectEvents
    of "disconnectevents": HookDisconnectEvents
    of "read": HookRead
    else:
      error(name & " is not a valid hook")
      HookProperty

proc parseHookKinds(node: NimNode): seq[HookKind] =
  case node.kind:
    of nnkIdent, nnkSym:
      result = @[parseHookKind(node.strVal)]
    of nnkTupleConstr:
      for child in node.children:
        result.add(parseHookKinds(child))
    else:
      error("Unable to parse hook kinds from " & $node.kind)

proc extractDocComment(node: NimNode): string =
  let
    str = node.repr
    pos = str.find("##")
  if pos == -1:
    return ""
  var newline = str.find("\n", pos)
  if newline == -1:
    newline = str.len - 1
  result = str[(pos + 2)..newline].strip()

proc parseBody(body: NimNode, def: var WidgetDef) =
  assert def.fields.len == 0
  var fieldLookup = newTable[string, int]()
  for child in body:
    case child.kind:
      of nnkCommentStmt:
        def.doc &= child.strVal & "\n"
      of nnkProcDef:
        assert child.name.isName
        def.events.add(EventDef(
          name: child.name.strVal,
          signature: child.params,
          doc: child.extractDocComment()
        ))
      of nnkCallKinds:
        assert not child[0].unwrapName().isNil
        if child[0].eqIdent("hooks"):
          child[^1].expectKind(nnkStmtList)
          var hooks: array[HookKind, NimNode]
          for hookDef in child[^1]:
            hookDef[^1].expectKind(nnkStmtList)
            for kind in parseHookKinds(hookDef[0]):
              hooks[kind] = hookDef[^1]
          if child.len == 2:
            for kind, body in hooks:
              if not body.isNil:
                def.hooks[kind].add(body)
          else:
            assert child[1].isName
            let fieldName = nimIdentNormalize(child[1].strVal)
            if fieldName notin fieldLookup:
              error(child[1].repr & " is not a field of " & def.name)
            let fieldId = fieldLookup[fieldName]
            for kind, body in hooks:
              if not body.isNil:
                def.fields[fieldId].hooks[kind] = body
        elif child[0].eqIdent("example"):
          child[^1].expectKind(nnkStmtList)
          def.examples.add(child[1])
        elif child[0].eqIdent("setter"):
          child[^1].expectKind(nnkStmtList)
          def.setters.add(Property(
            name: child[1].strVal,
            typ: child[2][0],
            doc: child[2].extractDocComment()
          ))
        elif child[0].eqIdent("adder"):
          var adder = Adder()
          
          if child[1].isName():
            adder.name = child[1].strVal
          else:
            child[1].expectKind(nnkPragmaExpr)
            adder.name = child[1][0].strVal
            for prop in child[1][1]:
              prop.expectKind(nnkExprColonExpr)
              adder.props.add(Property(
                name: prop[0].strVal,
                default: prop[1]
              ))
          
          if child[^1].kind == nnkStmtList:
            adder.body = child[^1]
          
          for stmt in child[^1]:
            if stmt.kind == nnkCommentStmt:
              adder.doc &= stmt.strVal & "\n"
          
          def.adders.add(adder)
        else:
          child[^1].expectKind(nnkStmtList)
          let name = child[0].unwrapName()
          var field = Field(
            name: name.strVal,
            isInternal: not child[0].findPragma("internal").isNil,
            lineInfo: name,
            doc: child[1].extractDocComment()
          )
          case child[1][0].kind:
            of nnkAsgn:
              field.typ = child[1][0][0]
              field.default = child[1][0][1]
            else:
              field.typ = child[1][0]
          def.fields.add(field)
          fieldLookup[nimIdentNormalize(field.name)] = def.fields.len - 1
      of nnkDiscardStmt: discard
      of nnkTypeSection:
        for typeDef in child:
          def.types.add(typeDef)
      else:
        error("Unable to parse " & $child.kind & " in widget body.")

proc parseWidgetDef(kind: WidgetKind, name, body: NimNode): WidgetDef =
  result.kind = kind
  name.parseName(result)
  body.parseBody(result)


proc genIdentDefs(event: EventDef): NimNode =
  result = newTree(nnkIdentDefs, [
    ident(event.name).newExport(),
    newBracketExpr(
      bindSym("Event"),
      newTree(nnkProcTy, event.signature, newEmptyNode())
    ),
    newEmptyNode()
  ])

proc genWidget(def: WidgetDef): NimNode =
  result = newTree(nnkRecList)
  for field in def.fields:
    result.add(newTree(nnkIdentDefs, [
      field.has().newExport(), bindSym("bool"), newEmptyNode()
    ]))
    result.add(newTree(nnkIdentDefs, [
      field.value().newExport(), field.typ, newEmptyNode()
    ]))
  for event in def.events:
    result.add(event.genIdentDefs())
  result = newTree(nnkTypeDef, [
    ident(def.name),
    newEmptyNode(),
    newTree(nnkRefTy, [
      newTree(nnkObjectTy, [
        newEmptyNode(),
        newTree(nnkOfInherit, def.widgetBase),
        result
      ])
    ])
  ])

proc substituteWidgets(node: NimNode): NimNode =
  case node.kind:
    of nnkSym, nnkIdent:
      if node.eqIdent("Widget"):
        result = bindSym("WidgetState")
      else:
        result = node
    else:
      result = newNimNode(node.kind)
      for child in node:
        result.add(substituteWidgets(child))

proc genState(def: WidgetDef): NimNode =
  result = newTree(nnkRecList)
  for field in def.fields:
    var fieldType = field.typ
    if def.kind == WidgetRenderable:
      fieldType = substituteWidgets(fieldType)
    result.add(newTree(nnkIdentDefs, [
      ident(field.name).newExport(), fieldType, newEmptyNode()
    ]))
  for event in def.events:
    result.add(event.genIdentDefs())
  result = newTree(nnkTypeDef, [
    ident(def.stateName),
    newEmptyNode(),
    newTree(nnkRefTy, [
      newTree(nnkObjectTy, [
        newEmptyNode(),
        newTree(nnkOfInherit, def.stateBase),
        result
      ])
    ])
  ])

proc genBuildState(def: WidgetDef): NimNode =
  let (state, widget) = (ident("state"), ident("widget"))
  result = newStmtList()
  
  if def.base.len > 0:
    result.add(newCall(ident("buildState"), state, newCall(def.widgetBase, widget)))
  
  for body in def.hooks[HookBuild]:
    result.add(body)
  
  for field in def.fields:
    if not field.hooks[HookBuild].isNil:
      result.add(newBlockStmt(field.hooks[HookBuild].copyNimTree()))
    else:
      var cond = newTree(nnkIfStmt, [
        newTree(nnkElifBranch, [
          newDotExpr(widget, field.has),
          newStmtList(newAssignment(
            newDotExpr(state, field.name),
            newDotExpr(widget, field.value)
          ))
        ])
      ])
      if field.default != nil:
        cond.add(newTree(nnkElse, newStmtList(newAssignment(
          newDotExpr(state, field.name),
          field.default
        ))))
      result.add(cond)
      if not field.hooks[HookProperty].isNil:
        result.add(newBlockStmt(field.hooks[HookProperty].copyNimTree()))
  for event in def.events:
    result.add(newAssignment(
      newDotExpr(state, event.name),
      newDotExpr(widget, event.name)
    ))
  for body in def.hooks[HookConnectEvents]:
    result.add(newBlockStmt(body.copyNimTree()))
  
  result = newProc(
    procType=nnkProcDef,
    name=ident("buildState"),
    params=[newEmptyNode(),
      newIdentDefs(state, ident(def.stateName)),
      newIdentDefs(widget, ident(def.name))
    ],
    body = result
  )

proc genBuild(def: WidgetDef): NimNode =
  let (state, widget) = (ident("state"), ident("widget"))
  result = newStmtList(newVarStmt(state, newCall(ident(def.stateName))))
  for body in def.hooks[HookBeforeBuild]:
    result.add(body)
  result.add: quote:
    `state`.app = `widget`.app
  
  if def.kind == WidgetViewable:
    result.add: quote:
      if isNil(`state`.app):
        `state`.app = Viewable(`state`)
  
  result.add(newCall(ident("buildState"), state, widget))
  
  if def.kind == WidgetViewable:
    result.add: quote:
      let viewedWidget = `state`.view()
      viewedWidget.assignApp(`state`.app)
      `state`.viewed = viewedWidget.build()
  
  for body in def.hooks[HookAfterBuild]:
    result.add(body)
  
  result.add(newTree(nnkReturnStmt, state))
  result = newProc(
    procType=nnkMethodDef,
    name=ident("build"),
    params=[bindSym("WidgetState"),
      newIdentDefs(widget, ident(def.name)),
    ],
    body = result
  )

proc genUpdateState(def: WidgetDef): NimNode =
  let (widget, state) = (ident("widget"), ident("state"))
  result = newStmtList()
  
  if def.base.len > 0:
    result.add(newCall(ident("updateState"), state, newCall(def.widgetBase, widget)))
  
  for hook in def.hooks[HookDisconnectEvents]:
    result.add(hook.copyNimTree())
  for field in def.fields:
    if not field.hooks[HookUpdate].isNil:
      result.add(newBlockStmt(field.hooks[HookUpdate]))
    else:
      let update = newStmtList(newAssignment(
        newDotExpr(state, field.name),
        newDotExpr(widget, field.value)
      ))
      var cond = newDotExpr(widget, field.has)
      if not field.hooks[HookProperty].isNil:
        update.add(field.hooks[HookProperty].copyNimTree())
        cond = newCall(bindSym("and"), [
          cond,
          newCall(bindSym("!="), [
            newDotExpr(state, field.name),
            newDotExpr(widget, field.value)
          ])
        ])
      result.add(newTree(nnkIfStmt, newTree(nnkElifBranch, [
        cond, update
      ])))
  for event in def.events:
    result.add(newAssignment(
      newDotExpr(state, event.name),
      newDotExpr(widget, event.name)
    ))
  for hook in def.hooks[HookUpdate]:
    result.add(newBlockStmt(hook.copyNimTree()))
  for hook in def.hooks[HookConnectEvents]:
    result.add(newBlockStmt(hook.copyNimTree()))
  
  result = newProc(
    procType=nnkProcDef,
    name=ident("updateState"),
    params=[newEmptyNode(),
      newIdentDefs(state, ident(def.stateName)),
      newIdentDefs(widget, ident(def.name))
    ],
    body = result
  )

proc genUpdate(def: WidgetDef): NimNode =
  let
    widgetTyp = ident(def.name)
    stateTyp = ident(def.stateName)
    updateState = ident("updateState")
    isViewable = newLit(def.kind == WidgetViewable)
  result = quote:
    method update(widget: `widgetTyp`, widgetState: WidgetState): WidgetState =
      let typeId {.global.} = block:
        let state = `stateTyp`()
        cast[ptr pointer](state)[]
      if cast[ptr pointer](widgetState)[] != typeId:
        return widget.build()
      let state = `stateTyp`(widgetState)
      state.app = widget.app
      read(state)
      `updateState`(state, widget)
      when `isViewable`:
        if redraw(state):
          result = state

proc genAssignAppEvents(def: WidgetDef): NimNode =
  let (widget, app) = (ident("widget"), ident("app"))
  result = newStmtList()
  
  if def.base.len > 0:
    result.add(newCall(ident("assignAppEvents"), newCall(def.widgetBase, widget), app))
  
  for event in def.events:
    let event = widget.newDotExpr(event.name)
    result.add(newTree(nnkIfStmt, newTree(nnkElifBranch, [
      newCall(bindSym("not"), newCall(bindSym("isNil"), event)),
      newStmtList(newAssignment(
        event.newDotExpr("app"), app
      ))
    ])))
  
  result = newProc(
    procType=nnkProcDef,
    name=ident("assignAppEvents"),
    params=[newEmptyNode(),
      newIdentDefs(widget, ident(def.name)),
      newIdentDefs(app, bindSym("Viewable"))
    ],
    body = result
  )

proc genAssignApp(def: WidgetDef): NimNode =
  let widgetTyp = ident(def.name)  
  result = quote:
    method assignApp(widget: `widgetTyp`, app: Viewable) =
      widget.app = app
      assignAppEvents(widget, app)

proc genRead(def: WidgetDef): NimNode =
  let
    state = ident("state")
    stateTyp = ident(def.stateName)
    body = newStmtList()
  
  if def.base.len > 0:
    body.add(newCall(bindSym("procCall"),
      newCall(ident("read"), newCall(ident(def.base & "State"), state))
    ))
  
  for field in def.fields:
    if not field.hooks[HookRead].isNil:
      body.add(field.hooks[HookRead].copyNimTree())
  
  result = quote:
    method read(`state`: `stateTyp`) =
      `body`

proc formatReference(widget: WidgetDef): string =
  result = "## " & widget.name & "\n\n"
  result &= "```nim\n"
  result &= ["renderable", "viewable"][ord(widget.kind)] & " "
  result &= widget.name
  if widget.base.len > 0:
    result &= " of " & widget.base
  result &= "\n```\n\n"
  if widget.doc.len > 0:
    result &= widget.doc.strip()
    result &= "\n\n"
  if widget.fields.len > 0 or widget.base.len > 0:
    result &= "###### Fields\n\n"
    if widget.base.len > 0:
      result &= "- All fields from [" & widget.base & "](#" & widget.base & ")\n"
    for field in widget.fields:
      if not field.isInternal:
        result &= "- `" & field.name & ": " & field.typ.repr
        if not field.default.isNil:
          result &= " = " & field.default.repr
        result &= "`"
        if field.doc.len > 0:
          result &= " " & field.doc
        result &= "\n"
    result &= "\n"
  if widget.setters.len > 0:
    result &= "###### Setters\n\n"
    for setter in widget.setters:
      result &= "- `" & setter.name & ": " & setter.typ.repr & "`"
      if setter.doc.len > 0:
        result &= " " & setter.doc
      result &= "\n"
    result &= "\n"
  if widget.events.len > 0:
    result &= "###### Events\n\n"
    for event in widget.events:
      result &= "- " & event.name & ": `proc " & event.signature.repr & "`"
      if event.doc.len > 0:
        result &= " " & event.doc
      result &= "\n"
    result &= "\n"
  if widget.adders.len > 0:
    result &= "###### Adders\n\n"
    if widget.base.len > 0:
      result &= "- All adders from [" & widget.base & "](#" & widget.base & ")\n"
    for adder in widget.adders:
      result &= "- `" & adder.name & "`"
      if adder.doc.len > 0:
        result &= " " & adder.doc
      result &= "\n"
      for prop in adder.props:
        result &= "  - `" & prop.name & " = " & prop.default.repr & "`\n"
    result &= "\n"
  if widget.examples.len > 0:
    result &= "###### Example\n\n"
    for example in widget.examples:
      result &= "```nim" & example.repr & "\n```\n\n"

proc genDocs(widget: WidgetDef): NimNode {.used.} =
  let reference = widget.formatReference()
  result = quote:
    when isMainModule:
      echo `reference`

proc genAdders(widget: WidgetDef): NimNode =
  result = newStmtList()
  for adder in widget.adders:
    if adder.body.isNil:
      continue
    
    var params = @[newEmptyNode(),
      newIdentDefs(ident("widget"), ident(widget.name)),
      newIdentDefs(ident("child"), bindSym("Widget"))
    ]
    
    for prop in adder.props:
      params.add(newTree(nnkIdentDefs,
        ident(prop.name), newEmptyNode(), prop.default
      ))
    
    result.add(newProc(
      name = ident(adder.name).newExport(),
      params = params,
      body = adder.body
    ))

proc gen(widget: WidgetDef): NimNode =
  result = newStmtList([
    newTree(nnkTypeSection, @[
      widget.genWidget(),
      widget.genState()
    ] & widget.types),
    widget.genBuildState(),
    widget.genBuild(),
    widget.genUpdateState(),
    widget.genUpdate(),
    widget.genAssignAppEvents(),
    widget.genAssignApp(),
    widget.genRead(),
    widget.genAdders()
  ])
  when defined(owlkettleDocs):
    result.add(widget.genDocs())

macro renderable*(name, body: untyped): untyped =
  let widget = parseWidgetDef(WidgetRenderable, name, body)
  result = widget.gen()
  when defined owlkettleDebug:
    echo result.repr

macro viewable*(name, body: untyped): untyped =
  let widget = parseWidgetDef(WidgetViewable, name, body)
  result = widget.gen()
  when defined owlkettleDebug:
    echo result.repr
