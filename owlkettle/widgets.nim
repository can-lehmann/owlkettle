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

# Default widgets

import std/[unicode, sets]
import gtk, widgetdef, cairo

when defined(owlkettle_docs):
  echo "# Widgets\n\n"

proc event_callback(widget: GtkWidget, data: ptr EventObj[proc ()]) =
  data[].callback()
  if data[].app.is_nil:
    raise new_exception(ValueError, "App is nil")
  data[].app.redraw()

proc entry_event_callback(widget: GtkWidget, data: ptr EventObj[proc (text: string)]) =
  data[].callback($gtk_editable_get_text(widget))
  if data[].app.is_nil:
    raise new_exception(ValueError, "App is nil")
  data[].app.redraw()

proc switch_event_callback(widget: GtkWidget, state: cbool, data: ptr EventObj[proc (state: bool)]) =
  data[].callback(state != 0)
  if data[].app.is_nil:
    raise new_exception(ValueError, "App is nil")
  data[].app.redraw()

proc toggle_button_event_callback(widget: GtkWidget, data: ptr EventObj[proc (state: bool)]) =
  data[].callback(gtk_toggle_button_get_active(widget) != 0)
  if data[].app.is_nil:
    raise new_exception(ValueError, "App is nil")
  data[].app.redraw()

proc check_button_event_callback(widget: GtkWidget, data: ptr EventObj[proc (state: bool)]) =
  data[].callback(gtk_check_button_get_active(widget) != 0)
  if data[].app.is_nil:
    raise new_exception(ValueError, "App is nil")
  data[].app.redraw()

proc draw_event_callback(widget: GtkWidget,
                         ctx: CairoContext,
                         data: ptr EventObj[proc (ctx: CairoContext, size: (int, int)): bool]): cbool =
  let requires_redraw = data[].callback(ctx, (
    int(gtk_widget_get_allocated_width(widget)),
    int(gtk_widget_get_allocated_height(widget))
  ))
  if requires_redraw:
    if data[].app.is_nil:
      raise new_exception(ValueError, "App is nil")
    data[].app.redraw()

proc color_event_callback(widget: GtkWidget, data: ptr EventObj[proc (color: tuple[r, g, b, a: float])]) =
  var color: GdkRgba
  gtk_color_chooser_get_rgba(widget, color.addr)
  data[].callback((color.r.float, color.g.float, color.b.float, color.a.float))
  if data[].app.is_nil:
    raise new_exception(ValueError, "App is nil")
  data[].app.redraw()

proc list_box_event_callback(widget: GtkWidget, data: ptr EventObj[proc (state: HashSet[int])]) =
  let selected = gtk_list_box_get_selected_rows(widget)
  var
    rows = init_hash_set[int]()
    cur = selected
  while not cur.is_nil:
    rows.incl(int(gtk_list_box_row_get_index(GtkWidget(cur[].data))))
    cur = cur[].next
  g_list_free(selected)
  data[].callback(rows)
  if data[].app.is_nil:
    raise new_exception(ValueError, "App is nil")
  data[].app.redraw()


proc connect[T](widget: GtkWidget,
                event: Event[T],
                name: cstring,
                event_callback: pointer) =
  if not event.is_nil:
    event.handler = g_signal_connect(widget, name, event_callback, event[].addr)

proc disconnect[T](widget: GtkWidget, event: Event[T]) =
  if not event.is_nil:
    assert event.handler > 0
    g_signal_handler_disconnect(widget, event.handler)

proc update_style[State, Widget](state: State, widget: Widget) =
  mixin classes
  if widget.has_style:
    let ctx = gtk_widget_get_style_context(state.internal_widget)
    for class_name in classes(state.style - widget.val_style):
      gtk_style_context_remove_class(ctx, class_name.cstring)
    for class_name in classes(widget.val_style - state.style):
      gtk_style_context_add_class(ctx, class_name.cstring)
    state.style = widget.val_style

type Margin* = object
  top*, bottom*, left*, right*: int

renderable BaseWidget:
  sensitive: bool = true
  size_request: tuple[x, y: int] = (-1, -1)
  internal_margin: Margin = Margin()
  hexpand: bool = false
  vexpand: bool = false
  
  hooks sensitive:
    property:
      gtk_widget_set_sensitive(state.internal_widget, cbool(ord(state.sensitive)))
  
  hooks size_request:
    property:
      gtk_widget_set_size_request(state.internal_widget,
        cint(state.size_request.x),
        cint(state.size_request.y)
      )

  hooks internal_margin:
    (build, update):
      if widget.has_internal_margin:
        state.internal_margin = widget.val_internal_margin
        gtk_widget_set_margin_top(state.internal_widget, cint(state.internal_margin.top))
        gtk_widget_set_margin_bottom(state.internal_widget, cint(state.internal_margin.bottom))
        gtk_widget_set_margin_start(state.internal_widget, cint(state.internal_margin.left))
        gtk_widget_set_margin_end(state.internal_widget, cint(state.internal_margin.right))
  
  hooks hexpand:
    property:
      gtk_widget_set_hexpand(state.internal_widget, cbool(ord(state.hexpand)))
  
  hooks vexpand:
    property:
      gtk_widget_set_vexpand(state.internal_widget, cbool(ord(state.vexpand)))
  
  setter margin: int

proc `has_margin=`*(widget: BaseWidget, has: bool) =
  widget.has_internal_margin = has

proc `val_margin=`*(widget: BaseWidget, width: int) =
  widget.val_internal_margin = Margin(top: width, bottom: width, left: width, right: width)

proc `val_margin=`*(widget: BaseWidget, margin: Margin) =
  widget.val_internal_margin = margin

template build_bin(state, widget, child, has_child, val_child, set_child: untyped) =
  if widget.has_child:
    widget.val_child.assign_app(state.app)
    state.child = widget.val_child.build()
    let child_widget = unwrap_renderable(state.child).internal_widget
    set_child(state.internal_widget, child_widget)

template build_bin(state, widget, set_child: untyped) =
  build_bin(state, widget, child, has_child, val_child, set_child)

