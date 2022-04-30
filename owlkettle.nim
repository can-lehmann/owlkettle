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

import owlkettle/[gtk, widgetdef, widgets, guidsl]
export widgetdef, widgets, guidsl

proc write_clipboard*(state: WidgetState, text: string) =
  let
    widget = state.unwrap_renderable().internal_widget
    display = gtk_widget_get_display(widget)
    clipboard = gtk_clipboard_get_default(display)
  gtk_clipboard_set_text(clipboard, text.cstring, text.len.cint)

proc open*(app: Viewable, widget: Widget): tuple[res: DialogResponse, state: WidgetState] =
  let
    state = WidgetState(widget.build())
    window = app.unwrap_renderable().internal_widget
    dialog = state.unwrap_renderable().internal_widget
  gtk_window_set_transient_for(dialog, window)
  let res = gtk_dialog_run(dialog)
  state.read()
  gtk_widget_destroy(dialog)
  result = (to_dialog_response(res), state)

proc setup_app(widget: Widget,
               icons: openArray[string],
               dark_theme: bool,
               stylesheets: openArray[string]): WidgetState =
  if dark_theme:
    let settings = gtk_settings_get_default()
    var value = g_value_new(dark_theme)
    g_object_set_property(settings.pointer, "gtk-application-prefer-dark-theme", value.addr)
    g_value_unset(value.addr)
  let icon_theme = gtk_icon_theme_get_default()
  for path in icons:
    gtk_icon_theme_append_search_path(icon_theme, path.cstring)
  result = widget.build()
  let screen = gdk_screen_get_default()
  for stylesheet in stylesheets:
    var error: GError
    let provider = gtk_css_provider_new()
    discard gtk_css_provider_load_from_path(provider, stylesheet.cstring, error.addr)
    if not error.is_nil:
      raise new_exception(IoError, $error[].message)
    gtk_style_context_add_provider_for_screen(screen, provider, 600)

proc brew*(widget: Widget,
           icons: openArray[string] = [],
           dark_theme: bool = false,
           stylesheets: openArray[string] = []) =
  gtk_init()
  discard setup_app(widget, icons, dark_theme, stylesheets)
  gtk_main()

proc brew*(id: string, widget: Widget,
           icons: openArray[string] = [],
           dark_theme: bool = false,
           stylesheets: openArray[string] = []) =
  type Closure = object
    widget: Widget
    icons: seq[string]
    dark_theme: bool
    stylesheets: seq[string]
  
  proc activate_callback(app: GApplication, data: ptr Closure) {.cdecl.} =
    let state = setup_app(
      data[].widget,
      data[].icons,
      data[].dark_theme,
      data[].stylesheets
    )
    gtk_application_add_window(app, state.unwrap_renderable().internal_widget)
  
  let app = gtk_application_new(id.cstring, G_APPLICATION_FLAGS_NONE)
  defer: g_object_unref(app.pointer)
  var closure = Closure(
    widget: widget,
    icons: @icons,
    dark_theme: dark_theme,
    stylesheets: @stylesheets
  )
  discard g_signal_connect(app, "activate", activate_callback, closure.addr)
  let status = g_application_run(app)
