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

import owlkettle/[gtk, widgetdef, widgets, guidsl, mainloop]
export widgetdef, widgets, guidsl

proc write_clipboard*(state: WidgetState, text: string) =
  let
    widget = state.unwrap_renderable().internal_widget
    display = gtk_widget_get_display(widget)
    clipboard = gdk_display_get_clipboard(display)
  gdk_clipboard_set_text(clipboard, text.cstring, text.len.cint)

proc open*(app: Viewable, widget: Widget): tuple[res: DialogResponse, state: WidgetState] =
  let
    state = WidgetState(widget.build())
    dialog_state = state.unwrap_renderable()
    window = app.unwrap_internal_widget()
    dialog = state.unwrap_internal_widget()
  gtk_window_set_transient_for(dialog, window)
  gtk_window_set_modal(dialog, cbool(bool(true)))
  gtk_window_present(dialog)
  
  if dialog_state of DialogState or dialog_state of BuiltinDialogState:
    proc response(dialog: GtkWidget, response_id: cint, res: ptr cint) {.cdecl.} =
      res[] = response_id
    
    var res = low(cint)
    discard g_signal_connect(dialog, "response", response, res.addr)
    while res == low(cint):
      discard g_main_context_iteration(nil, cbool(ord(true)))
    
    state.read()
    gtk_window_destroy(dialog)
    result = (to_dialog_response(res), state)
  else:
    proc destroy(dialog: GtkWidget, closed: ptr bool) {.cdecl.} =
      closed[] = true
    
    var closed = false
    discard g_signal_connect(dialog, "destroy", destroy, closed.addr)
    while not closed:
      discard g_main_context_iteration(nil, cbool(ord(true)))
    
    state.read()
    result = (DialogResponse(), state)

proc brew*(widget: Widget,
           icons: openArray[string] = [],
           dark_theme: bool = false,
           stylesheets: openArray[string] = []) =
  gtk_init()
  let state = setup_app(AppConfig(
    widget: widget,
    icons: @icons,
    dark_theme: dark_theme,
    stylesheets: @stylesheets
  ))
  run_mainloop(state)

proc brew*(id: string, widget: Widget,
           icons: openArray[string] = [],
           dark_theme: bool = false,
           stylesheets: openArray[string] = []) =
  var config = AppConfig(
    widget: widget,
    icons: @icons,
    dark_theme: dark_theme,
    stylesheets: @stylesheets
  )
  
  proc activate_callback(app: GApplication, data: ptr AppConfig) {.cdecl.} =
    let
      state = setup_app(data[])
      window = state.unwrap_renderable().internal_widget
    gtk_window_present(window)
    gtk_application_add_window(app, window)
  
  let app = gtk_application_new(id.cstring, G_APPLICATION_FLAGS_NONE)
  defer: g_object_unref(app.pointer)
  
  discard g_signal_connect(app, "activate", activate_callback, config.addr)
  let status = g_application_run(app)