template update_bin(state, widget, child, has_child, val_child, set_child: untyped) =
  if widget.has_child:
    widget.val_child.assign_app(state.app)
    let new_child = widget.val_child.update(state.child)
    if not new_child.is_nil:
      let child_widget = new_child.unwrap_internal_widget()
      set_child(state.internal_widget, child_widget)
      state.child = new_child

template update_bin(state, widget, set_child: untyped) =
  update_bin(state, widget, child, has_child, val_child, set_child)

renderable Window of BaseWidget:
  title: string
  titlebar: Widget
  default_size: tuple[width, height: int] = (800, 600)
  child: Widget
  
  proc close()
  
  hooks:
    before_build:
      state.internal_widget = gtk_window_new(GTK_WINDOW_TOPLEVEL)
    connect_events:
      state.internal_widget.connect(state.close, "destroy", event_callback)
    disconnect_events:
      state.internal_widget.disconnect(state.close)
  
  hooks title:
    property:
      if state.titlebar.is_nil:
        gtk_window_set_title(state.internal_widget, state.title.cstring)
  
  hooks titlebar:
    build:
      if widget.has_titlebar:
        widget.val_titlebar.assign_app(state.app)
        state.titlebar = widget.val_titlebar.build()
        gtk_window_set_titlebar(state.internal_widget,
          state.titlebar.unwrap_internal_widget()
        )
    update:
      if widget.has_titlebar:
        widget.val_titlebar.assign_app(state.app)
        let new_titlebar = widget.val_titlebar.update(state.titlebar)
        if not new_titlebar.is_nil:
          state.titlebar = new_titlebar
          gtk_window_set_titlebar(state.internal_widget,
            state.titlebar.unwrap_internal_widget()
          )
  
  hooks default_size:
    property:
      gtk_window_set_default_size(state.internal_widget,
        state.default_size.width.cint,
        state.default_size.height.cint
      )
  
  hooks child:
    build: build_bin(state, widget, gtk_window_set_child)
    update: update_bin(state, widget, gtk_window_set_child)
  
  example:
    Window:
      Label(text = "Hello, world")
  
  example:
    Window:
      proc close() =
        quit()
      
      Label(text = "Hello, world")

proc add*(window: Window, child: Widget) =
  if window.has_child:
    raise new_exception(ValueError, "Unable to add multiple children to a Window. Use a Box widget to display multiple widgets in a Window.")
  window.has_child = true
  window.val_child = child

proc add_titlebar*(window: Window, titlebar: Widget) =
  window.has_titlebar = true
  window.val_titlebar = titlebar

type Orient* = enum OrientX, OrientY

proc to_gtk(orient: Orient): GtkOrientation =
  result = [GTK_ORIENTATION_HORIZONTAL, GTK_ORIENTATION_VERTICAL][ord(orient)]

type BoxStyle* = enum
  BoxLinked

iterator classes(styles: set[BoxStyle]): string =
  for style in styles:
    yield [
      BoxLinked: "linked"
    ][style]

renderable Box of BaseWidget:
  orient: Orient
  spacing: int
  children: seq[Widget]
  style: set[BoxStyle]
  
  hooks:
    before_build:
      state.internal_widget = gtk_box_new(
        to_gtk(widget.val_orient),
        widget.val_spacing.cint
      )
  
  hooks spacing:
    property:
      gtk_box_set_spacing(state.internal_widget, state.spacing.cint)

  hooks children:
    (build, update):
      if widget.has_children:
        widget.val_children.assign_app(state.app)
        var it = 0
        while it < widget.val_children.len and it < state.children.len:
          let
            child = widget.val_children[it]
            new_child = child.update(state.children[it])
          if not new_child.is_nil:
            gtk_box_remove(
              state.internal_widget,
              state.children[it].unwrap_internal_widget()
            )
            var sibling: GtkWidget = nil
            if it > 0:
              sibling = state.children[it - 1].unwrap_internal_widget()
            let new_widget = new_child.unwrap_internal_widget()
            gtk_box_insert_child_after(state.internal_widget, new_widget, sibling)
            state.children[it] = new_child
          it += 1
        while it < widget.val_children.len:
          let child = widget.val_children[it].build()
          gtk_box_append(state.internal_widget, child.unwrap_internal_widget())
          state.children.add(child)
          it += 1
        while it < state.children.len:
          gtk_box_remove(
            state.internal_widget,
            state.children[^1].unwrap_internal_widget()
          )
          discard state.children.pop()
  
  hooks style:
    (build, update):
      update_style(state, widget)
  
  example:
    Box:
      orient = OrientX
      Label(text = "Label")
      Button(text = "Button") {.expand: false.}

proc add*(box: Box, child: Widget) =
  box.has_children = true
  box.val_children.add(child)

proc add*(box: Box, child: BaseWidget, expand: bool) =
  child.has_hexpand = true
  child.val_hexpand = expand
  child.has_vexpand = true
  child.val_vexpand = expand
  box.has_children = true
  box.val_children.add(child)

type EllipsizeMode* = enum
  EllipsizeNone, EllipsizeStart, EllipsizeMiddle, EllipsizeEnd

renderable Label of BaseWidget:
  text: string
  x_align: float = 0.5
  y_align: float = 0.5
  ellipsize: EllipsizeMode
  wrap: bool = false
  use_markup: bool = false
  
  hooks:
    before_build:
      state.internal_widget = gtk_label_new("")
  
  hooks text:
    property:
      gtk_label_set_text(state.internal_widget, state.text.cstring)

  hooks x_align:
    property:
      gtk_label_set_xalign(state.internal_widget, state.xalign.cdouble)
  
  hooks y_align:
    property:
      gtk_label_set_yalign(state.internal_widget, state.yalign.cdouble)
  
  hooks ellipsize:
    property:
      gtk_label_set_ellipsize(state.internal_widget, PangoEllipsizeMode(ord(state.ellipsize)))
  
  hooks wrap:
    property:
      gtk_label_set_wrap(state.internal_widget, cbool(ord(state.wrap)))
  
  hooks use_markup:
    property:
      gtk_label_set_use_markup(state.internal_widget, cbool(ord(state.use_markup)))
  
  example:
    Label:
      text = "Hello, world!"
      x_align = 0.0
      ellipsize = EllipsizeEnd
  
  example:
    Label:
      text = "Test ".repeat(50)
      line_wrap = true
  
  example:
    Label:
      text = "<b>Bold</b>, <i>Italic</i>, <span font=\"20\">Font Size</span>"
      use_markup = true

