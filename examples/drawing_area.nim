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

import owlkettle, owlkettle/cairo

type
  Color = tuple[r, g, b, a: float]
  
  Path = object
    points: seq[(float, float)]
    color: Color

viewable App:
  paths: seq[Path]
  color: Color = (0.0, 0.0, 0.0, 1.0)
  is_drawing: bool

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Drawing Area"
      
      HeaderBar {.add_titlebar.}:
        ColorButton {.add_left.}:
          color = app.color
          proc changed(color: Color) =
            app.color = color
      
      DrawingArea:
        proc draw(ctx: CairoContext, size: (int, int)): bool =
          ctx.rectangle(0, 0, size[0].float, size[1].float)
          ctx.set_source(1, 1, 1, 1)
          ctx.fill()
          for path in app.paths:
            for it, (x, y) in path.points:
              if it == 0:
                ctx.move_to(x, y)
              else:
                ctx.line_to(x, y)
            ctx.source = path.color
            ctx.stroke()
        
        proc mouse_pressed(evt: ButtonEvent) =
          if evt.button == 0:
            app.is_drawing = true
            app.paths.add(Path(
              color: app.color,
              points: @[(evt.x, evt.y)]
            ))
        
        proc mouse_released(evt: ButtonEvent) =
          if evt.button == 0:
            app.is_drawing = false
        
        proc mouse_moved(evt: MotionEvent) =
          if app.is_drawing and app.paths.len > 0:
            app.paths[^1].points.add((evt.x, evt.y))

brew(gui(App()))
