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
import gtk, common

type
  Widget* = ref object of RootObj
    app*: Viewable
  
  WidgetState* = ref object of RootObj
    app*: Viewable
  
  Viewable* = ref object of WidgetState
    viewed: WidgetState
  
  Renderable* = ref object of WidgetState
    internal_widget*: GtkWidget
  
  EventObj*[T] = object
    app*: Viewable
    callback*: T
    handler*: culong
  
  Event*[T] = ref EventObj[T]

method build*(widget: Widget): WidgetState {.base.} = discard
method update*(widget: Widget, state: WidgetState): WidgetState {.base.} = discard
method view*(viewable: Viewable): Widget {.base.} = discard
method read*(state: WidgetState) {.base.} = discard
method assign_app*(widget: Widget, app: Viewable) {.base.} = discard

method read(state: Viewable) =
  if not state.viewed.is_nil:
    state.viewed.read()

proc assign_app*[T](items: seq[T], app: Viewable) =
  mixin assign_app
  for item in items:
    item.assign_app(app)

proc unwrap_renderable*(state: WidgetState): Renderable =
  var cur = state
  while cur of Viewable:
    cur = Viewable(cur).viewed
  result = Renderable(cur)

proc redraw*(viewable: Viewable) =
  let widget = viewable.view()
  widget.assign_app(viewable.app)
  let new_widget = widget.update(viewable.viewed)
  if not new_widget.is_nil:
    viewable.viewed = new_widget

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
  
  EventDef = object
    name: string
    signature: NimNode
  
  WidgetDef = object
    name: string
    kind: WidgetKind
    base: string
    events: seq[EventDef]
    fields: seq[Field]
    hooks: array[HookKind, seq[NimNode]]
    types: seq[NimNode]

proc state_name(def: WidgetDef): string = def.name & "State"

proc widget_base(def: WidgetDef): NimNode =
  if def.base.len == 0:
    result = bind_sym("Widget")
  else:
    result = ident(def.base)

proc state_base(def: WidgetDef): NimNode =
  if def.base.len == 0:
    result = [
      WidgetRenderable: bind_sym("Renderable"),
      WidgetViewable: bind_sym("Viewable")
    ][def.kind]
  else:
    result = ident(def.base & "State")

proc parse_name(name: NimNode, def: var WidgetDef) =
  template invalid_name() =
    error(name.repr & " is not a valid widget name")
  
  case name.kind:
    of nnkIdent, nnkSym:
      def.name = name.str_val
    of nnkInfix:
      if name[0].is_name("of"):
        name[1].parse_name(def)
        if not name[2].is_name:
          error("Expected identifier after of in widget name, but got " & $name[2].kind)
        def.base = name[2].str_val
      else:
        invalid_name()
    else: invalid_name()

proc parse_hook_kind(name: string): HookKind =
  case nim_ident_normalize(name):
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

proc parse_hook_kinds(node: NimNode): seq[HookKind] =
  case node.kind:
    of nnkIdent, nnkSym:
      result = @[parse_hook_kind(node.str_val)]
    of nnkTupleConstr:
      for child in node.children:
        result.add(parse_hook_kinds(child))
    else:
      error("Unable to parse hook kinds from " & $node.kind)

