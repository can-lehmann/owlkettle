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

import std/[macros, strutils, genasts]
import common, widgetdef

type
  NodeKind = enum
    NodeWidget, NodeAttribute, NodeEvent,
    NodeAdder, NodeProperty,
    NodeBlock, NodeFor, NodeIf, NodeCase,
    NodeInsert, NodeLet
  
  Adder = object
    name: string
    args: seq[(string, NimNode)]
    lineInfo: NimNode
  
  Node = ref object
    children: seq[Node]
    lineInfo: NimNode
    case kind: NodeKind:
      of NodeWidget:
        widget: string
        adder: Adder
      of NodeAttribute, NodeProperty:
        name: string
        value: NimNode
      of NodeAdder:
        adderName: string
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
        insertAdder: Adder
      of NodeLet:
        defs: seq[NimNode]
      else: discard

proc parseAdder(node: NimNode): Adder =
  result.lineInfo = node
  for child in node:
    case child.kind:
      of nnkExprColonExpr:
        assert child[0].isName()
        result.args.add((child[0].strVal, child[1]))
      of nnkIdent, nnkSym:
        result.name = child.strVal
      else:
        error("Unable to parse adder argument from " & $child.kind, child)

proc parseGui(node: NimNode): Node =
  case node.kind:
    of nnkCallKinds:
      if node[0].unwrapName().eqIdent("insert"):
        return Node(kind: NodeInsert, insert: node[1])
      elif node[0].eqIdent("@"):
        return Node(kind: NodeAdder, adderName: node[1].strVal)
      elif node[0].isName:
        result = Node(kind: NodeWidget, widget: node[0].strVal, lineInfo: node)
      else:
        result = node[0].parseGui()
      for it in 1..<node.len:
        result.children.add(node[it].parseGui())
    of nnkPragmaExpr:
      if node[0].isName:
        result = Node(kind: NodeWidget, widget: node[0].strVal, lineInfo: node)
      else:
        result = node[0].parseGui()
      let adder = node[1].parseAdder()
      case result.kind:
        of NodeInsert: result.insertAdder = adder
        of NodeWidget: result.adder = adder
        else: error("Unable to add adder to " & $result.kind, node[1])
    of nnkStmtList:
      result = Node(kind: NodeBlock)
      for child in node:
        if child.kind != nnkDiscardStmt:
          result.children.add(child.parseGui())
    of nnkAsgn, nnkExprEqExpr:
      if node[0].kind == nnkPrefix and node[0][0].eqIdent("@"):
        result = Node(kind: NodeProperty, name: node[0][1].strVal)
      else:
        assert node[0].isName
        result = Node(kind: NodeAttribute, name: node[0].strVal)
      result.value = node[1]
      result.lineInfo = node
    of nnkProcDef:
      assert node[0].isName
      result = Node(kind: NodeEvent,
        event: node[0].strVal,
        callback: node,
        lineInfo: node
      )
    of nnkForStmt:
      result = Node(kind: NodeFor)
      for it in 0..<(node.len - 2):
        result.vars.add(node[it])
      result.iter = node[^2]
      result.children.add(node[^1].parseGui())
    of nnkIfStmt:
      result = Node(kind: NodeIf)
      for child in node:
        case child.kind:
          of nnkElifBranch:
            result.branches.add((child[0], child[1].parseGui()))
          of nnkElse:
            if not result.otherwise.isNil:
              error("There may be at most one else branch in an if statement", child)
            result.otherwise = child[0].parseGui()
          else:
            error($child.kind & " is not a valid gui tree inside an if statement.", child)
    of nnkCaseStmt:
      result = Node(kind: NodeCase, discr: node[0])
      for it in 1..<node.len:
        let child = node[it]
        case child.kind:
          of nnkOfBranch:
            assert child.len == 2
            result.patterns.add((child[0], child[1].parseGui()))
          of nnkElse:
            result.default = child[0].parseGui()
          else:
            error($child.kind & " is not a valid gui tree inside a case statement.", child)
    of nnkLetSection:
      result = Node(kind: NodeLet)
      for def in node:
        result.defs.add(def)
    else: error($node.kind & " is not a valid gui tree.", node)

proc foldAdders(node: Node, adder: var Adder) =
  var it = 0
  while it < node.children.len:
    let child = node.children[it]
    case child.kind:
      of NodeAdder:
        adder.name = child.adderName
        node.children.delete(it)
      of NodeProperty:
        adder.args.add((child.name, child.value))
        node.children.delete(it)
      of NodeBlock:
        child.foldAdders(adder)
        it += 1
      else:
        it += 1

