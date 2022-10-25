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
export widgetdef except build_bin, update_bin
export widgets, guidsl

proc writeClipboard*(state: WidgetState, text: string) =
  let
    widget = state.unwrapRenderable().internalWidget
    display = gtk_widget_get_display(widget)
    clipboard = gdk_display_get_clipboard(display)
  gdk_clipboard_set_text(clipboard, text.cstring, text.len.cint)

proc open*(app: Viewable, widget: Widget): tuple[res: DialogResponse, state: WidgetState] =
  let
    state = widget.build()
    dialogState = state.unwrapRenderable()
    window = app.unwrapInternalWidget()
    dialog = state.unwrapInternalWidget()
  gtk_window_set_transient_for(dialog, window)
  gtk_window_set_modal(dialog, cbool(bool(true)))
  gtk_window_present(dialog)
  
  proc destroy(dialog: GtkWidget, closed: ptr bool) {.cdecl.} =
    closed[] = true
  
  var closed = false
  discard g_signal_connect(dialog, "destroy", destroy, closed.addr)
  
  if dialogState of DialogState or dialogState of BuiltinDialogState:
    proc response(dialog: GtkWidget, responseId: cint, res: ptr cint) {.cdecl.} =
      res[] = responseId
    
    var res = low(cint)
    discard g_signal_connect(dialog, "response", response, res.addr)
    while res == low(cint):
      discard g_main_context_iteration(nil.GMainContext, cbool(ord(true)))
    
    state.read()
    if not closed:
      gtk_window_destroy(dialog)
    result = (toDialogResponse(res), state)
  else:
    while not closed:
      discard g_main_context_iteration(nil.GMainContext, cbool(ord(true)))
    
    state.read()
    result = (DialogResponse(), state)

proc brew*(widget: Widget,
           icons: openArray[string] = [],
           darkTheme: bool = false,
           stylesheets: openArray[string] = []) =
  gtk_init()
  let state = setupApp(AppConfig(
    widget: widget,
    icons: @icons,
    dark_theme: darkTheme,
    stylesheets: @stylesheets
  ))
  runMainloop(state)

proc brew*(id: string, widget: Widget,
           icons: openArray[string] = [],
           darkTheme: bool = false,
           stylesheets: openArray[string] = []) =
  var config = AppConfig(
    widget: widget,
    icons: @icons,
    dark_theme: darkTheme,
    stylesheets: @stylesheets
  )
  
  proc activateCallback(app: GApplication, data: ptr AppConfig) {.cdecl.} =
    let
      state = setupApp(data[])
      window = state.unwrapRenderable().internalWidget
    gtk_window_present(window)
    gtk_application_add_window(app, window)
  
  let app = gtk_application_new(id.cstring, G_APPLICATION_FLAGS_NONE)
  defer: g_object_unref(app.pointer)
  
  discard g_signal_connect(app, "activate", activateCallback, config.addr)
  discard g_application_run(app)