proc parse_body(body: NimNode, def: var WidgetDef) =
  assert def.fields.len == 0
  var field_lookup = new_table[string, int]()
  for child in body:
    case child.kind:
      of nnkProcDef:
        assert child.name.is_name
        def.events.add(EventDef(
          name: child.name.str_val,
          signature: child.params
        ))
      of nnkCallKinds:
        assert child[0].is_name
        child[^1].expect_kind(nnkStmtList)
        if child[0].is_name("hooks"):
          var hooks: array[HookKind, NimNode]
          for hook_def in child[^1]:
            hook_def[^1].expect_kind(nnkStmtList)
            for kind in parse_hook_kinds(hook_def[0]):
              hooks[kind] = hook_def[^1]
          if child.len == 2:
            for kind, body in hooks:
              if not body.is_nil:
                def.hooks[kind].add(body)
          else:
            assert child[1].is_name
            let field_name = nim_ident_normalize(child[1].str_val)
            if field_name notin field_lookup:
              error(child[1].repr & " is not a field of " & def.name)
            let field_id = field_lookup[field_name]
            for kind, body in hooks:
              if not body.is_nil:
                def.fields[field_id].hooks[kind] = body
        else:
          var field = Field(name: child[0].str_val)
          case child[1][0].kind:
            of nnkAsgn:
              field.typ = child[1][0][0]
              field.default = child[1][0][1]
            else:
              field.typ = child[1][0]
          def.fields.add(field)
          field_lookup[nim_ident_normalize(field.name)] = def.fields.len - 1
      of nnkDiscardStmt: discard
      of nnkTypeSection:
        for type_def in child:
          def.types.add(type_def)
      else:
        error("Unable to parse " & $child.kind & " in widget body.")

proc parse_widget_def(kind: WidgetKind, name, body: NimNode): WidgetDef =
  result.kind = kind
  name.parse_name(result)
  body.parse_body(result)

proc gen_ident_defs(event: EventDef): NimNode =
  result = new_tree(nnkIdentDefs, [
    ident(event.name).new_export(),
    new_bracket_expr(
      bind_sym("Event"),
      new_tree(nnkProcTy, [event.signature, new_empty_node()])
    ),
    new_empty_node()
  ])

proc gen_widget(def: WidgetDef): NimNode =
  result = new_tree(nnkRecList)
  for field in def.fields:
    result.add(new_tree(nnkIdentDefs, [
      ident("has_" & field.name).new_export(), bind_sym("bool"), new_empty_node()
    ]))
    result.add(new_tree(nnkIdentDefs, [
      ident("val_" & field.name).new_export(), field.typ, new_empty_node()
    ]))
  for event in def.events:
    result.add(event.gen_ident_defs())
  result = new_tree(nnkTypeDef, [
    ident(def.name),
    new_empty_node(),
    new_tree(nnkRefTy, [
      new_tree(nnkObjectTy, [
        new_empty_node(),
        new_tree(nnkOfInherit, def.widget_base),
        result
      ])
    ])
  ])

proc substitute_widgets(node: NimNode): NimNode =
  case node.kind:
    of nnkSym, nnkIdent:
      if nim_ident_normalize(node.str_val) == "Widget":
        result = bind_sym("WidgetState")
      else:
        result = node
    else:
      result = new_nim_node(node.kind)
      for child in node:
        result.add(substitute_widgets(child))

proc gen_state(def: WidgetDef): NimNode =
  result = new_tree(nnkRecList)
  for field in def.fields:
    var field_type = field.typ
    if def.kind == WidgetRenderable:
      field_type = substitute_widgets(field_type)
    result.add(new_tree(nnkIdentDefs, [
      ident(field.name).new_export(), field_type, new_empty_node()
    ]))
  for event in def.events:
    result.add(event.gen_ident_defs())
  result = new_tree(nnkTypeDef, [
    ident(def.state_name),
    new_empty_node(),
    new_tree(nnkRefTy, [
      new_tree(nnkObjectTy, [
        new_empty_node(),
        new_tree(nnkOfInherit, def.state_base),
        result
      ])
    ])
  ])

