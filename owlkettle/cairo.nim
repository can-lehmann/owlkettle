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
  
  CairoSurface* = distinct pointer
  CairoPattern* = distinct pointer
  
  CairoFormat* = enum
    FormatInvalid = -1,
    FormatARGB32 = 0,
    FormatRGB24 = 1,
    FormatA8 = 2,
    FormatA1 = 3,
    FormatRGB16 = 4, # FormatRGB16_565
    FormatRGB30 = 5
  
  CairoFilter* = enum
    FilterFast, FilterGood, FilterBest,
    FilterNearest, FilterBilinear, FilterGaussian
  
  CairoExtend* = enum
    ExtendNone, ExtendRepeat, ExtendReflect, ExtendPad
  
  CairoFontSlant* = enum
    FontSlantNormal, FontSlantItalic, FontSlantOblique
  
  CairoFontWeight* = enum
    FontWeightNormal, FontWeightBold
  
  CairoTextExtents* = object
    xBearing*: cdouble
    yBearing*: cdouble
    width*: cdouble
    height*: cdouble
    xAdvance*: cdouble
    yAdvance*: cdouble
  
  CairoStatus = distinct cint # TODO
  
  CairoLineJoin* = enum
    LineJoinMiter, LineJoinRound, LineJoinBevel
  
  CairoLineCap* = enum
    LineCapButt, LineCapRound, LineCapSquare

proc `==`(a, b: CairoStatus): bool {.borrow.}

import std/strutils as strutils
{.passl: strutils.strip(gorge("pkg-config --libs cairo")) .}

{.push importc, cdecl.}
proc cairo_create(surface: CairoSurface): CairoContext
proc cairo_destroy(ctx: CairoContext)

proc cairo_move_to(ctx: CairoContext, x, y: cdouble)
proc cairo_line_to(ctx: CairoContext, x, y: cdouble)
proc cairo_close_path(ctx: CairoContext)
proc cairo_rectangle(ctx: CairoContext, x, y, w, h: cdouble)
proc cairo_arc(ctx: CairoContext, x, y, r, start, stop: cdouble)
proc cairo_curve_to(ctx: CairoContext, x1, y1, x2, y2, x3, y3: cdouble)
proc cairo_text_path(ctx: CairoContext, text: cstring)

proc cairo_set_line_width(ctx: CairoContext, width: cdouble)
proc cairo_set_line_join(ctx: CairoContext, join: CairoLineJoin)
proc cairo_set_line_cap(ctx: CairoContext, cap: CairoLineCap)
proc cairo_set_miter_limit(ctx: CairoContext, limit: cdouble)
proc cairo_set_dash(ctx: CairoContext, dashes: ptr UncheckedArray[cdouble], count: cint, offset: cdouble)
proc cairo_set_source(ctx: CairoContext, pattern: CairoPattern)
proc cairo_set_source_rgb(ctx: CairoContext, r, g, b: cdouble)
proc cairo_set_source_rgba(ctx: CairoContext, r, g, b, a: cdouble)
proc cairo_fill(ctx: CairoContext)
proc cairo_fill_preserve(ctx: CairoContext)
proc cairo_stroke(ctx: CairoContext)
proc cairo_stroke_preserve(ctx: CairoContext)
proc cairo_clip(ctx: CairoContext)
proc cairo_reset_clip(ctx: CairoContext)

proc cairo_get_matrix(ctx: CairoContext, mat: ptr CairoMatrix)
proc cairo_set_matrix(ctx: CairoContext, mat: ptr CairoMatrix)
proc cairo_translate(ctx: CairoContext, dx, dy: cdouble)
proc cairo_scale(ctx: CairoContext, sx, sy: cdouble)

proc cairo_set_font_size(ctx: CairoContext, size: cdouble)
proc cairo_text_extents(ctx: CairoContext, text: cstring, extents: ptr CairoTextExtents)
proc cairo_select_font_face(ctx: CairoContext, family: cstring, slant: CairoFontSlant, weight: CairoFontWeight)

# Cairo.ImageSurface
proc cairo_image_surface_create(format: CairoFormat, width, height: cint): CairoSurface
proc cairo_image_surface_create_for_data(data: ptr UncheckedArray[uint8],
                                         format: CairoFormat,
                                         width, height, stride: cint): CairoSurface