renderable Icon of BaseWidget:
  name: string
  pixel_size: int = -1
  
  hooks:
    before_build:
      state.internal_widget = gtk_image_new()
  
  hooks name:
    property:
      gtk_image_set_from_icon_name(state.internal_widget, state.name.cstring, GTK_ICON_SIZE_BUTTON)
  
  hooks pixel_size:
    property:
      gtk_image_set_pixel_size(state.internal_widget, state.pixel_size.cint)
  
  example:
    Icon:
      name = "list-add-symbolic"
  
  example:
    Icon:
      name = "object-select-symbolic"
      pixel_size = 100

type ButtonStyle* = enum
  ButtonSuggested, ButtonDestructive, ButtonFlat

iterator classes(styles: set[ButtonStyle]): string =
  for style in styles:
    yield [
      ButtonSuggested: "suggested-action",
      ButtonDestructive: "destructive-action",
      ButtonFlat: "flat"
    ][style]

renderable Button of BaseWidget:
  style: set[ButtonStyle]
  child: Widget
  
  proc clicked()
  
  hooks:
    before_build:
      state.internal_widget = gtk_button_new()
    connect_events:
      state.internal_widget.connect(state.clicked, "clicked", event_callback)
    disconnect_events:
      state.internal_widget.disconnect(state.clicked)
  
  hooks style:
    (build, update):
      update_style(state, widget)
  
  hooks child:
    build: build_bin(state, widget, gtk_button_set_child)
    update: update_bin(state, widget, gtk_button_set_child)
  
  example:
    Button:
      icon = "list-add-symbolic"
      style = {ButtonSuggested}
      proc clicked() =
        echo "clicked"
  
  example:
    Button:
      text = "Delete"
      style = {ButtonDestructive}
  
  example:
    Button:
      text = "Inactive Button"
      sensitive = false

proc add*(button: Button, child: Widget) =
  if button.has_child:
    raise new_exception(ValueError, "Unable to add multiple children to a Button. Use a Box widget to display multiple widgets in a Button.")
  button.has_child = true
  button.val_child = child

proc `has_text=`*(button: Button, value: bool) = button.has_child = value
proc `val_text=`*(button: Button, value: string) =
  button.val_child = Label(has_text: true, val_text: value)

proc `has_icon=`*(button: Button, value: bool) = button.has_child = value
proc `val_icon=`*(button: Button, name: string) =
  button.val_child = Icon(has_name: true, val_name: name)


proc update_header_bar(internal_widget: GtkWidget,
                       children: var seq[WidgetState],
                       target: seq[Widget],
                       pack: proc(widget, child: GtkWidget) {.cdecl, locks: 0.}) =
  var it = 0
  while it < target.len and it < children.len:
    let new_child = target[it].update(children[it])
    assert new_child.is_nil
    it += 1
  while it < target.len:
    let
      child = target[it].build()
      child_widget = child.unwrap_internal_widget()
    pack(internal_widget, child_widget)
    children.add(child)
    it += 1
  while it < children.len:
    gtk_header_bar_remove(internal_widget, children[it].unwrap_internal_widget())
    children.del(it)

renderable HeaderBar of BaseWidget:
  title: Widget
  show_title_buttons: bool = true
  left: seq[Widget]
  right: seq[Widget]
  
  hooks:
    before_build:
      state.internal_widget = gtk_header_bar_new()
  
  hooks show_title_buttons:
    property:
      gtk_header_bar_set_show_title_buttons(state.internal_widget, cbool(ord(state.show_title_buttons)))
  
  hooks left:
    (build, update):
      if widget.has_left:
        widget.val_left.assign_app(state.app)
        update_header_bar(
          state.internal_widget,
          state.left, widget.val_left,
          gtk_header_bar_pack_start
        )
  
  hooks right:
    (build, update):
      if widget.has_right:
        widget.val_right.assign_app(state.app)
        update_header_bar(
          state.internal_widget,
          state.right, widget.val_right,
          gtk_header_bar_pack_end
        )
  
  hooks title:
    build: build_bin(state, widget, title, has_title, val_title, gtk_header_bar_set_title_widget)
    update: update_bin(state, widget, title, has_title, val_title, gtk_header_bar_set_title_widget)
  
  
  example:
    Window:
      border_width = 12
      
      HeaderBar {.add_titlebar.}:
        title = "Title"
        subtitle = "Subtitle"
        
        Button {.add_left.}:
          icon = "list-add-symbolic"
        
        Button {.add_right.}:
          icon = "open-menu-symbolic"

proc add_title*(header_bar: HeaderBar, child: Widget) =
  if header_bar.has_title:
    raise new_exception(ValueError, "Unable to add multiple title widgets to a HeaderBar.")
  header_bar.has_title = true
  header_bar.val_title = child

proc add_left*(header_bar: HeaderBar, child: Widget) =
  header_bar.has_left = true
  header_bar.val_left.add(child)

proc add_right*(header_bar: HeaderBar, child: Widget) =
  header_bar.has_right = true
  header_bar.val_right.add(child)

renderable ScrolledWindow of BaseWidget:
  child: Widget
  
  hooks:
    before_build:
      state.internal_widget = gtk_scrolled_window_new(nil, nil)
  
  hooks child:
    build: build_bin(state, widget, gtk_scrolled_window_set_child)
    update: update_bin(state, widget, gtk_scrolled_window_set_child)

proc add*(window: ScrolledWindow, child: Widget) =
  if window.has_child:
    raise new_exception(ValueError, "Unable to add multiple children to a ScrolledWindow. Use a Box widget to display multiple widgets in a ScrolledWindow.")
  window.has_child = true
  window.val_child = child

