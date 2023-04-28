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

import owlkettle/[gtk, widgetutils, widgetdef, widgets, guidsl, mainloop]
export widgetdef except build_bin, update_bin
export widgets, guidsl
export Align
export Stylesheet, newStylesheet, loadStylesheet

proc writeClipboard*(state: WidgetState, text: string) =
  let
    widget = state.unwrapRenderable().internalWidget
    display = gtk_widget_get_display(widget)
    clipboard = gdk_display_get_clipboard(display)
  gdk_clipboard_set_text(clipboard, text.cstring, text.len.cint)

type NotificationPriority* = enum
  NotificationNormal,
  NotificationLow,
  NotificationHigh,
  NotificationUrgent

proc toGtk(priority: NotificationPriority): GNotificationPriority =
  result = GNotificationPriority(ord(priority))

const ERROR_APP_ID =
  "Unable to send notification: " &
  "The Application does not have an application id. " &
  "Please pass the application id as the first parameter of the brew procedure. " &
  "Example: brew(\"com.example.MyApplication\", gui(App()))"

proc sendNotification*(id, title, body: string,
                       category: string = "",
                       icon: string = "",
                       priority: NotificationPriority = NotificationNormal) =
  let app = g_application_get_default()
  if app.isNil:
    raise newException(IoError, ERROR_APP_ID)
  
  let notification = g_notification_new(title.cstring)
  g_notification_set_priority(notification, toGtk(priority))
  
  if body.len > 0:
    g_notification_set_body(notification, body.cstring)
  if category.len > 0:
    g_notification_set_category(notification, category.cstring)
  
  if icon.len > 0:
    var err = GError(nil)
    let gIcon = g_icon_new_for_string(icon.cstring, err.addr)
    if not err.isNil:
      raise newException(IoError, "Icon \"" & icon & "\" is unknown")
    g_notification_set_icon(notification, gIcon)
    g_object_unref(pointer(gIcon))
  
  g_application_send_notification(app, id.cstring, notification)

proc withdrawNotification*(id: string) =
  let app = g_application_get_default()
  if app.isNil:
    raise newException(IoError, ERROR_APP_ID)
  g_application_withdraw_notification(app, id.cstring)

proc redrawFromThread*(viewable: Viewable, priority: int = 200) =
  when compileOption("threads"):
    proc fn(data: pointer): cbool {.cdecl.} =
      let cell = cast[ptr Viewable](data)
      discard unwrapSharedCell(cell).redraw()
    
    let data = allocSharedCell(viewable)
    discard g_idle_add_full(cint(priority), fn, data, nil)
  else:
    raise newException(IoError, "Threading is disabled")

type
  TimeoutProc* = proc(): bool {.closure.}
  EventDescriptor* = distinct cuint

proc `==`*(a, b: EventDescriptor): bool {.borrow.}
proc `$`*(event: EventDescriptor): string = "event" & $cuint(event)
proc isNil*(event: EventDescriptor): bool = cuint(event) == 0

proc allocCallback(fn: TimeoutProc): tuple[call: GSourceFunc, data: ptr TimeoutProc, destroy: GDestroyNotify] =
  proc call(data: pointer): cbool {.cdecl.} =
    let fn = cast[ptr TimeoutProc](data)
    result = cbool(ord(fn[]()))
  
  proc destroy(data: pointer) {.cdecl.} =
    let fn = cast[ptr TimeoutProc](data)
    reset(fn[])
    deallocShared(fn)
  
  result.call = call
  result.destroy = destroy
  
  result.data = cast[ptr TimeoutProc](allocShared0(sizeof(ptr TimeoutProc)))
  result.data[] = fn

proc addGlobalTimeout*(interval: int, fn: TimeoutProc, priority: int = 200): EventDescriptor =
  let (call, data, destroy) = allocCallback(fn)
  result = EventDescriptor(g_timeout_add_full(
    cint(priority), cuint(interval), call, data, destroy
  ))

proc addGlobalIdleTask*(fn: TimeoutProc, priority: int = 200): EventDescriptor =
  let (call, data, destroy) = allocCallback(fn)
  result = EventDescriptor(g_idle_add_full(
    cint(priority), call, data, destroy
  ))

proc remove*(event: EventDescriptor) =
  if g_source_remove(cuint(event)) == 0:
    raise newException(IoError, "Unable to remove " & $event)

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

proc respond*(state: WidgetState, response: DialogResponse) =
  let
    widget = state.unwrapInternalWidget()
    root = gtk_widget_get_root(widget)
  gtk_dialog_response(root, response.toGtk())

proc closeWindow*(state: WidgetState) =
  let
    widget = state.unwrapInternalWidget()
    root = gtk_widget_get_root(widget)
  gtk_window_close(root)

proc brew*(widget: Widget,
           icons: openArray[string] = [],
           darkTheme: bool = false,
           stylesheets: openArray[Stylesheet] = []) =
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
           stylesheets: openArray[Stylesheet] = []) =
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
