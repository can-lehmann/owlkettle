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

# Utility functions

import std/[macros, algorithm]

proc isName*(node: NimNode): bool = node.kind in {nnkIdent, nnkSym}

proc parseQualifiedName(node: NimNode): tuple[success: bool, name: seq[string]] =
  var cur = node
  while cur.kind == nnkDotExpr:
    if not cur[1].isName:
      return
    result.name.add(cur[1].strVal)
    cur = cur[0]
  
  if cur.isName:
    result.success = true
    result.name.add(cur.strVal)
    result.name.reverse()

proc isQualifiedName*(node: NimNode): bool = node.parseQualifiedName().success
proc qualifiedName*(node: NimNode): seq[string] = node.parseQualifiedName().name

proc unwrapName*(node: NimNode): NimNode =
  result = node
  while not result.isName:
    case result.kind:
      of nnkOpenSymChoice, nnkClosedSymChoice:
        result = result[0]
      of nnkHiddenDeref:
        result = result[0]
      of nnkPragmaExpr:
        result = result[0]
      else:
        return nil

proc findPragma*(node: NimNode, name: string): NimNode =
  case node.kind:
    of nnkPragma:
      for child in node:
        if child.eqIdent(name):
          return child
    else:
      for child in node:
        let pragma = child.findPragma(name)
        if not pragma.isNil:
          return pragma

proc newDotExpr*(node, field: NimNode, lineInfo: NimNode): NimNode =
  result = newTree(nnkDotExpr, [node, field])
  if not lineInfo.isNil:
    result.copyLineInfo(lineInfo)

proc newDotExpr*(node: NimNode, field: string, lineInfo: NimNode = nil): NimNode =
  result = newDotExpr(node, ident(field))
  if not lineInfo.isNil:
    result.copyLineInfo(lineInfo)
    result[1].copyLineInfo(lineInfo)

proc newQualifiedIdent*(name: seq[string], lineInfo: NimNode = nil): NimNode =
  result = ident(name[0])
  if not lineInfo.isNil:
    result.copyLineInfo(lineInfo)
  for it in 1..<name.len:
    result = newDotExpr(result, name[it], lineInfo)

proc newAssignment*(lhs, rhs, lineInfo: NimNode): NimNode =
  result = newAssignment(lhs, rhs)
  if not lineInfo.isNil:
    result.copyLineInfo(lineInfo)

proc newBracketExpr*(node, index: NimNode): NimNode =
  result = newTree(nnkBracketExpr, node, index)

proc newExport*(node: NimNode): NimNode =
  result = newTree(nnkPostfix, ident("*"), node)

proc newExport*(node: NimNode, addExport: bool): NimNode =
  if addExport:
    result = newTree(nnkPostfix, ident("*"), node)
  else:
    result = node


template customPragmas*() =
  ## Definess a custom pragma called "locker".
  ## This does nothing when compiled with a nim version 2.0 or higher,
  ## but applies the "locks: 0" pragma if compiled for e.g. 1.6.X.
  ## "locks: 0" is applied to ensure that this code never accesses locked data in user-defined procs.
  ## Its main purpose is silencing compiler-warnings for nim 1.6.X.
  when NimMajor >= 2:
    {.pragma: locker.}
  else:
    {.pragma: locker, locks: 0.}
    
template crossVersionDestructor*(name: untyped, typ: typedesc, body: untyped) =
  ## Defines a =destroy to work for both nim 2 and nim 1.6.X
  when NimMajor >= 2:
    proc `=destroy`*(name: typ) =
      body
  else:
    proc `=destroy`*(name: var typ) =
      body