renderable Entry of BaseWidget:
  text: string
  placeholder: string
  width: int = -1
  x_align: float = 0.0
  visibility: bool = true
  invisible_char: Rune = '*'.Rune
  
  proc changed(text: string)
  proc activate()

  hooks:
    before_build:
      state.internal_widget = gtk_entry_new()
    connect_events:
      state.internal_widget.connect(state.changed, "changed", entry_event_callback)
      state.internal_widget.connect(state.activate, "activate", event_callback)
    disconnect_events:
      state.internal_widget.disconnect(state.changed)
      state.internal_widget.disconnect(state.activate)


  hooks text:
    property:
      gtk_editable_set_text(state.internal_widget, state.text.cstring)
    read:
      state.text = $gtk_editable_get_text(state.internal_widget)
  
  hooks placeholder:
    property:
      gtk_entry_set_placeholder_text(state.internal_widget, state.placeholder.cstring)
  
  hooks width:
    property:
      gtk_editable_set_width_chars(state.internal_widget, state.width.cint)
  
  hooks x_align:
    property:
      gtk_entry_set_alignment(state.internal_widget, state.x_align.cfloat)

  hooks visibility:
    property:
      gtk_entry_set_visibility(state.internal_widget, cbool(ord(state.visibility)))

  hooks invisible_char:
    property:
      gtk_entry_set_invisible_char(state.internal_widget, state.invisible_char.uint32)

  
  example:
    Entry:
      text = app.text
      proc changed(text: string) =
        app.text = text
  
  example:
    Entry:
      text = app.query
      placeholder = "Search..."
      proc changed(query: string) =
        app.query = query
      proc activate() =
        ## Runs when enter is pressed
        echo app.query
  
  example:
    Entry:
      placeholder = "Password"
      visibility = false
      invisible_char = '*'.Rune

type PanedChild[T] = object
  widget: T
  resize: bool
  shrink: bool

proc build_paned_child(child: PanedChild[Widget],
                       app: Viewable,
                       internal_widget: GtkWidget,
                       set_child: proc(paned, child: GtkWidget) {.cdecl, locks: 0.},
                       set_resize: proc(paned: GtkWidget, val: cbool) {.cdecl, locks: 0.},
                       set_shrink: proc(paned: GtkWidget, val: cbool) {.cdecl, locks: 0.}): PanedChild[WidgetState] =
  child.widget.assign_app(app)
  result = PanedChild[WidgetState](
    widget: child.widget.build(),
    resize: child.resize,
    shrink: child.shrink
  )
  set_child(internal_widget, result.widget.unwrap_internal_widget())
  set_resize(internal_widget, cbool(ord(child.resize)))
  set_shrink(internal_widget, cbool(ord(child.shrink)))

proc update_paned_child(state: var PanedChild[WidgetState],
                        target: PanedChild[Widget],
                        app: Viewable) =
  target.widget.assign_app(app)
  assert target.resize == state.resize
  assert target.shrink == state.shrink
  let new_child = target.widget.update(state.widget)
  assert new_child.is_nil


renderable Paned of BaseWidget:
  orient: Orient
  initial_position: int
  first: PanedChild[Widget]
  second: PanedChild[Widget]
  
  hooks:
    before_build:
      state.internal_widget = gtk_paned_new(to_gtk(widget.val_orient))
      state.orient = widget.val_orient
  
  hooks first:
    build:
      if widget.has_first:
        state.first = widget.val_first.build_paned_child(
          state.app, state.internal_widget,
          gtk_paned_set_start_child,
          gtk_paned_set_resize_start_child,
          gtk_paned_set_shrink_start_child
        )
    update:
      if widget.has_first:
        state.first.update_paned_child(widget.val_first, state.app)

  hooks initial_position:
    build:
      if widget.has_initial_position:
        state.initial_position = widget.val_initial_position
        gtk_paned_set_position(state.internal_widget, cint(state.initial_position))
  
  hooks second:
    build:
      if widget.has_second:
        state.second = widget.val_second.build_paned_child(
          state.app, state.internal_widget,
          gtk_paned_set_end_child,
          gtk_paned_set_resize_end_child,
          gtk_paned_set_shrink_end_child
        )
    update:
      if widget.has_second:
        state.second.update_paned_child(widget.val_second, state.app)

proc add*(paned: Paned, child: Widget, resize: bool = true, shrink: bool = false) =
  let paned_child = PanedChild[Widget](
    widget: child,
    resize: resize,
    shrink: shrink
  )
  if paned.has_first:
    paned.has_second = true
    paned.val_second = paned_child
  else:
    paned.has_first = true
    paned.val_first = paned_child

#[
type
  ModifierKey* = enum
    ModifierCtrl, ModifierAlt, ModifierShift,
    ModifierSuper, ModifierMeta, ModifierHyper
  
  ButtonEvent* = object
    time*: uint32
    button*: int
    x*, y*: float
    modifiers*: set[ModifierKey]
  
  MotionEvent* = object
    time*: uint32
    x*, y*: float
    modifiers*: set[ModifierKey]
  
  KeyEvent* = object
    time*: uint32
    rune*: Rune
    value*: int
    modifiers*: set[ModifierKey]

proc init_modifier_set(state: GdkModifierType): set[ModifierKey] =
  const MODIFIERS = [
    (GDK_CONTROL_MASK, ModifierCtrl),
    (GDK_ALT_MASK, ModifierAlt),
    (GDK_SHIFT_MASK, ModifierShift),
    (GDK_SUPER_MASK, ModifierSuper),
    (GDK_HYPER_MASK, ModifierHyper)
  ]
  for (mask, key) in MODIFIERS:
    if mask in state:
      result.incl(key)

proc button_event_callback(widget: GtkWidget,
                           event: GdkEventButton,
                           data: ptr EventObj[proc (event: ButtonEvent)]): cbool =
  var evt = ButtonEvent(
    time: event[].time,
    button: int(event[].button) - 1,
    x: float(event[].x),
    y: float(event[].y)
  )
  var state: GdkModifierType
  if gdk_event_get_state(cast[GdkEvent](event), state.addr) != cbool(0):
    evt.modifiers = init_modifier_set(state)
  data[].callback(evt)
  if data[].app.is_nil:
    raise new_exception(ValueError, "App is nil")
  data[].app.redraw()

