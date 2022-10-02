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

import std/[macros]

proc isName*(node: NimNode): bool = node.kind in {nnkIdent, nnkSym}

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

proc newAssignment*(lhs, rhs, lineInfo: NimNode): NimNode =
  result = newAssignment(lhs, rhs)
  if not lineInfo.isNil:
    result.copyLineInfo(lineInfo)

proc newBracketExpr*(node, index: NimNode): NimNode =
  result = newTree(nnkBracketExpr, node, index)

proc newExport*(node: NimNode): NimNode =
  result = newTree(nnkPostfix, ident("*"), node)