proc cairo_image_surface_get_data(surface: CairoSurface): ptr UncheckedArray[uint8]
proc cairo_image_surface_get_format(surface: CairoSurface): CairoFormat
proc cairo_image_surface_get_width(surface: CairoSurface): cint
proc cairo_image_surface_get_height(surface: CairoSurface): cint

# Cairo.Surface
proc cairo_surface_status(surface: CairoSurface): CairoStatus
proc cairo_surface_flush(surface: CairoSurface)
proc cairo_surface_mark_dirty(surface: CairoSurface)
proc cairo_surface_destroy(surface: CairoSurface)

# PNG
proc cairo_image_surface_create_from_png(path: cstring): CairoSurface
proc cairo_surface_write_to_png(surface: CairoSurface, path: cstring): CairoStatus

# Cairo.Pattern
proc cairo_pattern_create_for_surface(surface: CairoSurface): CairoPattern
proc cairo_pattern_set_filter(pattern: CairoPattern, filter: CairoFilter)
proc cairo_pattern_set_extend(pattern: CairoPattern, extend: CairoExtend)
proc cairo_pattern_destroy(pattern: CairoPattern)

# Cairo.Status
proc cairo_status_to_string(status: CairoStatus): cstring
{.pop.}

{.push inline.}
proc newCairoContext*(surface: CairoSurface): CairoContext = cairo_create(surface)
proc destroy*(ctx: CairoContext) = cairo_destroy(ctx)

proc moveTo*(ctx: CairoContext, x, y: float) =
  cairo_move_to(ctx, x.cdouble, y.cdouble)

proc lineTo*(ctx: CairoContext, x, y: float) =
  cairo_line_to(ctx, x.cdouble, y.cdouble)

proc closePath*(ctx: CairoContext) =
  cairo_close_path(ctx)

proc curveTo*(ctx: CairoContext, x1, y1, x2, y2, x3, y3: float) =
  cairo_curve_to(ctx, x1.cdouble, y1.cdouble, x2.cdouble, y2.cdouble, x3.cdouble, y3.cdouble)

proc rectangle*(ctx: CairoContext, x, y, w, h: float) =
  cairo_rectangle(ctx, x.cdouble, y.cdouble, w.cdouble, h.cdouble)

proc circle*(ctx: CairoContext, x, y, r: float) =
  cairo_arc(ctx, x.cdouble, y.cdouble, r.cdouble, 0, cdouble(PI * 2))

proc arc*(ctx: CairoContext, x, y, r, start, stop: float) =
  cairo_arc(ctx, x.cdouble, y.cdouble, r.cdouble, start.cdouble, stop.cdouble)

proc text*(ctx: CairoContext, text: string) =
  cairo_text_path(ctx, text.cstring)

proc setSource*(ctx: CairoContext, r, g, b: float) =
  cairo_set_source_rgb(ctx, r.cdouble, g.cdouble, b.cdouble)

proc setSource*(ctx: CairoContext, r, g, b, a: float) =
  cairo_set_source_rgba(ctx, r.cdouble, g.cdouble, b.cdouble, a.cdouble)

proc setSource*(ctx: CairoContext, pattern: CairoPattern) =
  cairo_set_source(ctx, pattern)

proc `source=`*(ctx: CairoContext, color: tuple[r, g, b, a: float]) =
  ctx.setSource(color.r, color.g, color.b, color.a)

proc `source=`*(ctx: CairoContext, color: tuple[r, g, b: float]) =
  ctx.setSource(color.r, color.g, color.b)

proc `source=`*(ctx: CairoContext, pattern: CairoPattern) =
  cairo_set_source(ctx, pattern)

proc `lineWidth=`*(ctx: CairoContext, width: float) =
  cairo_set_line_width(ctx, width.cdouble)

proc `lineJoin=`*(ctx: CairoContext, join: CairoLineJoin) =
  cairo_set_line_join(ctx, join)

proc `miterLimit=`*(ctx: CairoContext, limit: float) =
  cairo_set_miter_limit(ctx, limit.cdouble)

proc `lineCap=`*(ctx: CairoContext, cap: CairoLineCap) =
  cairo_set_line_cap(ctx, cap)

proc setDash*(ctx: CairoContext, dash: openArray[float], offset: float = 0.0) =
  if dash.len > 0:
    var data = newSeq[cdouble](dash.len)
    for it, value in dash:
      data[it] = cdouble(value)
    let dataPtr = cast[ptr UncheckedArray[cdouble]](data[0].addr)
    cairo_set_dash(ctx, dataPtr, cint(dash.len), cdouble(offset))
  else:
    cairo_set_dash(ctx, nil, 0, cdouble(offset))

