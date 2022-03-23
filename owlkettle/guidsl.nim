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

# Domain-specific language for specifying GUI layouts

import std/[macros, sugar]
import common, widgetdef

type
  NodeKind = enum
    NodeWidget, NodeAttribute, NodeEvent,
    NodeBlock, NodeFor, NodeIf, NodeCase,
    NodeInsert
  
  Adder = object
    name: string
    args: seq[(string, NimNode)]
  
  Node = ref object
    children: seq[Node]
    case kind: NodeKind:
      of NodeWidget:
        widget: string
        adder: Adder
      of NodeAttribute:
        name: string
        value: NimNode
      of NodeEvent:
        event: string
        callback: NimNode
      of NodeFor:
        vars: seq[NimNode]
        iter: NimNode
      of NodeIf:
        branches: seq[(NimNode, Node)]
        otherwise: Node
      of NodeCase:
        discr: NimNode
        patterns: seq[(NimNode, Node)]
        default: Node
      of NodeInsert:
        insert: NimNode
        insert_adder: Adder
      else: discard

proc parse_adder(node: NimNode): Adder =
  for child in node:
    case child.kind:
      of nnkExprColonExpr:
        assert child[0].is_name()
        result.args.add((child[0].str_val, child[1]))
      of nnkIdent, nnkSym:
        result.name = child.str_val
      else:
        error("Unable to parse adder argument from " & $child.kind)

proc parse_gui(node: NimNode): Node =
  case node.kind:
    of nnkCallKinds:
      if node[0].unwrap_name().is_name("insert"):
        return Node(kind: NodeInsert, insert: node[1])
      elif node[0].is_name:
        result = Node(kind: NodeWidget, widget: node[0].str_val)
      else:
        result = node[0].parse_gui()
      for it in 1..<node.len:
        result.children.add(node[it].parse_gui())
    of nnkPragmaExpr:
      if node[0].is_name:
        result = Node(kind: NodeWidget, widget: node[0].str_val)
      else:
        result = node[0].parse_gui()
      let adder = node[1].parse_adder()
      case result.kind:
        of NodeInsert: result.insert_adder = adder
        of NodeWidget: result.adder = adder
        else: error("Unable to add adder to " & $result.kind)
    of nnkStmtList:
      result = Node(kind: NodeBlock)
      for child in node:
        if child.kind != nnkDiscardStmt:
          result.children.add(child.parse_gui())
    of nnkAsgn, nnkExprEqExpr:
      assert node[0].is_name
      result = Node(kind: NodeAttribute,
        name: node[0].str_val,
        value: node[1]
      )
    of nnkProcDef:
      assert node[0].is_name
      result = Node(kind: NodeEvent,
        event: node[0].str_val,
        callback: node
      )
    of nnkForStmt:
      result = Node(kind: NodeFor)
      for it in 0..<(node.len - 2):
        result.vars.add(node[it])
      result.iter = node[^2]
      result.children.add(node[^1].parse_gui())
    of nnkIfStmt:
      result = Node(kind: NodeIf)
      for child in node:
        case child.kind:
          of nnkElifBranch:
            result.branches.add((child[0], child[1].parse_gui()))
          of nnkElse:
            if not result.otherwise.is_nil:
              error("There may be at most one else branch in an if statement")
            result.otherwise = child[0].parse_gui()
          else:
            error($child.kind & " is not a valid gui tree inside an if statement.")
    of nnkCaseStmt:
      result = Node(kind: NodeCase, discr: node[0])
      for it in 1..<node.len:
        let child = node[it]
        case child.kind:
          of nnkOfBranch:
            assert child.len == 2
            result.patterns.add((child[0], child[1].parse_gui()))
          of nnkElse:
            result.default = child[0].parse_gui()
          else:
            error($child.kind & " is not a valid gui tree inside a case statement.")
    else: error($node.kind & " is not a valid gui tree.")

proc gen(adder: Adder, name, parent: NimNode): NimNode =
  var callee = ident("add")
  if adder.name.len > 0:
    callee = ident(adder.name)
  result = new_call(callee, parent, name)
  for (key, value) in adder.args:
    result.add(new_tree(nnkExprEqExpr, [ident(key), value]))

proc gen(node: Node, stmts, parent: NimNode) =
  case node.kind:
    of NodeWidget:
      let name = gensym(nskLet)
      stmts.add(new_let_stmt(name, new_call(ident(node.widget))))
      for child in node.children:
        child.gen(stmts, name)
      if not parent.is_nil:
        stmts.add(node.adder.gen(name, parent))
      else:
        stmts.add(name)
    of NodeAttribute:
      stmts.add(new_assignment(
        new_dot_expr(parent, "has_" & node.name),
        bind_sym("true")
      ))
      stmts.add(new_assignment(
        new_dot_expr(parent, "val_" & node.name),
        node.value
      ))
    of NodeEvent:
      let typ = new_tree(nnkProcTy, [
        node.callback.params, new_empty_node()
      ])
      node.callback.name = new_empty_node()
      stmts.add(new_assignment(
        new_dot_expr(parent, node.event),
        new_tree(nnkObjConstr, [
          bindsym("Event").new_bracket_expr(typ),
          new_tree(nnkExprColonExpr, [
            ident("callback"), node.callback
          ])
        ])
      ))
    of NodeBlock:
      for child in node.children:
        child.gen(stmts, parent)
    of NodeFor:
      var body = new_stmt_list()
      node.children[0].gen(body, parent)
      stmts.add(new_tree(nnkForStmt, node.vars & @[
        node.iter,
        new_tree(nnkCommand, @[bind_sym("capture")] & node.vars & @[body])
      ]))
    of NodeIf:
      var stmt = new_tree(nnkIfStmt)
      for (cond, body) in node.branches:
        var body_stmts = new_stmt_list()
        body.gen(body_stmts, parent)
        stmt.add(new_tree(nnkElifBranch, cond, body_stmts))
      if not node.otherwise.is_nil:
        var body_stmts = new_stmt_list()
        node.otherwise.gen(body_stmts, parent)
        stmt.add(new_tree(nnkElse, body_stmts))
      stmts.add(stmt)
    of NodeCase:
      let stmt = new_tree(nnkCaseStmt, node.discr)
      for (pattern, body) in node.patterns:
        let body_stmts = new_stmt_list()
        body.gen(body_stmts, parent)
        stmt.add(new_tree(nnkOfBranch, pattern, body_stmts))
      if not node.default.is_nil:
        let body_stmts = new_stmt_list()
        node.default.gen(body_stmts, parent)
        stmt.add(new_tree(nnkElse, body_stmts))
      stmts.add(stmt)
    of NodeInsert:
      stmts.add(node.insert_adder.gen(node.insert, parent))

macro gui*(tree: untyped): untyped =
  let gui = tree.parse_gui()
  result = new_nim_node(nnkStmtListExpr)
  gui.gen(result, nil)
  echo result.repr
