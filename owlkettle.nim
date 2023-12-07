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

import owlkettle/[widgetutils, widgetdef, widgets, guidsl, mainloop]
import owlkettle/bindings/gtk
export widgetdef except build_bin, update_bin
export widgets, guidsl
export Align
export Stylesheet, ApplicationEvent, newStylesheet, loadStylesheet

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
  when defined(gcDestructors):
    `=wasMoved`(result.data[])
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
           startupEvents: openArray[ApplicationEvent] = [],
           shutdownEvents: openArray[ApplicationEvent] = [],
           stylesheets: openArray[Stylesheet] = []) =
  gtk_init()
  let config = AppConfig(
    widget: widget,
    icons: @icons,
    darkTheme: darkTheme,
    stylesheets: @stylesheets
  )
  
  let state = setupApp(config)
  
  var context = AppContext[AppConfig](
    config: config,
    state: state,
    startupEvents: @startupEvents,
    shutdownEvents: @shutdownEvents
  )
  context.execStartupEvents()
  runMainloop(state)
  context.execShutdownEvents()

proc brew*(id: string,
           widget: Widget,
           icons: openArray[string] = [],
           darkTheme: bool = false,
           startupEvents: openArray[ApplicationEvent] = [],
           shutdownEvents: openArray[ApplicationEvent] = [],
           stylesheets: openArray[Stylesheet] = []) =
  var config = AppConfig(
    widget: widget,
    icons: @icons,
    darkTheme: darkTheme,
    stylesheets: @stylesheets,
  )
  
  var context = AppContext[AppConfig](
    config: config,
    startupEvents: @startupEvents,
    shutdownEvents: @shutdownEvents
  )
  
  proc activateCallback(app: GApplication, data: ptr AppContext[AppConfig]) {.cdecl.} =
    let
      state = setupApp(data[].config)
      window = state.unwrapRenderable().internalWidget
    gtk_window_present(window)
    gtk_application_add_window(app, window)
    
    data[].state = state
    data[].execStartupEvents()
  
  let app = gtk_application_new(id.cstring, G_APPLICATION_FLAGS_NONE)
  defer: g_object_unref(app.pointer)
  
  proc shutdownCallback(app: GApplication, data: ptr AppContext[AppConfig]) {.cdecl.} =
    data[].execShutdownEvents()

  discard g_signal_connect(app, "activate", activateCallback, context.addr)
  discard g_signal_connect(app, "shutdown", shutdownCallback, context.addr)
  discard g_application_run(app)