proc motion_event_callback(widget: GtkWidget,
                           event: GdkEventMotion,
                           data: ptr EventObj[proc (event: MotionEvent)]): cbool =
  var evt = MotionEvent(
    time: event[].time,
    x: float(event[].x),
    y: float(event[].y)
  )
  var state: GdkModifierType
  if gdk_event_get_state(cast[GdkEvent](event), state.addr) != cbool(0):
    evt.modifiers = init_modifier_set(state)
  data[].callback(evt)
  if data[].app.is_nil:
    raise new_exception(ValueError, "App is nil")
  data[].app.redraw()

proc key_event_callback(widget: GtkWidget,
                        event: GdkEventKey,
                        data: ptr EventObj[proc (event: KeyEvent): bool]): cbool =
  var evt = KeyEvent(
    time: event[].time,
    rune: Rune(gdk_keyval_to_unicode(event[].key_val)),
    value: event[].key_val.int
  )
  var state: GdkModifierType
  if gdk_event_get_state(cast[GdkEvent](event), state.addr) != cbool(0):
    evt.modifiers = init_modifier_set(state)
  result = cbool(ord(data[].callback(evt)))
  if data[].app.is_nil:
    raise new_exception(ValueError, "App is nil")
  data[].app.redraw()

renderable DrawingArea of BaseWidget:
  focusable: bool
  
  proc draw(ctx: CairoContext, size: (int, int)): bool
  proc mouse_pressed(event: ButtonEvent)
  proc mouse_released(event: ButtonEvent)
  proc mouse_moved(event: MotionEvent)
  proc key_pressed(event: KeyEvent): bool
  proc key_released(event: KeyEvent): bool
  
  hooks:
    before_build:
      state.internal_widget = gtk_drawing_area_new()
      
      var mask = gtk_widget_get_events(state.internal_widget)
      mask[GDK_BUTTON_PRESS_MASK] = not widget.mouse_pressed.is_nil
      mask[GDK_BUTTON_RELEASE_MASK] = not widget.mouse_released.is_nil
      mask[GDK_POINTER_MOTION_MASK] = not widget.mouse_moved.is_nil
      mask[GDK_KEY_PRESS_MASK] = not widget.key_pressed.is_nil
      mask[GDK_KEY_RELEASE_MASK] = not widget.key_released.is_nil
      gtk_widget_set_events(state.internal_widget, mask)
    connect_events:
      state.internal_widget.connect(state.draw, "draw", draw_event_callback)
      state.internal_widget.connect(state.mouse_pressed, "button-press-event", button_event_callback)
      state.internal_widget.connect(state.mouse_released, "button-release-event", button_event_callback)
      state.internal_widget.connect(state.mouse_moved, "motion-notify-event", motion_event_callback)
      state.internal_widget.connect(state.key_pressed, "key-press-event", key_event_callback)
      state.internal_widget.connect(state.key_released, "key-release-event", key_event_callback)
    disconnect_events:
      state.internal_widget.disconnect(state.draw)
      state.internal_widget.disconnect(state.mouse_pressed)
      state.internal_widget.disconnect(state.mouse_released)
      state.internal_widget.disconnect(state.mouse_moved)
      state.internal_widget.disconnect(state.key_pressed)
      state.internal_widget.disconnect(state.key_released)
    update:
      gtk_widget_queue_draw(state.internal_widget)
  
  hooks focusable:
    property:
      gtk_widget_set_can_focus(state.internal_widget, cbool(ord(state.focusable)))
]#

renderable ColorButton of BaseWidget:
  color: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0)
  use_alpha: bool = false
  
  proc changed(color: tuple[r, g, b, a: float])
  
  hooks:
    before_build:
      state.internal_widget = gtk_color_button_new()
    connect_events:
      state.internal_widget.connect(state.changed, "color-set", color_event_callback)
    disconnect_events:
      state.internal_widget.disconnect(state.changed)
  
  hooks color:
    property:
      var rgba = GdkRgba(
        r: cdouble(state.color.r),
        g: cdouble(state.color.g),
        b: cdouble(state.color.b),
        a: cdouble(state.color.a)
      )
      gtk_color_chooser_set_rgba(state.internal_widget, rgba.addr)
  
  hooks use_alpha:
    property:
      gtk_color_chooser_set_use_alpha(state.internal_widget, cbool(ord(state.use_alpha)))

renderable Switch of BaseWidget:
  state: bool
  
  proc changed(state: bool)
  
  hooks:
    before_build:
      state.internal_widget = gtk_switch_new()
    connect_events:
      state.internal_widget.connect(state.changed, "state-set", switch_event_callback)
    disconnect_events:
      state.internal_widget.disconnect(state.changed)
  
  hooks state:
    property:
      gtk_switch_set_state(state.internal_widget, cbool(ord(state.state)))

renderable ToggleButton of Button:
  state: bool
  
  proc changed(state: bool)
  
  hooks:
    before_build:
      state.internal_widget = gtk_toggle_button_new()
    connect_events:
      state.internal_widget.connect(state.changed, "toggled", toggle_button_event_callback)
    disconnect_events:
      state.internal_widget.disconnect(state.changed)
  
  hooks state:
    property:
      gtk_toggle_button_set_active(state.internal_widget, cbool(ord(state.state)))

renderable CheckButton of BaseWidget:
  state: bool
  
  proc changed(state: bool)
  
  hooks:
    before_build:
      state.internal_widget = gtk_check_button_new()
    connect_events:
      state.internal_widget.connect(state.changed, "toggled", check_button_event_callback)
    disconnect_events:
      state.internal_widget.disconnect(state.changed)
  
  hooks state:
    property:
      gtk_check_button_set_active(state.internal_widget, cbool(ord(state.state)))

renderable Popover of BaseWidget:
  child: Widget
  
  hooks:
    before_build:
      state.internal_widget = gtk_popover_new(nil)
  
  hooks child:
    build: build_bin(state, widget, gtk_popover_set_child)
    update: update_bin(state, widget, gtk_popover_set_child)

proc add*(popover: Popover, child: Widget) =
  if popover.has_child:
    raise new_exception(ValueError, "Unable to add multiple children to a Popover. Use a Box widget to display multiple widgets in a popover.")
  popover.has_child = true
  popover.val_child = child