proc gen_build_state(def: WidgetDef): NimNode =
  let (state, widget) = (ident("state"), ident("widget"))
  result = new_stmt_list()
  
  if def.base.len > 0:
    result.add(new_call(ident("build_state"), state, new_call(def.widget_base, widget)))
  
  for field in def.fields:
    if not field.hooks[HookBuild].is_nil:
      result.add(field.hooks[HookBuild].clone())
    else:
      var cond = new_tree(nnkIfStmt, [
        new_tree(nnkElifBranch, [
          new_dot_expr(widget, "has_" & field.name),
          new_stmt_list(new_assignment(
            new_dot_expr(state, field.name),
            new_dot_expr(widget, "val_" & field.name)
          ))
        ])
      ])
      if field.default != nil:
        cond.add(new_tree(nnkElse, new_stmt_list(new_assignment(
          new_dot_expr(state, field.name),
          field.default
        ))))
      result.add(cond)
      if not field.hooks[HookProperty].is_nil:
        result.add(field.hooks[HookProperty].clone())
  for event in def.events:
    result.add(new_assignment(
      new_dot_expr(state, event.name),
      new_dot_expr(widget, event.name)
    ))
  for body in def.hooks[HookConnectEvents]:
    result.add(body.clone())
  
  result = new_proc(
    proc_type=nnkProcDef,
    name=ident("build_state"),
    params=[new_empty_node(),
      new_ident_defs(state, ident(def.state_name)),
      new_ident_defs(widget, ident(def.name))
    ],
    body = result
  )

proc gen_build(def: WidgetDef): NimNode =
  let (state, widget) = (ident("state"), ident("widget"))
  result = new_stmt_list(new_var_stmt(state, new_call(ident(def.state_name))))
  for body in def.hooks[HookBeforeBuild]:
    result.add(body)
  result.add: quote:
    `state`.app = `widget`.app
  if def.kind == WidgetViewable:
    result.add: quote:
      if is_nil(`state`.app):
        `state`.app = Viewable(`state`)
  result.add(new_call(ident("build_state"), state, widget))
  for body in def.hooks[HookAfterBuild]:
    result.add(body)
  if def.kind == WidgetViewable:
    result.add: quote:
      let viewed_widget = `state`.view()
      viewed_widget.assign_app(`state`.app)
      `state`.viewed = viewed_widget.build()
  result.add(new_tree(nnkReturnStmt, state))
  result = new_proc(
    proc_type=nnkMethodDef,
    name=ident("build"),
    params=[bind_sym("WidgetState"),
      new_ident_defs(widget, ident(def.name)),
    ],
    body = result
  )

proc gen_update_state(def: WidgetDef): NimNode =
  let (widget, state) = (ident("widget"), ident("state"))
  result = new_stmt_list()
  
  if def.base.len > 0:
    result.add(new_call(ident("update_state"), state, new_call(def.widget_base, widget)))
  
  for hook in def.hooks[HookDisconnectEvents]:
    result.add(hook.clone())
  for field in def.fields:
    if not field.hooks[HookUpdate].is_nil:
      result.add(field.hooks[HookUpdate])
    else:
      let update = new_stmt_list(new_assignment(
        new_dot_expr(state, field.name),
        new_dot_expr(widget, "val_" & field.name)
      ))
      var cond = new_dot_expr(widget, "has_" & field.name)
      if not field.hooks[HookProperty].is_nil:
        update.add(field.hooks[HookProperty].clone())
        cond = new_call(bind_sym("and"), [
          cond,
          new_call(bind_sym("!="), [
            new_dot_expr(state, field.name),
            new_dot_expr(widget, "val_" & field.name)
          ])
        ])
      result.add(new_tree(nnkIfStmt, new_tree(nnkElifBranch, [
        cond, update
      ])))
  for event in def.events:
    result.add(new_assignment(
      new_dot_expr(state, event.name),
      new_dot_expr(widget, event.name)
    ))
  for hook in def.hooks[HookUpdate]:
    result.add(hook.clone())
  for hook in def.hooks[HookConnectEvents]:
    result.add(hook.clone())
  
  result = new_proc(
    proc_type=nnkProcDef,
    name=ident("update_state"),
    params=[new_empty_node(),
      new_ident_defs(state, ident(def.state_name)),
      new_ident_defs(widget, ident(def.name))
    ],
    body = result
  )

