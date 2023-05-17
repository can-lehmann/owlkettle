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

import std/[strutils, math, sets, tables]
when defined(nimPreviewSlimSystem):
  import std/formatfloat
import widgets, widgetdef, guidsl

when defined(owlkettleDocs) and isMainModule:
  echo "# Dataentries Widgets\n\n"

proc isFloat(value: string): bool =
  if value.len > 0:
    var
      it = 0
      digits = 0
    if value[it] == '+' or value[it] == '-':
      it += 1
    while it < value.len and value[it] in '0'..'9':
      it += 1
      digits += 1
    if it < value.len and value[it] == '.':
      it += 1
      while it < value.len and value[it] in '0'..'9':
        it += 1
        digits += 1
    result = it == value.len and digits > 0

viewable NumberEntry:
  ## A entry for entering floating point numbers.

  value: float
  current {.internal.}: float
  text {.internal.}: string
  consistent {.internal.}: bool = true
  eps: float = 1e-6
  
  placeholder: string
  width: int = -1
  maxWidth: int = -1
  xAlign: float = 0.0
  
  tooltip: string = ""
  sizeRequest: tuple[x, y: int] = (-1, -1)
  sensitive: bool = true
  
  proc changed(value: float)
  
  hooks:
    build:
      state.current = state.value
      state.text = $state.value
      state.consistent = true
  
  example:
    NumberEntry:
      value = app.value
      proc changed(value: float) =
        app.value = value

method parse(entry: NumberEntryState, text: string): (bool, float) {.base.} =
  if isFloat(text):
    result = (true, parseFloat(text))

method view*(entry: NumberEntryState): Widget =
  if abs(entry.value - entry.current) > entry.eps:
    entry.current = entry.value
    entry.text = $entry.value
    entry.consistent = true
  result = gui:
    Entry:
      text = entry.text
      
      placeholder = entry.placeholder
      width = entry.width
      maxWidth = entry.maxWidth
      xAlign = entry.xAlign
      
      tooltip = entry.tooltip
      sizeRequest = entry.sizeRequest
      sensitive = entry.sensitive
      
      if entry.consistent:
        style = initHashSet[StyleClass]()
      else:
        style = [EntryError]
      
      proc changed(text: string) =
        entry.text = text
        let (success, value) = entry.parse(text)
        if success:
          entry.current = value
          entry.value = value
          if not entry.changed.isNil:
            entry.changed.callback(value)
        entry.consistent = success
      
      proc activate() =
        entry.current = entry.value
        entry.text = $entry.value
        entry.consistent = true

viewable FormulaEntry of NumberEntry:
  ## A entry for entering floating point numbers.
  ## The FormulaEntry can evaluate mathematical expressions like `1 + 2 * 3`.
  
  vars: Table[string, float] ## Variables that may be used in the expression
  
  example:
    FormulaEntry:
      value = app.value
      vars = toTable({"pi": PI})
      proc changed(value: float) =
        app.value = value

method parse(entry: FormulaEntryState, text: string): (bool, float64) =
  type
    TokenKind = enum
      TokenNumber, TokenName, TokenOp, TokenPrefixOp, TokenParOpen, TokenParClose
    
    Token = object
      kind: TokenKind
      value: string
    
    TokenStream = object
      tokens: seq[Token]
      cur: int
  
  proc add(stream: var TokenStream, token: Token) {.locks: 0.} =
    stream.tokens.add(token)
  
  proc next(stream: TokenStream, kind: TokenKind): bool {.locks: 0.} =
    result = stream.cur < stream.tokens.len and
             stream.tokens[stream.cur].kind == kind
  
  proc take(stream: var TokenStream, kind: TokenKind): bool {.locks: 0.} =
    result = stream.next(kind)
    if result:
      stream.cur += 1
  
  proc tokenize(text: string): TokenStream {.locks: 0.} =
    const
      WHITESPACE = {' ', '\n', '\r', '\t'}
      OP = {'+', '-', '*', '/', '^', '%'}
      STOP = {'(', ')'} + OP + WHITESPACE
    var it = 0
    while it < text.len:
      it += 1
      case text[it - 1]:
        of WHITESPACE: discard
        of '(': result.add(Token(kind: TokenParOpen))
        of ')': result.add(Token(kind: TokenParClose))
        of OP:
          var op = $text[it - 1]
          while it < text.len and text[it] in OP:
            op.add(text[it])
            it += 1
          if (op == "+" or op == "-") and
             it < text.len and
             text[it] notin WHITESPACE and
             (it - 2 < 0 or text[it - 2] in WHITESPACE):
            result.add(Token(kind: TokenPrefixOp, value: op))
          else:
            result.add(Token(kind: TokenOp, value: op))
        else:
          var name = $text[it - 1]
          while it < text.len and text[it] notin STOP:
            name.add(text[it])
            it += 1
          var kind = TokenName
          if isFloat(name):
            kind = TokenNumber
          result.add(Token(kind: kind, value: name))
  
  proc eval(stream: var TokenStream, level: int): tuple[valid: bool, val: float64] {.locks: 0.} =
    var prefix = 1.0
    if stream.take(TokenPrefixOp) and stream.tokens[stream.cur - 1].value == "-":
      prefix = -1.0
    
    if stream.take(TokenNumber):
      let value = stream.tokens[stream.cur - 1].value
      result.valid = value.isFloat()
      if result.valid:
        result.val = parseFloat(value)
    elif stream.take(TokenParOpen):
      result = stream.eval(0)
      if not stream.take(TokenParClose):
        return (false, 0.0)
    elif stream.take(TokenName):
      let value = stream.tokens[stream.cur - 1].value
      result.valid = value in entry.vars
      if result.valid:
        result.val = entry.vars[value]
    
    if not result.valid:
      return
    
    result.val *= prefix
    
    while stream.take(TokenOp):
      let
        op = stream.tokens[stream.cur - 1].value
        opLevel = case op:
          of "+": 0
          of "-": 0
          of "*": 1
          of "/": 1
          of "%": 1
          of "^": 2
          else:
            return (false, 0.0)
      if opLevel < level:
        stream.cur -= 1
        return
      
      let rhs = stream.eval(opLevel + 1)
      if not rhs.valid:
        return (false, 0.0)
      
      result.val = case op:
        of "+": result.val + rhs.val
        of "-": result.val - rhs.val
        of "*": result.val * rhs.val
        of "/": result.val / rhs.val
        of "%": result.val mod rhs.val
        of "^": pow(result.val, rhs.val)
        else: 0.0
  
  var stream = text.tokenize()
  result = stream.eval(0)
  if stream.cur < stream.tokens.len:
    result[0] = false

export NumberEntry, FormulaEntry