renderable MenuButton of BaseWidget:
  child: Widget
  popover: Widget
  
  hooks:
    before_build:
      state.internal_widget = gtk_menu_button_new()
  
  hooks child:
    build: build_bin(state, widget, gtk_menu_button_set_child)
    update: update_bin(state, widget, gtk_menu_button_set_child)
  
  hooks popover:
    build:
      if widget.has_popover:
        widget.val_popover.assign_app(state.app)
        state.popover = widget.val_popover.build()
        let popover_widget = unwrap_renderable(state.popover).internal_widget
        gtk_menu_button_set_popover(state.internal_widget, popover_widget)
    update:
      if widget.has_popover:
        widget.val_popover.assign_app(state.app)
        let new_popover = widget.val_popover.update(state.popover)
        if not new_popover.is_nil:
          let popover_widget = new_popover.unwrap_internal_widget()
          gtk_menu_button_set_popover(state.internal_widget, popover_widget)
          state.popover = new_popover

proc add_child*(menu_button: MenuButton, child: Widget) =
  if menu_button.has_child:
    raise new_exception(ValueError, "Unable to add multiple children to a MenuButton. Use a Box widget to display multiple widgets in a MenuButton.")
  menu_button.has_child = true
  menu_button.val_child = child

proc `has_text=`*(menu_button: MenuButton, value: bool) = menu_button.has_child = value
proc `val_text=`*(menu_button: MenuButton, value: string) =
  menu_button.val_child = Label(has_text: true, val_text: value)

proc `has_icon=`*(menu_button: MenuButton, value: bool) = menu_button.has_child = value
proc `val_icon=`*(menu_button: MenuButton, name: string) =
  menu_button.val_child = Icon(has_name: true, val_name: name)

proc add*(button: MenuButton, child: Widget) =
  if not button.has_child:
    button.has_child = true
    button.val_child = child
  elif not button.has_popover:
    button.has_popover = true
    button.val_popover = child
  else:
    raise new_exception(ValueError, "Unable to add more than two children to MenuButton")

#[
renderable ModelButton of BaseWidget:
  text: string
  
  proc clicked()
  
  hooks:
    before_build:
      state.internal_widget = gtk_model_button_new()
    connect_events:
      state.internal_widget.connect(state.clicked, "clicked", event_callback)
    disconnect_events:
      state.internal_widget.disconnect(state.clicked)
  
  hooks text:
    property:
      var value = g_value_new(state.text)
      g_object_set_property(state.internal_widget.pointer, "text", value.addr)
      g_value_unset(value.addr)
]#

renderable Separator of BaseWidget:
  orient: Orient
  
  hooks:
    before_build:
      state.internal_widget = gtk_separator_new(widget.val_orient.to_gtk())

type
  TextBufferObj = object
    gtk: GtkTextBuffer
  
  TextBuffer* = ref TextBufferObj

proc finalizer(buffer: TextBuffer) =
  gobject_unref(pointer(buffer.gtk))

proc new_text_buffer*(): TextBuffer =
  new(result, finalizer=finalizer)
  result.gtk = gtk_text_buffer_new(nil)

proc count_lines*(buffer: TextBuffer): int =
  result = int(gtk_text_buffer_get_line_count(buffer.gtk))

proc `text=`*(buffer: TextBuffer, text: string) =
  gtk_text_buffer_set_text(buffer.gtk, text.cstring, text.len.cint)

renderable TextView of BaseWidget:
  buffer: TextBuffer
  monospace: bool
  
  proc changed()
  
  hooks:
    before_build:
      state.internal_widget = gtk_text_view_new()
    connect_events:
      GtkWidget(state.buffer.gtk).connect(state.changed, "changed", event_callback)
    disconnect_events:
      GtkWidget(state.buffer.gtk).disconnect(state.changed)
  
  hooks monospace:
    property:
      gtk_text_view_set_monospace(state.internal_widget, cbool(ord(state.monospace)))
  
  hooks buffer:
    property:
      if state.buffer.is_nil:
        raise new_exception(ValueError, "TextView.buffer must not be nil")
      gtk_text_view_set_buffer(state.internal_widget, state.buffer.gtk)

renderable ListBoxRow of BaseWidget:
  child: Widget
  
  proc activate()
  
  hooks:
    before_build:
      state.internal_widget = gtk_list_box_row_new()
    connect_events:
      state.internal_widget.connect(state.activate, "activate", event_callback)
    disconnect_events:
      state.internal_widget.disconnect(state.activate)
  
  hooks child:
    build: build_bin(state, widget, gtk_list_box_row_set_child)
    update: update_bin(state, widget, gtk_list_box_row_set_child)
  
  example:
    ListBox:
      for it in 0..<10:
        ListBoxRow {.add_row.}:
          proc activate() =
            echo it
          Label(text = $it)

proc add*(row: ListBoxRow, child: Widget) =
  if row.has_child:
    raise new_exception(ValueError, "Unable to add multiple children to a ListBoxRow. Use a Box widget to display multiple widgets in a ListBoxRow.")
  row.has_child = true
  row.val_child = child

type SelectionMode* = enum
  SelectionNone, SelectionSingle, SelectionBrowse, SelectionMultiple