proc foldAdders(node: Node) =
  for child in node.children:
    child.foldAdders()
  
  if node.kind == NodeWidget:
    node.foldAdders(node.adder)

proc gen(adder: Adder, name, parent: NimNode): NimNode =
  var callee = ident("add")
  if adder.name.len > 0:
    callee = ident(adder.name)
  callee.copyLineInfo(adder.lineInfo)
  result = newCall(callee, parent, name)
  for (key, value) in adder.args:
    result.add(newTree(nnkExprEqExpr, ident(key), value))
  result.copyLineInfo(adder.lineInfo)

macro customCapture(vars: varargs[typed], body: untyped): untyped =
  var
    params = @[newEmptyNode()]
    args: seq[NimNode] = @[]
  for variable in vars:
    let name = variable.unwrapName()
    assert name.isName
    params.add:
      newIdentDefs(ident(name.strVal), variable.getTypeInst())

    args.add(variable)
  result = newProc(
    params = params,
    body = body
  ).newCall(args)

proc findVariables(node: NimNode): seq[NimNode] =
  case node.kind:
    of nnkIdent, nnkSym:
      result = @[ident(node.strVal)]
    of nnkTupleConstr, nnkVarTuple:
      for child in node:
        result.add(child.findVariables())
    of nnkEmpty: discard
    else: echo node.kind

proc findVariables(nodes: seq[NimNode]): seq[NimNode] =
  for child in nodes:
    result.add(child.findVariables())

proc gen(node: Node, stmts, parent: NimNode) =
  case node.kind:
    of NodeWidget:
      let
        body = newStmtList()
        name = gensym(nskLet)
        widgetTyp = ident(node.widget)
      widgetTyp.copyLineInfo(node.lineInfo)
      body.add(newLetStmt(name, newCall(widgetTyp)))
      for child in node.children:
        child.gen(body, name)
      if not parent.isNil:
        body.add(node.adder.gen(name, parent))
      else:
        body.add(name)
      stmts.add(newTree(nnkBlockStmt, newEmptyNode(), body))
    of NodeAttribute:
      stmts.add(newAssignment(
        newDotExpr(parent, "has" & capitalizeAscii(node.name)),
        newLit(true),
        node.lineInfo
      ))
      stmts.add(newAssignment(
        newDotExpr(parent, "val" & capitalizeAscii(node.name), node.lineInfo),
        node.value,
        node.lineInfo
      ))
    of NodeEvent:
      let typ = newTree(nnkProcTy, node.callback.params, newEmptyNode())
      node.callback.name = newEmptyNode()

      let constr = genAst(typ, nodeCallback = node.callback):
        Event[typ](callback: nodeCallback)
      constr.copyLineInfo(node.lineInfo)
      stmts.add(newAssignment(
        newDotExpr(parent, node.event),
        constr,
        node.lineInfo
      ))
    of NodeBlock:
      for child in node.children:
        child.gen(stmts, parent)
    of NodeFor:
      var body = newStmtList()
      node.children[0].gen(body, parent)
      stmts.add(newTree(nnkForStmt, node.vars & @[
        node.iter,
        newStmtList(
          newCall(bindSym("customCapture"),
            node.vars.findVariables() & @[body]
          )
        )
      ]))
    of NodeIf:
      var stmt = newTree(nnkIfStmt)
      for (cond, body) in node.branches:
        var bodyStmts = newStmtList()
        body.gen(bodyStmts, parent)
        stmt.add(newTree(nnkElifBranch, cond, bodyStmts))
      if not node.otherwise.isNil:
        var bodyStmts = newStmtList()
        node.otherwise.gen(bodyStmts, parent)
        stmt.add(newTree(nnkElse, bodyStmts))
      stmts.add(stmt)
    of NodeCase:
      let stmt = newTree(nnkCaseStmt, node.discr)
      for (pattern, body) in node.patterns:
        let bodyStmts = newStmtList()
        body.gen(bodyStmts, parent)
        stmt.add(newTree(nnkOfBranch, pattern, bodyStmts))
      if not node.default.isNil:
        let bodyStmts = newStmtList()
        node.default.gen(bodyStmts, parent)
        stmt.add(newTree(nnkElse, bodyStmts))
      stmts.add(stmt)
    of NodeInsert:
      stmts.add(node.insertAdder.gen(node.insert, parent))
    of NodeLet:
      stmts.add(newTree(nnkLetSection, node.defs))
    of NodeAdder, NodeProperty:
      error("Adders and propeties may not appear in if statements or loops")

macro gui*(tree: untyped): untyped =
  let gui = tree.parseGui()
  gui.foldAdders()
  result = newStmtList()
  gui.gen(result, nil)
  when defined(owlkettleDebug):
    echo result.repr