proc `dash=`*(ctx: CairoContext, dash: openArray[float]) = ctx.setDash(dash)

proc fill*(ctx: CairoContext) = cairo_fill(ctx)
proc stroke*(ctx: CairoContext) = cairo_stroke(ctx)
proc fillPreserve*(ctx: CairoContext) = cairo_fill_preserve(ctx)
proc strokePreserve*(ctx: CairoContext) = cairo_stroke_preserve(ctx)

proc clip*(ctx: CairoContext) = cairo_clip(ctx)
proc resetClip*(ctx: CairoContext) = cairo_reset_clip(ctx)

proc matrix*(ctx: CairoContext): CairoMatrix = cairo_get_matrix(ctx, result.addr)
proc `matrix=`*(ctx: CairoContext, mat: CairoMatrix) = cairo_set_matrix(ctx, mat.unsafe_addr)
proc scale*(ctx: CairoContext, x, y: float) = cairo_scale(ctx, x.cdouble, y.cdouble)
proc translate*(ctx: CairoContext, x, y: float) = cairo_translate(ctx, x.cdouble, y.cdouble)

proc `fontSize=`*(ctx: CairoContext, size: float) =
  cairo_set_font_size(ctx, size.cdouble)

proc selectFontFace*(ctx: CairoContext,
                     family: string,
                     slant: CairoFontSlant = FontSlantNormal,
                     weight: CairoFontWeight = FontWeightNormal) =
  cairo_select_font_face(ctx, family.cstring, slant, weight)

proc textExtents*(ctx: CairoContext, text: string): CairoTextExtents =
  cairo_text_extents(ctx, text.cstring, result.addr)

proc newImageSurface*(format: CairoFormat, width, height: int): CairoSurface =
  result = cairo_image_surface_create(format, width.cint, height.cint)

proc newImageSurface*(format: CairoFormat,
                      width, height, stride: int,
                      data: ptr UncheckedArray[uint8]): CairoSurface =
  result = cairo_image_surface_create_for_data(data, format, width.cint, height.cint, stride.cint)

proc loadImageSurface*(path: string): CairoSurface =
  result = cairo_image_surface_create_from_png(path.cstring)
  let status = cairo_surface_status(result)
  if status != CairoStatus(0):
    raise newException(IOError, $cairo_status_to_string(status))

proc data*(surface: CairoSurface): ptr UncheckedArray[uint8] = cairo_image_surface_get_data(surface)
proc format*(surface: CairoSurface): CairoFormat = cairo_image_surface_get_format(surface)
proc width*(surface: CairoSurface): int = int(cairo_image_surface_get_width(surface))
proc height*(surface: CairoSurface): int = int(cairo_image_surface_get_height(surface))
proc flush*(surface: CairoSurface) = cairo_surface_flush(surface)
proc markDirty*(surface: CairoSurface) = cairo_surface_mark_dirty(surface)
proc destroy*(surface: CairoSurface) = cairo_surface_destroy(surface)
proc save*(surface: CairoSurface, path: string) =
  discard cairo_surface_write_to_png(surface, path.cstring)

proc newPattern*(surface: CairoSurface): CairoPattern =
  result = cairo_pattern_create_for_surface(surface)

proc `filter=`*(pattern: CairoPattern, filter: CairoFilter) =
  cairo_pattern_set_filter(pattern, filter)

proc `extend=`*(pattern: CairoPattern, extend: CairoExtend) =
  cairo_pattern_set_extend(pattern, extend)

proc destroy*(pattern: CairoPattern) = cairo_pattern_destroy(pattern)
{.pop.}

template withMatrix*(ctx: CairoContext, body: untyped) =
  block:
    let mat = ctx.matrix
    defer: ctx.matrix = mat
    body

template modify*(surface: CairoSurface, pixels, body: untyped) =
  block:
    surface.flush()
    let pixels {.inject.} = surface.data
    body
    surface.markDirty()

proc draw*(ctx: CairoContext,
           surface: CairoSurface,
           x, y, w, h: float,
           filter: CairoFilter = FilterGood) =
  ctx.withMatrix:
    ctx.rectangle(x, y, w, h)
    let pattern = newPattern(surface)
    defer: pattern.destroy()
    pattern.filter = filter
    ctx.translate(x, y)
    ctx.scale(w / surface.width.float, h / surface.height.float)
    ctx.source = pattern
    ctx.fill()