renderable ListBox of BaseWidget:
  rows: seq[Widget]
  selection_mode: SelectionMode
  selected: HashSet[int]
  
  proc select(rows: HashSet[int])
  
  hooks:
    before_build:
      state.internal_widget = gtk_list_box_new()
    connect_events:
      state.internal_widget.connect(state.select, "selected-rows-changed", list_box_event_callback)
    disconnect_events:
      state.internal_widget.disconnect(state.select)
  
  hooks rows:
    build:
      for row in widget.val_rows:
        row.assign_app(widget.app)
        let row_state = row.build()
        state.rows.add(row_state)
        let row_widget = row_state.unwrap_internal_widget()
        gtk_list_box_append(state.internal_widget, row_widget)
    update:
      var it = 0
      while it < widget.val_rows.len and it < state.rows.len:
        widget.val_rows[it].assign_app(state.app)
        let new_row = widget.val_rows[it].update(state.rows[it])
        assert new_row.is_nil
        it += 1
      
      while it < widget.val_rows.len:
        widget.val_rows[it].assign_app(state.app)
        let
          row_state = widget.val_rows[it].build()
          row_widget = row_state.unwrap_internal_widget()
        state.rows.add(row_state)
        gtk_list_box_append(state.internal_widget, row_widget)
        it += 1
      
      while it < state.rows.len:
        let row = unwrap_renderable(state.rows.pop()).internal_widget
        gtk_list_box_remove(state.internal_widget, row)
  
  hooks selection_mode:
    property:
      gtk_list_box_set_selection_mode(state.internal_widget,
        GtkSelectionMode(ord(state.selection_mode))
      )
  
  hooks selected:
    (build, update):
      if widget.has_selected:
        for index in state.selected - widget.val_selected:
          if index >= state.rows.len:
            continue
          let row = state.rows[index].unwrap_internal_widget()
          gtk_list_box_unselect_row(state.internal_widget, row)
        for index in widget.val_selected - state.selected:
          let row = state.rows[index].unwrap_internal_widget()
          gtk_list_box_select_row(state.internal_widget, row)
        state.selected = widget.val_selected
        for row in state.selected:
          if row >= state.rows.len:
            raise new_exception(IndexDefect, "Unable to select row " & $row & ", since there are only " & $state.rows.len & " rows in the ListBox.")

proc add_row*(list_box: ListBox, row: ListBoxRow) =
  list_box.has_rows = true
  list_box.val_rows.add(row)

proc add*(list_box: ListBox, child: Widget) =
  if child of ListBoxRow:
    list_box.add_row(ListBoxRow(child))
  else:
    list_box.add_row(ListBoxRow(has_child: true, val_child: child))

renderable FlowBoxChild of BaseWidget:
  child: Widget
  
  hooks:
    before_build:
      state.internal_widget = gtk_flow_box_child_new()
  
  hooks child:
    build: build_bin(state, widget, gtk_flow_box_child_set_child)
    update: update_bin(state, widget, gtk_flow_box_child_set_child)
  
  example:
    FlowBox:
      columns = 1..5
      for it in 0..<10:
        FlowBoxChild {.add_child.}:
          Label(text = $it)

proc add*(flow_box_child: FlowBoxChild, child: Widget) =
  if flow_box_child.has_child:
    raise new_exception(ValueError, "Unable to add multiple children to a FlowBoxChild. Use a Box widget to display multiple widgets in a FlowBoxChild.")
  flow_box_child.has_child = true
  flow_box_child.val_child = child

renderable FlowBox of BaseWidget:
  homogeneous: bool
  row_spacing: int
  column_spacing: int
  columns: HSlice[int, int] = 1..5
  selection_mode: SelectionMode
  children: seq[Widget]
  
  hooks:
    before_build:
      state.internal_widget = gtk_flow_box_new()
  
  hooks homogeneous:
    property:
      gtk_flow_box_set_homogeneous(state.internal_widget, cbool(ord(state.homogeneous)))
  
  hooks row_spacing:
    property:
      gtk_flow_box_set_row_spacing(state.internal_widget, cuint(state.row_spacing))
  
  hooks column_spacing:
    property:
      gtk_flow_box_set_column_spacing(state.internal_widget, cuint(state.column_spacing))
  
  hooks columns:
    property:
      gtk_flow_box_set_min_children_per_line(state.internal_widget, cuint(state.columns.a))
      gtk_flow_box_set_max_children_per_line(state.internal_widget, cuint(state.columns.b))
  
  hooks selection_mode:
    property:
      gtk_flow_box_set_selection_mode(state.internal_widget,
        GtkSelectionMode(ord(state.selection_mode))
      )
  
  hooks children:
    (build, update):
      var it = 0
      while it < widget.val_children.len and
            it < state.children.len:
        let child_widget = widget.val_children[it]
        child_widget.assign_app(state.app)
        let new_child = child_widget.update(state.children[it])
        if not new_child.is_nil:
          gtk_flow_box_remove(
            state.internal_widget,
            unwrap_renderable(state.children[it]).internal_widget
          )
          gtk_flow_box_insert(
            state.internal_widget,
            unwrap_renderable(new_child).internal_widget,
            cint(it)
          )
          state.children[it] = new_child
        it += 1
      
      while it < widget.val_children.len:
        let child_widget = widget.val_children[it]
        child_widget.assign_app(state.app)
        let
          child = child_widget.build()
          child_internal = unwrap_renderable(child).internal_widget
        gtk_flow_box_append(state.internal_widget, child_internal)
        state.children.add(child)
        it += 1
      
      while it < state.children.len:
        let child = state.children.pop()
        gtk_flow_box_remove(
          state.internal_widget,
          unwrap_renderable(child).internal_widget
        )
  
  example:
    FlowBox:
      columns = 1..5
      for it in 0..<10:
        Label(text = $it)

proc add_child*(flow_box: FlowBox, child: FlowBoxChild) =
  flow_box.has_children = true
  flow_box.val_children.add(child)

proc add*(flow_box: FlowBox, child: Widget) =
  flow_box.add_child(FlowBoxChild(has_child: true, val_child: child))

renderable Frame of BaseWidget:
  label: string
  align: tuple[x, y: float] = (0.0, 0.0)
  child: Widget
  
  hooks:
    before_build:
      state.internal_widget = gtk_frame_new(nil)
  
  hooks label:
    property:
      if state.label.len == 0:
        gtk_frame_set_label(state.internal_widget, nil)
      else:
        gtk_frame_set_label(state.internal_widget, state.label.cstring)
  
  hooks align:
    property:
      gtk_frame_set_label_align(state.internal_widget,
        state.align.x.cfloat, state.align.y.cfloat
      )
  
  hooks child:
    build: build_bin(state, widget, gtk_frame_set_child)
    update: update_bin(state, widget, gtk_frame_set_child)

proc add*(frame: Frame, child: Widget) =
  if frame.has_child:
    raise new_exception(ValueError, "Unable to add multiple children to a Frame. Use a Box widget to display multiple widgets in a Frame.")
  frame.has_child = true
  frame.val_child = child 

