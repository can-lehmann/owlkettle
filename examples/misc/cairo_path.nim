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

import std/[sequtils]
import owlkettle, owlkettle/[adw, cairo, dataentries]

type Color = tuple[r, g, b, a: float]

viewable App:
  path: seq[tuple[x, y: float]] = @[
    (50.0, 300.0),
    (200.0, 100.0),
    (300.0, 200.0),
  ]
  closed: bool = false
  
  # Stroke
  strokeEnabled: bool = true
  strokeColor: Color = (0.0, 0.0, 0.0, 1.0)
  lineWidth: float = 16.0
  lineJoin: CairoLineJoin
  miterLimit: float = 10.0
  lineCap: CairoLineCap
  dash: seq[float] = @[]
  dashOffset: float = 0.0
  
  # Fill
  fillEnabled: bool = true
  fillColor: Color = (0.5, 0.5, 0.5, 1.0)

proc drawPath(app: AppState, ctx: CairoContext) =
  for it, (x, y) in app.path:
    if it == 0:
      ctx.moveTo(x, y)
    else:
      ctx.lineTo(x, y)
  if app.closed:
    ctx.closePath()

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Cairo Path Properties"
      defaultSize = (800, 600)
      
      HeaderBar {.addTitlebar.}:
        WindowTitle {.addTitle.}:
          title = "Cairo Path Properties"
      
      Paned:
        initialPosition = 300
        
        ScrolledWindow {.resize: false.}:
          Box:
            orient = OrientY
            margin = 12
            spacing = 12
            
            PreferencesGroup {.expand: false.}:
              title = "Path"
              
              ExpanderRow:
                title = "Points"
                subtitle = $app.path.len & " points"
                
                for it, (x, y) in app.path:
                  ActionRow {.addRow.}:
                    title = "Point " & $it
                    
                    NumberEntry {.addSuffix.}:
                      maxWidth = 5
                      xAlign = 1.0
                      value = x
                      proc changed(value: float) =
                        app.path[it].x = value
                    
                    NumberEntry {.addSuffix.}:
                      maxWidth = 5
                      xAlign = 1.0
                      value = y
                      proc changed(value: float) =
                        app.path[it].y = value
                    
                    Button {.addSuffix.}:
                      icon = "user-trash-symbolic"
                      proc clicked() =
                        app.path.delete(it)
                
                ListBoxRow {.addRow.}:
                  Button:
                    icon = "list-add-symbolic"
                    style = [ButtonFlat]
                    proc clicked() =
                      app.path.add((0.0, 0.0))
              
              ActionRow:
                title = "Closed"
                
                Switch {.addSuffix.}:
                  state = app.closed
                  proc changed(state: bool) =
                    app.closed = state
            
            PreferencesGroup {.expand: false.}:
              title = "Stroke"
              
              Box {.addSuffix.}:
                Switch {.expand: false, vAlign: AlignCenter.}:
                  state = app.strokeEnabled
                  proc changed(state: bool) =
                    app.strokeEnabled = state
              
              ActionRow:
                title = "Color"
                sensitive = app.strokeEnabled
                
                ColorButton {.addSuffix.}:
                  color = app.strokeColor
                  proc changed(color: Color) =
                    app.strokeColor = color
              
              ActionRow:
                title = "Line Width"
                sensitive = app.strokeEnabled
                
                NumberEntry {.addSuffix.}:
                  maxWidth = 6
                  xAlign = 1.0
                  value = app.lineWidth
                  proc changed(value: float) =
                    app.lineWidth = value
              
              ComboRow:
                title = "Line Join"
                sensitive = app.strokeEnabled
                items = mapIt(low(CairoLineJoin)..high(CairoLineJoin), $it)
                selected = ord(app.lineJoin)
                
                proc select(item: int) =
                  app.lineJoin = CairoLineJoin(item)
              
              if app.lineJoin == LineJoinMiter:
                ActionRow:
                  title = "Miter Limit"
                  sensitive = app.strokeEnabled
                  
                  NumberEntry {.addSuffix.}:
                    maxWidth = 6
                    xAlign = 1.0
                    value = app.miterLimit
                    proc changed(value: float) =
                      app.miterLimit = value
              
              ComboRow:
                title = "Line Cap"
                sensitive = app.strokeEnabled
                items = mapIt(low(CairoLineCap)..high(CairoLineCap), $it)
                selected = ord(app.lineCap)
                
                proc select(item: int) =
                  app.lineCap = CairoLineCap(item)
            
            PreferencesGroup {.expand: false.}:
              title = "Dash"
              sensitive = app.strokeEnabled
              
              ExpanderRow:
                title = "Pattern"
                if app.dash.len > 0:
                  subtitle = $app.dash.len & " segments"
                else:
                  subtitle = "No pattern set"
                sensitive = app.strokeEnabled
                
                for it, length in app.dash:
                  ActionRow {.addRow.}:
                    title = "Segment " & $it
                    
                    NumberEntry {.addSuffix.}:
                      maxWidth = 6
                      xAlign = 1.0
                      value = length
                      proc changed(value: float) =
                        app.dash[it] = value
                    
                    Button {.addSuffix.}:
                      icon = "user-trash-symbolic"
                      proc clicked() =
                        app.dash.delete(it)
                
                ListBoxRow {.addRow.}:
                  Button:
                    icon = "list-add-symbolic"
                    style = [ButtonFlat]
                    proc clicked() =
                      app.dash.add(10.0)
              
              ActionRow:
                title = "Offset"
                sensitive = app.strokeEnabled
                
                NumberEntry {.addSuffix.}:
                  maxWidth = 6
                  xAlign = 1.0
                  value = app.dashOffset
                  proc changed(value: float) =
                    app.dashOffset = value
            
            PreferencesGroup {.expand: false.}:
              title = "Fill"
              
              Box {.addSuffix.}:
                Switch {.expand: false, vAlign: AlignCenter.}:
                  state = app.fillEnabled
                  proc changed(state: bool) =
                    app.fillEnabled = state
              
              ActionRow:
                title = "Color"
                sensitive = app.fillEnabled
                
                ColorButton {.addSuffix.}:
                  color = app.fillColor
                  proc changed(color: Color) =
                    app.fillColor = color
        
        DrawingArea:
          proc draw(ctx: CairoContext, size: tuple[w, h: int]): bool =
            if app.fillEnabled:
              app.drawPath(ctx)
              ctx.source = app.fillColor
              ctx.fill()
            
            if app.strokeEnabled:
              app.drawPath(ctx)
              ctx.lineWidth = app.lineWidth
              ctx.lineJoin = app.lineJoin
              ctx.lineCap = app.lineCap
              ctx.miterLimit = app.miterLimit
              ctx.source = app.strokeColor
              ctx.setDash(app.dash, app.dashOffset)
              ctx.stroke()

adw.brew(gui(App()))
