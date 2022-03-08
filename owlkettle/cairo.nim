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

# Wrapper for the cairo vector graphics library

import std/math

type
  CairoContext* = distinct pointer
  CairoMatrix* = object
    xx*: cdouble
    yx*: cdouble
    xy*: cdouble
    yy*: cdouble
    x0*: cdouble
    y0*: cdouble

{.passl: gorge("pkg-config --libs cairo").}

{.push importc, cdecl.}
proc cairo_move_to(ctx: CairoContext, x, y: cdouble)
proc cairo_line_to(ctx: CairoContext, x, y: cdouble)
proc cairo_rectangle(ctx: CairoContext, x, y, w, h: cdouble)
proc cairo_arc(ctx: CairoContext, x, y, r, start, stop: cdouble)
proc cairo_curve_to(ctx: CairoContext, x1, y1, x2, y2, x3, y3: cdouble)
proc cairo_text_path(ctx: CairoContext, text: cstring)

proc cairo_set_line_width(ctx: CairoContext, width: cdouble)
proc cairo_set_source_rgb(ctx: CairoContext, r, g, b: cdouble)
proc cairo_set_source_rgba(ctx: CairoContext, r, g, b, a: cdouble)
proc cairo_fill(ctx: CairoContext)
proc cairo_stroke(ctx: CairoContext)

proc cairo_get_matrix*(ctx: CairoContext, mat: ptr CairoMatrix)
proc cairo_set_matrix*(ctx: CairoContext, mat: ptr CairoMatrix)
proc cairo_translate*(ctx: CairoContext, dx, dy: cdouble)
proc cairo_scale*(ctx: CairoContext, sx, sy: cdouble)
{.pop.}

{.push inline.}
proc move_to*(ctx: CairoContext, x, y: float) =
  cairo_move_to(ctx, x.cdouble, y.cdouble)

proc line_to*(ctx: CairoContext, x, y: float) =
  cairo_line_to(ctx, x.cdouble, y.cdouble)

proc curve_to*(ctx: CairoContext, x1, y1, x2, y2, x3, y3: float) =
  cairo_curve_to(ctx, x1.cdouble, y1.cdouble, x2.cdouble, y2.cdouble, x3.cdouble, y3.cdouble)

proc rectangle*(ctx: CairoContext, x, y, w, h: float) =
  cairo_rectangle(ctx, x.cdouble, y.cdouble, w.cdouble, h.cdouble)

proc circle*(ctx: CairoContext, x, y, r: float) =
  cairo_arc(ctx, x.cdouble, y.cdouble, r.cdouble, 0, cdouble(PI * 2))

proc arc*(ctx: CairoContext, x, y, r, start, stop: float) =
  cairo_arc(ctx, x.cdouble, y.cdouble, r.cdouble, start.cdouble, stop.cdouble)

proc text*(ctx: CairoContext, text: string) =
  cairo_text_path(ctx, text.cstring)

proc set_source*(ctx: CairoContext, r, g, b: float) =
  cairo_set_source_rgb(ctx, r.cdouble, g.cdouble, b.cdouble)

proc set_source*(ctx: CairoContext, r, g, b, a: float) =
  cairo_set_source_rgba(ctx, r.cdouble, g.cdouble, b.cdouble, a.cdouble)

proc `source=`*(ctx: CairoContext, color: tuple[r, g, b, a: float]) =
  ctx.set_source(color.r, color.g, color.b, color.a)

proc `source=`*(ctx: CairoContext, color: tuple[r, g, b: float]) =
  ctx.set_source(color.r, color.g, color.b)

proc `line_width=`*(ctx: CairoContext, width: float) =
  cairo_set_line_width(ctx, width.cdouble)

proc fill*(ctx: CairoContext) = cairo_fill(ctx)
proc stroke*(ctx: CairoContext) = cairo_stroke(ctx)

proc matrix*(ctx: CairoContext): CairoMatrix = cairo_get_matrix(ctx, result.addr)
proc `matrix=`*(ctx: CairoContext, mat: CairoMatrix) = cairo_set_matrix(ctx, mat.unsafe_addr)
proc scale*(ctx: CairoContext, x, y: float) = cairo_scale(ctx, x.cdouble, y.cdouble)
proc translate*(ctx: CairoContext, x, y: float) = cairo_translate(ctx, x.cdouble, y.cdouble)
{.pop.}

template with_matrix*(ctx: CairoContext, body: untyped) =
  block:
    let mat = ctx.matrix
    defer: ctx.matrix = mat
    body