proc gen_update(def: WidgetDef): NimNode =
  let
    widget_typ = ident(def.name)
    state_typ = ident(def.state_name)
    update_state = ident("update_state")
    is_viewable = new_lit(def.kind == WidgetViewable)
  result = quote:
    method update(widget: `widget_typ`, widget_state: WidgetState): WidgetState =
      if not (widget_state of `state_typ`):
        return widget.build()
      let state = `state_typ`(widget_state)
      state.app = widget.app
      `update_state`(state, widget)
      when `is_viewable`:
        redraw(state)

proc gen_assign_app_events(def: WidgetDef): NimNode =
  let (widget, app) = (ident("widget"), ident("app"))
  result = new_stmt_list()
  
  if def.base.len > 0:
    result.add(new_call(ident("assign_app_events"), new_call(def.widget_base, widget), app))
  
  for event in def.events:
    let event = widget.new_dot_expr(event.name)
    result.add(new_tree(nnkIfStmt, new_tree(nnkElifBranch, [
      new_call(bind_sym("not"), new_call(bind_sym("is_nil"), event)),
      new_stmt_list(new_assignment(
        event.new_dot_expr("app"), app
      ))
    ])))
  
  result = new_proc(
    proc_type=nnkProcDef,
    name=ident("assign_app_events"),
    params=[new_empty_node(),
      new_ident_defs(widget, ident(def.name)),
      new_ident_defs(app, bind_sym("Viewable"))
    ],
    body = result
  )

proc gen_assign_app(def: WidgetDef): NimNode =
  let widget_typ = ident(def.name)  
  result = quote:
    method assign_app(widget: `widget_typ`, app: Viewable) =
      widget.app = app
      assign_app_events(widget, app)

proc gen_read(def: WidgetDef): NimNode =
  let
    state = ident("state")
    state_typ = ident(def.state_name)
    body = new_stmt_list()
  
  if def.base.len > 0:
    body.add(new_call(bind_sym("proc_call"),
      new_call(ident("read"), new_call(ident(def.base & "State"), state))
    ))
  
  for field in def.fields:
    if not field.hooks[HookRead].is_nil:
      body.add(field.hooks[HookRead].clone())
  
  result = quote:
    method read(`state`: `state_typ`) =
      `body`

proc gen(widget: WidgetDef): NimNode =
  result = new_stmt_list([
    new_tree(nnkTypeSection, @[
      widget.gen_widget(),
      widget.gen_state()
    ] & widget.types),
    widget.gen_build_state(),
    widget.gen_build(),
    widget.gen_update_state(),
    widget.gen_update(),
    widget.gen_assign_app_events(),
    widget.gen_assign_app(),
    widget.gen_read()
  ])

macro renderable*(name, body: untyped): untyped =
  let widget = parse_widget_def(WidgetRenderable, name, body)
  result = widget.gen()
  echo result.repr

macro viewable*(name, body: untyped): untyped =
  let widget = parse_widget_def(WidgetViewable, name, body)
  result = widget.gen()
  echo result.repr

type
  DialogResponseKind* = enum
    DialogCustom, DialogAccept, DialogCancel
  
  DialogResponse* = object
    case kind*: DialogResponseKind:
      of DialogCustom: id*: int
      else: discard

proc to_dialog_response(id: cint): DialogResponse =
  case id:
    of -3: result = DialogResponse(kind: DialogAccept)
    of -6: result = DialogResponse(kind: DialogCancel)
    else: result = DialogResponse(kind: DialogCustom, id: int(id))

renderable Dialog:
  discard

export Dialog, DialogState, build_state, update_state, assign_app_events

proc open*(app: Viewable, widget: Dialog): tuple[res: DialogResponse, state: WidgetState] =
  let
    state = DialogState(widget.build())
    window = app.unwrap_renderable().internal_widget
    dialog = state.unwrap_renderable().internal_widget
  gtk_window_set_transient_for(dialog, window)
  let res = gtk_dialog_run(dialog)
  state.read()
  gtk_widget_destroy(dialog)
  result = (to_dialog_response(res), state)

proc brew*(widget: Widget) =
  gtk_init()
  let state = widget.build()
  gtk_main()