type
  DialogResponseKind* = enum
    DialogCustom, DialogAccept, DialogCancel
  
  DialogResponse* = object
    case kind*: DialogResponseKind:
      of DialogCustom: id*: int
      else: discard

proc to_dialog_response*(id: cint): DialogResponse =
  case id:
    of -3: result = DialogResponse(kind: DialogAccept)
    of -6: result = DialogResponse(kind: DialogCancel)
    else: result = DialogResponse(kind: DialogCustom, id: int(id))

proc to_gtk(resp: DialogResponse): cint =
  case resp.kind:
    of DialogCustom: result = resp.id.cint
    of DialogAccept: result = -3
    of DialogCancel: result = -6

renderable DialogButton:
  text: string
  response: DialogResponse
  style: set[ButtonStyle]

proc `has_res=`*(button: DialogButton, value: bool) =
  button.has_response = value

proc `val_res=`*(button: DialogButton, kind: DialogResponseKind) =
  button.val_response = DialogResponse(kind: kind)

renderable Dialog of Window:
  buttons: seq[DialogButton]
  
  hooks:
    before_build:
      state.internal_widget = gtk_dialog_new_with_buttons("", nil, GTK_DIALOG_USE_HEADER_BAR, nil)
      gtk_window_set_child(state.internal_widget, nil)
  
  hooks buttons:
    build:
      for button in widget.val_buttons:
        let
          button_widget = gtk_dialog_add_button(state.internal_widget,
            button.val_text.cstring,
            button.val_response.to_gtk
          )
          ctx = gtk_widget_get_style_context(button_widget)
        for class in classes(button.val_style):
          gtk_style_context_add_class(ctx, class.cstring)

proc add_button*(dialog: Dialog, button: DialogButton) =
  dialog.has_buttons = true
  dialog.val_buttons.add(button)

renderable BuiltinDialog:
  title: string
  buttons: seq[DialogButton]
  
  hooks buttons:
    build:
      for button in widget.val_buttons:
        let
          button_widget = gtk_dialog_add_button(state.internal_widget,
            button.val_text.cstring,
            button.val_response.to_gtk
          )
          ctx = gtk_widget_get_style_context(button_widget)
        for class in classes(button.val_style):
          gtk_style_context_add_class(ctx, class.cstring)

proc add_button*(dialog: BuiltinDialog, button: DialogButton) =
  dialog.has_buttons = true
  dialog.val_buttons.add(button)

type FileChooserAction* = enum
  FileChooserOpen,
  FileChooserSave,
  FileChooserSelectFolder,
  FileChooserCreateFolder

renderable FileChooserDialog of BuiltinDialog:
  action: FileChooserAction
  filename: string
  
  hooks:
    before_build:
      state.internal_widget = gtk_file_chooser_dialog_new(
        widget.val_title.cstring,
        nil,
        GtkFileChooserAction(ord(widget.val_action))
      )
  
  hooks filename:
    read:
      let file = gtk_file_chooser_get_file(state.internal_widget)
      state.filename = $g_file_get_path(file)

renderable ColorChooserDialog of BuiltinDialog:
  color: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0)
  use_alpha: bool = false
  
  hooks:
    before_build:
      state.internal_widget = gtk_color_chooser_dialog_new(
        widget.val_title.cstring,
        nil
      )
  
  hooks color:
    property:
      var rgba = GdkRgba(
        r: cdouble(state.color.r),
        g: cdouble(state.color.g),
        b: cdouble(state.color.b),
        a: cdouble(state.color.a)
      )
      gtk_color_chooser_set_rgba(state.internal_widget, rgba.addr)
    read:
      var color: GdkRgba
      gtk_color_chooser_get_rgba(state.internal_widget, color.addr)
      state.color = (color.r.float, color.g.float, color.b.float, color.a.float)
  
  hooks use_alpha:
    property:
      gtk_color_chooser_set_use_alpha(state.internal_widget, cbool(ord(state.use_alpha)))

renderable MessageDialog of BuiltinDialog:
  message: string
  
  hooks:
    before_build:
      state.internal_widget = gtk_message_dialog_new(
        nil,
        GTK_DIALOG_DESTROY_WITH_PARENT,
        GTK_MESSAGE_INFO,
        GTK_BUTTONS_NONE,
        widget.val_message.cstring
      )

renderable AboutDialog of BuiltinDialog:
  program_name: string
  logo: string
  copyright: string
  version: string
  license: string
  credits: seq[(string, seq[string])]
  
  hooks:
    before_build:
      state.internal_widget = gtk_about_dialog_new()
  
  hooks program_name:
    property:
      gtk_about_dialog_set_program_name(state.internal_widget, state.program_name.cstring)
  
  hooks logo:
    property:
      gtk_about_dialog_set_logo_icon_name(state.internal_widget, state.logo.cstring)
  
  hooks copyright:
    property:
      gtk_about_dialog_set_copyright(state.internal_widget, state.copyright.cstring)
  
  hooks version:
    property:
      gtk_about_dialog_set_version(state.internal_widget, state.version.cstring)
  
  hooks license:
    property:
      gtk_about_dialog_set_license(state.internal_widget, state.license.cstring)
  
  hooks credits:
    build:
      if widget.has_credits:
        state.credits = widget.val_credits
        for (section_name, people) in state.credits:
          let names = alloc_cstring_array(people)
          defer: dealloc_cstring_array(names)
          gtk_about_dialog_add_credit_section(state.internal_widget, section_name.cstring, names)

export BaseWidget
export Window, Box, Label, Icon, Button, HeaderBar, ScrolledWindow, Entry
export Paned, ColorButton, Switch, ToggleButton, CheckButton
export MenuButton, Separator, Popover, TextView
export ListBox, ListBoxRow, FlowBox, FlowBoxChild, Frame
export Dialog, DialogState, DialogButton
export BuiltinDialog, BuiltinDialogState
export FileChooserDialog, FileChooserDialogState
export ColorChooserDialog, ColorChooserDialogState
export MessageDialog, MessageDialogState
export AboutDialog, AboutDialogState
export build_state, update_state, assign_app_events
