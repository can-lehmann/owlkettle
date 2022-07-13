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

proc is_name*(node: NimNode): bool = node.kind in {nnkIdent, nnkSym}
proc is_name*(node: NimNode, name: string): bool = node.is_name and node.eq_ident(name)

proc unwrap_name*(node: NimNode): NimNode =
  result = node
  while not result.is_name:
    case result.kind:
      of nnkOpenSymChoice, nnkClosedSymChoice:
        result = result[0]
      of nnkHiddenDeref:
        result = result[0]
      else:
        return nil

proc new_dot_expr*(node: NimNode, field: string, line_info: NimNode = nil): NimNode =
  result = new_tree(nnkDotExpr, [node, ident(field)])
  if not line_info.is_nil:
    result.copy_line_info(line_info)

proc new_assignment*(lhs, rhs, line_info: NimNode): NimNode =
  result = new_assignment(lhs, rhs)
  if not line_info.is_nil:
    result.copy_line_info(line_info)

proc new_bracket_expr*(node, index: NimNode): NimNode =
  result = new_tree(nnkBracketExpr, node, index)

proc new_export*(node: NimNode): NimNode =
  result = new_tree(nnkPostfix, ident("*"), node)

proc clone*(node: NimNode): NimNode =
  case node.kind:
    of nnkIdent, nnkSym:
      result = ident(node.str_val)
    of nnkLiterals:
      result = node
    else:
      result = new_nim_node(node.kind)
      for child in node:
        result.add(child.clone()) 

