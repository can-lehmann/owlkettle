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

# Create libadwaita apps using owlkettle

import gtk, widgetdef, widgets, mainloop

{.passl: "-ladwaita-1".}

type
  StyleManager = distinct pointer
  
  ColorScheme* = enum
    ColorSchemeDefault,
    ColorSchemeForceLight,
    ColorSchemeForceDark,
    ColorSchemePreferDark,
    ColorSchemePreferLight

{.push importc, cdecl.}
# Adw
proc adw_init()

# Adw.StyleManager
proc adw_style_manager_get_default(): StyleManager
proc adw_style_manager_set_color_scheme(manager: StyleManager, color_scheme: ColorScheme)

# Adw.WindowTitle
proc adw_window_title_new(title, subtitle: cstring): GtkWidget
proc adw_window_title_set_title(widget: GtkWidget, title: cstring)
proc adw_window_title_set_subtitle(widget: GtkWidget, subtitle: cstring)
{.pop.}

renderable WindowTitle of BaseWidget:
  title: string
  subtitle: string
  
  hooks:
    before_build:
      state.internal_widget = adw_window_title_new(cstring(""), cstring(""))
  
  hooks title:
    property:
      adw_window_title_set_title(state.internal_widget, state.title.cstring)
  
  hooks subtitle:
    property:
      adw_window_title_set_subtitle(state.internal_widget, state.subtitle.cstring)

export WindowTitle

proc brew*(widget: Widget,
           icons: openArray[string] = [],
           color_scheme: ColorScheme = ColorSchemeDefault,
           stylesheets: openArray[string] = []) =
  adw_init()
  let style_manager = adw_style_manager_get_default()
  adw_style_manager_set_color_scheme(style_manager, color_scheme)
  let state = setup_app(AppConfig(
    widget: widget,
    icons: @icons,
    dark_theme: false,
    stylesheets: @stylesheets
  ))
  run_mainloop(state)
