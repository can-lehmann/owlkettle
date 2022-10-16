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

import std/[unicode, sets, tables]
import gtk, widgetdef, cairo

when defined(owlkettleDocs):
  echo "# Widgets\n\n"

proc eventCallback(widget: GtkWidget, data: ptr EventObj[proc ()]) =
  data[].callback()
  if data[].app.isNil:
    raise newException(ValueError, "App is nil")
  data[].app.redraw()

proc entryEventCallback(widget: GtkWidget, data: ptr EventObj[proc (text: string)]) =
  data[].callback($gtk_editable_get_text(widget))
  if data[].app.isNil:
    raise newException(ValueError, "App is nil")
  data[].app.redraw()

proc switchEventCallback(widget: GtkWidget, state: cbool, data: ptr EventObj[proc (state: bool)]) =
  data[].callback(state != 0)
  if data[].app.isNil:
    raise newException(ValueError, "App is nil")
  data[].app.redraw()

proc toggleButtonEventCallback(widget: GtkWidget, data: ptr EventObj[proc (state: bool)]) =
  data[].callback(gtk_toggle_button_get_active(widget) != 0)
  if data[].app.isNil:
    raise newException(ValueError, "App is nil")
  data[].app.redraw()

proc checkButtonEventCallback(widget: GtkWidget, data: ptr EventObj[proc (state: bool)]) =
  data[].callback(gtk_check_button_get_active(widget) != 0)
  if data[].app.isNil:
    raise newException(ValueError, "App is nil")
  data[].app.redraw()

proc colorEventCallback(widget: GtkWidget, data: ptr EventObj[proc (color: tuple[r, g, b, a: float])]) =
  var color: GdkRgba
  gtk_color_chooser_get_rgba(widget, color.addr)
  data[].callback((color.r.float, color.g.float, color.b.float, color.a.float))
  if data[].app.isNil:
    raise newException(ValueError, "App is nil")
  data[].app.redraw()

proc listBoxEventCallback(widget: GtkWidget, data: ptr EventObj[proc (state: HashSet[int])]) =
  let selected = gtk_list_box_get_selected_rows(widget)
  var
    rows = initHashSet[int]()
    cur = selected
  while not cur.isNil:
    rows.incl(int(gtk_list_box_row_get_index(GtkWidget(cur[].data))))
    cur = cur[].next
  g_list_free(selected)
  data[].callback(rows)
  if data[].app.isNil:
    raise newException(ValueError, "App is nil")
  data[].app.redraw()


proc connect[T](widget: GtkWidget,
                event: Event[T],
                name: cstring,
                eventCallback: pointer) =
  if not event.isNil:
    event.handler = g_signal_connect(widget, name, eventCallback, event[].addr)

proc disconnect[T](widget: GtkWidget, event: Event[T]) =
  if not event.isNil:
    assert event.handler > 0
    g_signal_handler_disconnect(widget, event.handler)

proc updateStyle[State, Widget](state: State, widget: Widget) =
  mixin classes
  if widget.hasStyle:
    let ctx = gtk_widget_get_style_context(state.internalWidget)
    for styleClass in state.style - widget.valStyle:
      gtk_style_context_remove_class(ctx, cstring($styleClass))
    for styleClass in widget.valStyle - state.style:
      gtk_style_context_add_class(ctx, cstring($styleClass))
    state.style = widget.valStyle

type Margin* = object
  top*, bottom*, left*, right*: int

renderable BaseWidget:
  sensitive: bool = true
  sizeRequest: tuple[x, y: int] = (-1, -1)
  internalMargin {.internal.}: Margin = Margin()
  tooltip: string = ""
  
  hooks sensitive:
    property:
      gtk_widget_set_sensitive(state.internalWidget, cbool(ord(state.sensitive)))
  
  hooks sizeRequest:
    property:
      gtk_widget_set_size_request(state.internalWidget,
        cint(state.sizeRequest.x),
        cint(state.sizeRequest.y)
      )

  hooks internalMargin:
    (build, update):
      if widget.hasInternalMargin:
        state.internalMargin = widget.valInternalMargin
        gtk_widget_set_margin_top(state.internalWidget, cint(state.internalMargin.top))
        gtk_widget_set_margin_bottom(state.internalWidget, cint(state.internalMargin.bottom))
        gtk_widget_set_margin_start(state.internalWidget, cint(state.internalMargin.left))
        gtk_widget_set_margin_end(state.internalWidget, cint(state.internalMargin.right))
  
  hooks tooltip:
    property:
      if state.tooltip.len > 0:
        gtk_widget_set_tooltip_text(state.internalWidget, state.tooltip.cstring)
      else:
        gtk_widget_set_has_tooltip(state.internalWidget, cbool(0))
  
  setter margin: int
  setter margin: Margin

proc `hasMargin=`*(widget: BaseWidget, has: bool) =
  widget.hasInternalMargin = has

proc `valMargin=`*(widget: BaseWidget, width: int) =
  widget.valInternalMargin = Margin(top: width, bottom: width, left: width, right: width)

proc `valMargin=`*(widget: BaseWidget, margin: Margin) =
  widget.valInternalMargin = margin

template buildBin*(state, widget, child, hasChild, valChild, setChild: untyped) =
  if widget.hasChild:
    widget.valChild.assignApp(state.app)
    state.child = widget.valChild.build()
    let childWidget = unwrapInternalWidget(state.child)
    setChild(state.internalWidget, childWidget)

template buildBin*(state, widget, setChild: untyped) =
  buildBin(state, widget, child, hasChild, valChild, setChild)

template updateBin*(state, widget, child, hasChild, valChild, setChild: untyped) =
  if widget.hasChild:
    widget.valChild.assignApp(state.app)
    let newChild = widget.valChild.update(state.child)
    if not newChild.isNil:
      let childWidget = newChild.unwrapInternalWidget()
      setChild(state.internalWidget, childWidget)
      state.child = newChild

template updateBin*(state, widget, setChild: untyped) =
  updateBin(state, widget, child, hasChild, valChild, setChild)

renderable Window of BaseWidget:
  title: string
  titlebar: Widget
  defaultSize: tuple[width, height: int] = (800, 600)
  child: Widget
  
  proc close()
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_window_new(GTK_WINDOW_TOPLEVEL)
    connectEvents:
      state.internalWidget.connect(state.close, "destroy", eventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.close)
  
  hooks title:
    property:
      if state.titlebar.isNil:
        gtk_window_set_title(state.internalWidget, state.title.cstring)
  
  hooks titlebar:
    build: buildBin(state, widget, titlebar, hasTitlebar, valTitlebar, gtk_window_set_titlebar)
    update: updateBin(state, widget, titlebar, hasTitlebar, valTitlebar, gtk_window_set_titlebar)
  
  hooks defaultSize:
    property:
      gtk_window_set_default_size(state.internalWidget,
        state.defaultSize.width.cint,
        state.defaultSize.height.cint
      )
  
  hooks child:
    build: buildBin(state, widget, gtk_window_set_child)
    update: updateBin(state, widget, gtk_window_set_child)
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a Window. Use a Box widget to display multiple widgets in a Window.")
    widget.hasChild = true
    widget.valChild = child
  
  adder addTitlebar:
    widget.hasTitlebar = true
    widget.valTitlebar = child
  
  example:
    Window:
      Label(text = "Hello, world")

type Orient* = enum OrientX, OrientY

proc toGtk(orient: Orient): GtkOrientation =
  result = [GTK_ORIENTATION_HORIZONTAL, GTK_ORIENTATION_VERTICAL][ord(orient)]

type BoxStyle* = enum
  BoxLinked = "linked",
  BoxCard = "card"

type
  Align* = enum
    AlignFill, AlignStart, AlignEnd, AlignCenter
  
  BoxChild[T] = object
    widget: T
    expand: bool
    hAlign: Align
    vAlign: Align

proc toGtk(align: Align): GtkAlign = GtkAlign(ord(align))

proc assignApp[T](child: BoxChild[T], app: Viewable) =
  child.widget.assignApp(app)

renderable Box of BaseWidget:
  orient: Orient
  spacing: int
  children: seq[BoxChild[Widget]]
  style: set[BoxStyle]
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_box_new(
        toGtk(widget.valOrient),
        widget.valSpacing.cint
      )
  
  hooks spacing:
    property:
      gtk_box_set_spacing(state.internalWidget, state.spacing.cint)

  hooks children:
    (build, update):
      if widget.hasChildren:
        widget.valChildren.assignApp(state.app)
        var it = 0
        while it < widget.valChildren.len and it < state.children.len:
          let
            child = widget.valChildren[it]
            newChild = child.widget.update(state.children[it].widget)
          if not newChild.isNil:
            gtk_box_remove(
              state.internalWidget,
              state.children[it].widget.unwrapInternalWidget()
            )
            var sibling: GtkWidget = nil
            if it > 0:
              sibling = state.children[it - 1].widget.unwrapInternalWidget()
            let newWidget = newChild.unwrapInternalWidget()
            gtk_box_insert_child_after(state.internalWidget, newWidget, sibling)
            state.children[it].widget = newChild
          
          let childWidget = state.children[it].widget.unwrapInternalWidget()
          
          if child.expand != state.children[it].expand:
            case state.orient:
              of OrientX: gtk_widget_set_hexpand(childWidget, child.expand.ord.cbool)
              of OrientY: gtk_widget_set_vexpand(childWidget, child.expand.ord.cbool)
            state.children[it].expand = child.expand
          
          if child.hAlign != state.children[it].hAlign:
            state.children[it].hAlign = child.hAlign
            gtk_widget_set_halign(childWidget, toGtk(child.hAlign))
          
          if child.vAlign != state.children[it].vAlign:
            state.children[it].vAlign = child.vAlign
            gtk_widget_set_valign(childWidget, toGtk(child.vAlign))
          
          it += 1
        
        while it < widget.valChildren.len:
          let
            child = widget.valChildren[it]
            childState = child.widget.build()
            childWidget = childState.unwrapInternalWidget()
          case state.orient:
            of OrientX: gtk_widget_set_hexpand(childWidget, child.expand.ord.cbool)
            of OrientY: gtk_widget_set_vexpand(childWidget, child.expand.ord.cbool)
          gtk_widget_set_halign(childWidget, toGtk(child.hAlign))
          gtk_widget_set_valign(childWidget, toGtk(child.vAlign))
          gtk_box_append(state.internalWidget, childWidget)
          state.children.add(BoxChild[WidgetState](
            widget: childState,
            expand: child.expand,
            hAlign: child.hAlign,
            vAlign: child.vAlign
          ))
          it += 1
        while it < state.children.len:
          gtk_box_remove(
            state.internalWidget,
            state.children[^1].widget.unwrapInternalWidget()
          )
          discard state.children.pop()
  
  hooks style:
    (build, update):
      updateStyle(state, widget)
  
  adder add {.expand: true,
              hAlign: AlignFill,
              vAlign: AlignFill.}:
    widget.hasChildren = true
    widget.valChildren.add(BoxChild[Widget](
      widget: child,
      expand: expand,
      hAlign: hAlign,
      vAlign: vAlign
    ))
  
  example:
    Box:
      orient = OrientX
      Label(text = "Label")
      Button(text = "Button") {.expand: false.}
  
  example:
    Box:
      orient = OrientY
      margin = 12
      spacing = 6
      
      for it in 0..<5:
        Label(text = "Label " & $it)
  
  example:
    HeaderBar {.addTitlebar.}:
      Box {.addLeft.}:
        style = {BoxLinked}
        
        for it in 0..<5:
          Button {.expand: false.}:
            text = "Button " & $it
            proc clicked() =
              echo it

type OverlayChild[T] = object
  widget: T
  hAlign: Align
  vAlign: Align

proc assignApp[T](child: OverlayChild[T], app: Viewable) =
  child.widget.assignApp(app)

renderable Overlay of BaseWidget:
  child: Widget
  overlays: seq[OverlayChild[Widget]]
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_overlay_new()
  
  hooks child:
    build: buildBin(state, widget, gtk_overlay_set_child)
    update: updateBin(state, widget, gtk_overlay_set_child)
  
  hooks overlays:
    (build, update):
      widget.valOverlays.assignApp(state.app)
      
      var it = 0
      
      while it < widget.valOverlays.len and it < state.overlays.len:
        let
          child = widget.valOverlays[it]
          newChild = child.widget.update(state.overlays[it].widget)
        assert newChild.isNil
        
        let childWidget = state.overlays[it].widget.unwrapInternalWidget()
        if child.hAlign != state.overlays[it].hAlign:
          state.overlays[it].hAlign = child.hAlign
          gtk_widget_set_halign(childWidget, toGtk(child.hAlign))
        
        if child.vAlign != state.overlays[it].vAlign:
          state.overlays[it].vAlign = child.vAlign
          gtk_widget_set_valign(childWidget, toGtk(child.vAlign))
        
        it += 1
      
      while it < widget.valOverlays.len:
        let
          child = widget.valOverlays[it]
          childState = child.widget.build()
          childWidget = unwrapInternalWidget(childState)
        gtk_widget_set_halign(childWidget, toGtk(child.hAlign))
        gtk_widget_set_valign(childWidget, toGtk(child.vAlign))
        gtk_overlay_add_overlay(state.internalWidget, childWidget)
        state.overlays.add(OverlayChild[WidgetState](
          widget: childState,
          hAlign: child.hAlign,
          vAlign: child.vAlign
        ))
        it += 1
      
      while it < state.overlays.len:
        gtk_overlay_remove_overlay(
          state.internalWidget,
          state.overlays[^1].widget.unwrapInternalWidget()
        )
        discard state.overlays.pop()
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a Overlay. You can add overlays using the addOverlay adder.")
    widget.hasChild = true
    widget.valChild = child
  
  adder addOverlay {.hAlign: AlignFill,
                     vAlign: AlignFill.}:
    widget.hasOverlays = true
    widget.valOverlays.add(OverlayChild[Widget](
      widget: child,
      hAlign: hAlign,
      vAlign: vAlign
    ))

type LabelStyle* = enum
  LabelHeading = "heading",
  LabelBody = "body",
  LabelMonospace = "monospace"

type EllipsizeMode* = enum
  EllipsizeNone, EllipsizeStart, EllipsizeMiddle, EllipsizeEnd

renderable Label of BaseWidget:
  text: string
  xAlign: float = 0.5
  yAlign: float = 0.5
  ellipsize: EllipsizeMode
  wrap: bool = false
  useMarkup: bool = false
  
  style: set[LabelStyle]
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_label_new("")
  
  hooks style:
    (build, update):
      updateStyle(state, widget)
  
  hooks text:
    property:
      if state.useMarkup:
        gtk_label_set_markup(state.internalWidget, state.text.cstring)
      else:
        gtk_label_set_text(state.internalWidget, state.text.cstring)
  
  hooks xAlign:
    property:
      gtk_label_set_xalign(state.internalWidget, state.xAlign.cdouble)
  
  hooks yAlign:
    property:
      gtk_label_set_yalign(state.internalWidget, state.yAlign.cdouble)
  
  hooks ellipsize:
    property:
      gtk_label_set_ellipsize(state.internalWidget, PangoEllipsizeMode(ord(state.ellipsize)))
  
  hooks wrap:
    property:
      gtk_label_set_wrap(state.internalWidget, cbool(ord(state.wrap)))
  
  hooks useMarkup:
    property:
      gtk_label_set_use_markup(state.internalWidget, cbool(ord(state.useMarkup)))
  
  example:
    Label:
      text = "Hello, world!"
      xAlign = 0.0
      ellipsize = EllipsizeEnd
  
  example:
    Label:
      text = "Test ".repeat(50)
      wrap = true
  
  example:
    Label:
      text = "<b>Bold</b>, <i>Italic</i>, <span font=\"20\">Font Size</span>"
      useMarkup = true

renderable Icon of BaseWidget:
  name: string
  pixelSize: int = -1
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_image_new()
  
  hooks name:
    property:
      gtk_image_set_from_icon_name(state.internalWidget, state.name.cstring, GTK_ICON_SIZE_BUTTON)
  
  hooks pixelSize:
    property:
      gtk_image_set_pixel_size(state.internalWidget, state.pixelSize.cint)
  
  example:
    Icon:
      name = "list-add-symbolic"
  
  example:
    Icon:
      name = "object-select-symbolic"
      pixelSize = 100

type ButtonStyle* = enum
  ButtonSuggested = "suggested-action",
  ButtonDestructive = "destructive-action",
  ButtonFlat = "flat",
  ButtonPill = "pill",
  ButtonCircular = "circular"

renderable Button of BaseWidget:
  style: set[ButtonStyle]
  child: Widget
  shortcut: string
  
  proc clicked()
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_button_new()
    connectEvents:
      state.internalWidget.connect(state.clicked, "clicked", eventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.clicked)
  
  hooks shortcut:
    build:
      if widget.hasShortcut:
        state.shortcut = widget.valShortcut
      if state.shortcut.len > 0: 
        let
          trigger = gtk_shortcut_trigger_parse_string(state.shortcut.cstring)
          action = gtk_shortcut_action_parse_string("signal(clicked)")
          shortcut = gtk_shortcut_new(trigger, action)
          controller = gtk_shortcut_controller_new()
        gtk_shortcut_controller_set_scope(controller, GTK_SHORTCUT_SCOPE_MANAGED)
        gtk_shortcut_controller_add_shortcut(controller, shortcut)
        gtk_widget_add_controller(state.internalWidget, controller)
    update:
      if widget.hasShortcut:
        assert state.shortcut == widget.valShortcut # TODO
  
  hooks style:
    (build, update):
      updateStyle(state, widget)
  
  hooks child:
    build: buildBin(state, widget, gtk_button_set_child)
    update: updateBin(state, widget, gtk_button_set_child)
  
  setter text: string
  setter icon: string
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a Button. Use a Box widget to display multiple widgets in a Button.")
    widget.hasChild = true
    widget.valChild = child
  
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


proc `hasText=`*(button: Button, value: bool) = button.hasChild = value
proc `valText=`*(button: Button, value: string) =
  button.valChild = Label(hasText: true, valText: value)

proc `hasIcon=`*(button: Button, value: bool) = button.hasChild = value
proc `valIcon=`*(button: Button, name: string) =
  button.valChild = Icon(hasName: true, valName: name)


proc updateHeaderBar(internalWidget: GtkWidget,
                     children: var seq[WidgetState],
                     target: seq[Widget],
                     pack: proc(widget, child: GtkWidget) {.cdecl, locks: 0.}) =
  var it = 0
  while it < target.len and it < children.len:
    let newChild = target[it].update(children[it])
    assert newChild.isNil
    it += 1
  while it < target.len:
    let
      child = target[it].build()
      childWidget = child.unwrapInternalWidget()
    pack(internalWidget, childWidget)
    children.add(child)
    it += 1
  while it < children.len:
    gtk_header_bar_remove(internalWidget, children[it].unwrapInternalWidget())
    children.del(it)

renderable HeaderBar of BaseWidget:
  title: Widget
  showTitleButtons: bool = true
  left: seq[Widget]
  right: seq[Widget]
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_header_bar_new()
  
  hooks showTitleButtons:
    property:
      gtk_header_bar_set_show_title_buttons(state.internalWidget, cbool(ord(state.showTitleButtons)))
  
  hooks left:
    (build, update):
      if widget.hasLeft:
        widget.valLeft.assignApp(state.app)
        updateHeaderBar(
          state.internalWidget,
          state.left, widget.valLeft,
          gtk_header_bar_pack_start
        )
  
  hooks right:
    (build, update):
      if widget.hasRight:
        widget.valRight.assignApp(state.app)
        updateHeaderBar(
          state.internalWidget,
          state.right, widget.valRight,
          gtk_header_bar_pack_end
        )
  
  hooks title:
    build: buildBin(state, widget, title, hasTitle, valTitle, gtk_header_bar_set_title_widget)
    update: updateBin(state, widget, title, hasTitle, valTitle, gtk_header_bar_set_title_widget)
  
  adder addTitle:
    if widget.hasTitle:
      raise newException(ValueError, "Unable to add multiple title widgets to a HeaderBar.")
    widget.hasTitle = true
    widget.valTitle = child
  
  adder addLeft:
    widget.hasLeft = true
    widget.valLeft.add(child)
  
  adder addRight:
    widget.hasRight = true
    widget.valRight.add(child)
  
  
  example:
    Window:
      title = "Title"
      
      HeaderBar {.addTitlebar.}:
        Button {.addLeft.}:
          icon = "list-add-symbolic"
        
        Button {.addRight.}:
          icon = "open-menu-symbolic"

renderable ScrolledWindow of BaseWidget:
  child: Widget
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_scrolled_window_new(nil, nil)
  
  hooks child:
    build: buildBin(state, widget, gtk_scrolled_window_set_child)
    update: updateBin(state, widget, gtk_scrolled_window_set_child)
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a ScrolledWindow. Use a Box widget to display multiple widgets in a ScrolledWindow.")
    widget.hasChild = true
    widget.valChild = child

type EntryStyle* = enum
  EntrySuccess = "success",
  EntryWarning = "warning",
  EntryError = "error"

renderable Entry of BaseWidget:
  text: string
  placeholder: string
  width: int = -1
  maxWidth: int = -1
  xAlign: float = 0.0
  visibility: bool = true
  invisibleChar: Rune = '*'.Rune
  
  style: set[EntryStyle]
  
  proc changed(text: string)
  proc activate()

  hooks:
    beforeBuild:
      state.internalWidget = gtk_entry_new()
    connectEvents:
      state.internalWidget.connect(state.changed, "changed", entryEventCallback)
      state.internalWidget.connect(state.activate, "activate", eventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.changed)
      state.internalWidget.disconnect(state.activate)

  hooks style:
    (build, update):
      updateStyle(state, widget)

  hooks text:
    property:
      gtk_editable_set_text(state.internalWidget, state.text.cstring)
    read:
      state.text = $gtk_editable_get_text(state.internalWidget)
  
  hooks placeholder:
    property:
      gtk_entry_set_placeholder_text(state.internalWidget, state.placeholder.cstring)
  
  hooks width:
    property:
      gtk_editable_set_width_chars(state.internalWidget, state.width.cint)
  
  hooks maxWidth:
    property:
      gtk_editable_set_max_width_chars(state.internalWidget, state.maxWidth.cint)
  
  hooks xAlign:
    property:
      gtk_entry_set_alignment(state.internalWidget, state.xAlign.cfloat)

  hooks visibility:
    property:
      gtk_entry_set_visibility(state.internalWidget, cbool(ord(state.visibility)))

  hooks invisibleChar:
    property:
      gtk_entry_set_invisible_char(state.internalWidget, state.invisibleChar.uint32)

  
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
      invisibleChar = '*'.Rune

type PanedChild[T] = object
  widget: T
  resize: bool
  shrink: bool

proc buildPanedChild(child: PanedChild[Widget],
                     app: Viewable,
                     internalWidget: GtkWidget,
                     setChild: proc(paned, child: GtkWidget) {.cdecl, locks: 0.},
                     setResize: proc(paned: GtkWidget, val: cbool) {.cdecl, locks: 0.},
                     setShrink: proc(paned: GtkWidget, val: cbool) {.cdecl, locks: 0.}): PanedChild[WidgetState] =
  child.widget.assignApp(app)
  result = PanedChild[WidgetState](
    widget: child.widget.build(),
    resize: child.resize,
    shrink: child.shrink
  )
  setChild(internalWidget, result.widget.unwrapInternalWidget())
  setResize(internalWidget, cbool(ord(child.resize)))
  setShrink(internalWidget, cbool(ord(child.shrink)))

proc updatePanedChild(state: var PanedChild[WidgetState],
                      target: PanedChild[Widget],
                      app: Viewable) =
  target.widget.assignApp(app)
  assert target.resize == state.resize
  assert target.shrink == state.shrink
  let newChild = target.widget.update(state.widget)
  assert newChild.isNil


renderable Paned of BaseWidget:
  orient: Orient
  initialPosition: int
  first: PanedChild[Widget]
  second: PanedChild[Widget]
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_paned_new(toGtk(widget.valOrient))
      state.orient = widget.valOrient
  
  hooks first:
    build:
      if widget.hasFirst:
        state.first = widget.valFirst.buildPanedChild(
          state.app, state.internalWidget,
          gtk_paned_set_start_child,
          gtk_paned_set_resize_start_child,
          gtk_paned_set_shrink_start_child
        )
    update:
      if widget.hasFirst:
        state.first.updatePanedChild(widget.valFirst, state.app)

  hooks initialPosition:
    build:
      if widget.hasInitialPosition:
        state.initialPosition = widget.valInitialPosition
        gtk_paned_set_position(state.internalWidget, cint(state.initialPosition))
  
  hooks second:
    build:
      if widget.hasSecond:
        state.second = widget.valSecond.buildPanedChild(
          state.app, state.internalWidget,
          gtk_paned_set_end_child,
          gtk_paned_set_resize_end_child,
          gtk_paned_set_shrink_end_child
        )
    update:
      if widget.hasSecond:
        state.second.updatePanedChild(widget.valSecond, state.app)
  
  adder add {.resize: true, shrink: false.}:
    let panedChild = PanedChild[Widget](
      widget: child,
      resize: resize,
      shrink: shrink
    )
    if widget.hasFirst:
      widget.hasSecond = true
      widget.valSecond = panedChild
    else:
      widget.hasFirst = true
      widget.valFirst = panedChild
  
  example:
    Paned:
      initialPosition = 200
      Box(orient = OrientY) {.resize: false.}:
        Label(text = "Sidebar")
      Box(orient = OrientY) {.resize: true.}:
        Label(text = "Content")

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
  
  ScrollDirection* = enum
    ScrollUp, ScrollDown, ScrollLeft, ScrollRight, ScrollSmooth
  
  ScrollEvent* = object
    time*: uint32
    modifiers*: set[ModifierKey]
    case direction*: ScrollDirection:
      of ScrollSmooth: dx*, dy*: float
      else: discard

proc toScrollDirection(dir: GdkScrollDirection): ScrollDirection =
  result = ScrollDirection(ord(dir))

proc initModifierSet(state: GdkModifierType): set[ModifierKey] =
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

type
  CustomWidgetEventsObj = object
    mousePressed: proc(event: ButtonEvent): bool
    mouseReleased: proc(event: ButtonEvent): bool
    mouseMoved: proc(event: MotionEvent): bool
    scroll: proc(event: ScrollEvent): bool
    keyPressed: proc(event: KeyEvent): bool
    keyReleased: proc(event: KeyEvent): bool
    app: Viewable
  
  CustomWidgetEvents = ref CustomWidgetEventsObj

proc gdkEventCallback(controller: GtkEventController, event: GdkEvent, data: ptr CustomWidgetEventsObj): cbool =
  let
    modifiers = initModifierSet(gdk_event_get_modifier_state(event))
    time = gdk_event_get_time(event)
    pos = block:
      var nativePos = (x: cdouble(0.0), y: cdouble(0.0))
      discard gdk_event_get_position(event, nativePos.x.addr, nativePos.y.addr)
      
      let
        widget = gtk_event_controller_get_widget(controller)
        root = gtk_widget_get_root(widget)
        native = gtk_widget_get_native(root)
      
      var nativeOffset = (x: cdouble(0.0), y: cdouble(0.0))
      gtk_native_get_surface_transform(native, nativeOffset.x.addr, nativeOffset.y.addr)
      
      var localPos = (x: cdouble(0.0), y: cdouble(0.0))
      discard gtk_widget_translate_coordinates(
        root, widget,
        nativePos.x - nativeOffset.x, nativePos.y - nativeOffset.y,
        localPos.x.addr, localPos.y.addr
      )
      localPos
  
  var stopEvent = false
  
  let kind = gdk_event_get_event_type(event)
  case kind:
    of GDK_MOTION_NOTIFY:
      if not data[].mouseMoved.isNil:
        stopEvent = data[].mouseMoved(MotionEvent(
          time: time,
          x: float(pos.x),
          y: float(pos.y),
          modifiers: modifiers
        ))
    of GDK_BUTTON_PRESS, GDK_BUTTON_RELEASE:
      let evt = ButtonEvent(
        time: time,
        button: int(gdk_button_event_get_button(event)) - 1,
        x: float(pos.x),
        y: float(pos.y),
        modifiers: modifiers
      )
      if kind == GDK_BUTTON_PRESS:
        if not data[].mousePressed.isNil:
          stopEvent = data[].mousePressed(evt)
      else:
        if not data[].mouseReleased.isNil:
          stopEvent = data[].mouseReleased(evt)
    of GDK_KEY_PRESS, GDK_KEY_RELEASE:
      let
        keyVal = gdk_key_event_get_keyval(event)
        evt = KeyEvent(
          time: time,
          rune: Rune(gdk_keyval_to_unicode(keyVal)),
          value: keyVal.int,
          modifiers: modifiers
        )
      if kind == GDK_KEY_PRESS:
        if not data[].keyPressed.isNil:
          stopEvent = data[].keyPressed(evt)
      else:
        if not data[].keyReleased.isNil:
          stopEvent = data[].keyReleased(evt)
    of GDK_SCROLL:
      if not data[].scroll.isNil:
        var evt = ScrollEvent(
          time: time,
          direction: toScrollDirection(gdk_scroll_event_get_direction(event)),
          modifiers: modifiers
        )
        if evt.direction == ScrollSmooth:
          var
            dx: cdouble
            dy: cdouble
          gdk_scroll_event_get_deltas(event, dx.addr, dy.addr)
          evt.dx = float(dx)
          evt.dy = float(dy)
        stopEvent = data[].scroll(evt)
    else: discard
  
  if data[].app.isNil:
    raise newException(ValueError, "App is nil")
  data[].app.redraw()
  result = cbool(ord(stopEvent))

proc drawFunc(widget: GtkWidget,
              ctx: pointer,
              width, height: cint,
              data: pointer) {.cdecl.} =
  let
    event = cast[ptr EventObj[proc (ctx: CairoContext, size: (int, int)): bool]](data)
    requiresRedraw = event[].callback(CairoContext(ctx), (int(width), int(height)))
  if requiresRedraw:
    if event[].app.isNil:
      raise newException(ValueError, "App is nil")
    event[].app.redraw()

proc callbackOrNil[T](event: Event[T]): T =
  if event.isNil:
    result = nil
  else:
    result = event.callback

renderable CustomWidget of BaseWidget:
  focusable: bool
  events: CustomWidgetEvents
  
  proc mousePressed(event: ButtonEvent): bool
  proc mouseReleased(event: ButtonEvent): bool
  proc mouseMoved(event: MotionEvent): bool
  proc scroll(event: ScrollEvent): bool
  proc keyPressed(event: KeyEvent): bool
  proc keyReleased(event: KeyEvent): bool
  
  hooks:
    build:
      state.events = CustomWidgetEvents()
      let controller = gtk_event_controller_legacy_new()
      discard g_signal_connect(controller, "event", gdkEventCallback, state.events[].addr)
      gtk_widget_add_controller(state.internalWidget, controller)
    connectEvents:
      state.events.app = state.app
      state.events.mousePressed = state.mousePressed.callbackOrNil
      state.events.mouseReleased = state.mouseReleased.callbackOrNil
      state.events.mouseMoved = state.mouseMoved.callbackOrNil
      state.events.scroll = state.scroll.callbackOrNil
      state.events.keyPressed = state.keyPressed.callbackOrNil
      state.events.keyReleased = state.keyReleased.callbackOrNil
  
  hooks focusable:
    property:
      gtk_widget_set_can_focus(state.internalWidget, cbool(ord(state.focusable)))

renderable DrawingArea of CustomWidget:
  proc draw(ctx: CairoContext, size: (int, int)): bool
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_drawing_area_new()
    connectEvents:
      gtk_drawing_area_set_draw_func(state.internalWidget, draw_func, state.draw[].addr, nil)
    update:
      gtk_widget_queue_draw(state.internalWidget)

proc setupEventCallback(widget: GtkWidget, data: ptr EventObj[proc (size: (int, int)): bool]) =
  gtk_gl_area_make_current(widget)
  if not gtk_gl_area_get_error(widget).isNil:
    raise newException(IOError, "Failed to initialize OpenGL context")
  
  let
    width = int(gtk_widget_get_allocated_width(widget))
    height = int(gtk_widget_get_allocated_height(widget))
    requiresRedraw = data[].callback((width, height))
  if requiresRedraw:
    if data[].app.isNil:
      raise newException(ValueError, "App is nil")
    data[].app.redraw()

proc renderEventCallback(widget: GtkWidget,
                         context: pointer,
                         data: ptr EventObj[proc (size: (int, int)): bool]): cbool =
  let
    width = int(gtk_widget_get_allocated_width(widget))
    height = int(gtk_widget_get_allocated_height(widget))
    requiresRedraw = data[].callback((width, height))
  if requiresRedraw:
    if data[].app.isNil:
      raise newException(ValueError, "App is nil")
    data[].app.redraw()
  result = cbool(ord(true))

renderable GlArea of CustomWidget:
  useEs: bool = false
  requiredVersion: tuple[major, minor: int] = (4, 3)
  hasDepthBuffer: bool = true
  hasStencilBuffer: bool = false
  
  proc setup(size: (int, int)): bool
  proc render(size: (int, int)): bool
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_gl_area_new()
    connectEvents:
      state.internalWidget.connect(state.setup, "realize", setupEventCallback)
      state.internalWidget.connect(state.render, "render", renderEventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.setup)
      state.internalWidget.disconnect(state.render)
    update:
      gtk_widget_queue_draw(state.internalWidget)
  
  hooks useEs:
    property:
      gtk_gl_area_set_use_es(state.internalWidget, cbool(ord(state.useEs)))
  
  hooks hasDepthBuffer:
    property:
      gtk_gl_area_set_has_depth_buffer(state.internalWidget, cbool(ord(state.hasDepthBuffer)))
  
  hooks hasStencilBuffer:
    property:
      gtk_gl_area_set_has_stencil_buffer(state.internalWidget, cbool(ord(state.hasStencilBuffer)))
  
  hooks requiredVersion:
    property:
      gtk_gl_area_set_required_version(state.internalWidget, 
        cint(state.requiredVersion.major),
        cint(state.requiredVersion.minor)
      )

renderable ColorButton of BaseWidget:
  color: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0)
  useAlpha: bool = false
  
  proc changed(color: tuple[r, g, b, a: float])
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_color_button_new()
    connectEvents:
      state.internalWidget.connect(state.changed, "color-set", colorEventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.changed)
  
  hooks color:
    property:
      var rgba = GdkRgba(
        r: cdouble(state.color.r),
        g: cdouble(state.color.g),
        b: cdouble(state.color.b),
        a: cdouble(state.color.a)
      )
      gtk_color_chooser_set_rgba(state.internalWidget, rgba.addr)
  
  hooks useAlpha:
    property:
      gtk_color_chooser_set_use_alpha(state.internalWidget, cbool(ord(state.useAlpha)))

renderable Switch of BaseWidget:
  state: bool
  
  proc changed(state: bool)
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_switch_new()
    connectEvents:
      state.internalWidget.connect(state.changed, "state-set", switchEventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.changed)
  
  hooks state:
    property:
      gtk_switch_set_state(state.internalWidget, cbool(ord(state.state)))
  
  example:
    Switch:
      state = app.state
      proc changed(state: bool) =
        app.state = state

renderable ToggleButton of Button:
  state: bool
  
  proc changed(state: bool)
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_toggle_button_new()
    connectEvents:
      state.internalWidget.connect(state.changed, "toggled", toggleButtonEventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.changed)
  
  hooks state:
    property:
      gtk_toggle_button_set_active(state.internalWidget, cbool(ord(state.state)))
  
  example:
    ToggleButton:
      text = "Current State: " & $app.state
      state = app.state
      proc changed(state: bool) =
        app.state = state

renderable LinkButton of Button:
  uri: string
  visited: bool
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_link_button_new("")
  
  hooks uri:
    property:
      gtk_link_button_set_uri(state.internalWidget, cstring(state.uri))
  
  hooks visited:
    property:
      gtk_link_button_set_visited(state.internalWidget, cbool(ord(state.visited)))

renderable CheckButton of BaseWidget:
  state: bool
  
  proc changed(state: bool)
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_check_button_new()
    connectEvents:
      state.internalWidget.connect(state.changed, "toggled", checkButtonEventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.changed)
  
  hooks state:
    property:
      gtk_check_button_set_active(state.internalWidget, cbool(ord(state.state)))
  
  example:
    CheckButton:
      state = app.state
      proc changed(state: bool) =
        app.state = state

renderable Popover of BaseWidget:
  child: Widget
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_popover_new(nil)
  
  hooks child:
    build: buildBin(state, widget, gtk_popover_set_child)
    update: updateBin(state, widget, gtk_popover_set_child)
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a Popover. Use a Box widget to display multiple widgets in a popover.")
    widget.hasChild = true
    widget.valChild = child

renderable PopoverMenu of BaseWidget:
  pages: Table[string, Widget]
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_popover_menu_new_from_model(nil)
  
  hooks pages:
    (build, update):
      if widget.hasPages:
        for name, page in widget.valPages:
          page.assignApp(state.app)
        
        let
          window = gtk_popover_get_child(state.internalWidget)
          viewport = gtk_widget_get_first_child(window)
          stack = gtk_widget_get_first_child(viewport)
        
        for name, page in state.pages:
          if name notin widget.valPages:
            gtk_stack_remove(stack, page.unwrapInternalWidget())
        
        for name, pageWidget in widget.valPages:
          if name in state.pages:
            let
              page = state.pages[name]
              newPage = pageWidget.update(page)
            if not newPage.isNil:
              gtk_stack_remove(stack, page.unwrapInternalWidget())
              gtk_stack_add_named(stack, newPage.unwrapInternalWidget(), name.cstring)
              state.pages[name] = newPage
          else:
            let page = pageWidget.build()
            gtk_stack_add_named(stack, page.unwrapInternalWidget(), name.cstring)
            state.pages[name] = page
  
  adder add {.name: "main".}:
    if name in widget.valPages:
      raise newException(ValueError, "Page \"" & name & "\" already exists")
    widget.hasPages = true
    widget.valPages[name] = child

renderable MenuButton of BaseWidget:
  child: Widget
  popover: Widget
  
  style: set[ButtonStyle]
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_menu_button_new()
  
  hooks child:
    build: buildBin(state, widget, gtk_menu_button_set_child)
    update: updateBin(state, widget, gtk_menu_button_set_child)
  
  hooks popover:
    build:
      if widget.hasPopover:
        widget.valPopover.assignApp(state.app)
        state.popover = widget.valPopover.build()
        let popoverWidget = unwrapRenderable(state.popover).internalWidget
        gtk_menu_button_set_popover(state.internalWidget, popoverWidget)
    update:
      if widget.hasPopover:
        widget.valPopover.assignApp(state.app)
        let newPopover = widget.valPopover.update(state.popover)
        if not newPopover.isNil:
          let popoverWidget = newPopover.unwrapInternalWidget()
          gtk_menu_button_set_popover(state.internalWidget, popoverWidget)
          state.popover = newPopover
  
  hooks style:
    (build, update):
      updateStyle(state, widget)
  
  setter text: string
  setter icon: string
  
  adder addChild:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a MenuButton. Use a Box widget to display multiple widgets in a MenuButton.")
    widget.hasChild = true
    widget.valChild = child
  
  adder add:
    if not widget.hasChild:
      widget.hasChild = true
      widget.valChild = child
    elif not widget.hasPopover:
      widget.hasPopover = true
      widget.valPopover = child
    else:
      raise newException(ValueError, "Unable to add more than two children to MenuButton")

proc `hasText=`*(menuButton: MenuButton, value: bool) = menuButton.hasChild = value
proc `valText=`*(menuButton: MenuButton, value: string) =
  menuButton.valChild = Label(hasText: true, valText: value)

proc `hasIcon=`*(menuButton: MenuButton, value: bool) = menuButton.hasChild = value
proc `valIcon=`*(menuButton: MenuButton, name: string) =
  menuButton.valChild = Icon(hasName: true, valName: name)

renderable ModelButton of BaseWidget:
  text: string
  icon: string
  menuName: string
  
  proc clicked()
  
  hooks:
    beforeBuild:
      state.internalWidget = GtkWidget(g_object_new(g_type_from_name("GtkModelButton"), nil))
    connectEvents:
      state.internalWidget.connect(state.clicked, "clicked", eventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.clicked)
  
  hooks text:
    property:
      var value = g_value_new(state.text)
      g_object_set_property(state.internalWidget.pointer, "text", value.addr)
      g_value_unset(value.addr)
  
  hooks icon:
    property:
      var value = g_value_new(state.icon.len > 0)
      g_object_set_property(state.internalWidget.pointer, "iconic", value.addr)
      g_value_unset(value.addr)
      if state.icon.len > 0:
        var err: GError
        let icon = g_icon_new_for_string(state.icon, err.addr)
        var value = g_value_new(icon)
        g_object_set_property(state.internalWidget.pointer, "icon", value.addr)
        g_value_unset(value.addr)
  
  hooks menuName:
    property:
      var value: GValue
      discard g_value_init(value.addr, G_TYPE_STRING)
      if state.menuName.len > 0:
        g_value_set_string(value.addr, state.menuName.cstring)
      else:
        g_value_set_string(value.addr, nil)
      g_object_set_property(state.internalWidget.pointer, "menu_name", value.addr)
      g_value_unset(value.addr)

renderable Separator of BaseWidget:
  orient: Orient
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_separator_new(widget.valOrient.toGtk())

type
  TextBufferObj = object
    gtk: GtkTextBuffer
  
  TextBuffer* = ref TextBufferObj

proc finalizer(buffer: TextBuffer) =
  g_object_unref(pointer(buffer.gtk))

proc newTextBuffer*(): TextBuffer =
  new(result, finalizer=finalizer)
  result.gtk = gtk_text_buffer_new(nil)

proc countLines*(buffer: TextBuffer): int =
  result = int(gtk_text_buffer_get_line_count(buffer.gtk))

proc `text=`*(buffer: TextBuffer, text: string) =
  gtk_text_buffer_set_text(buffer.gtk, text.cstring, text.len.cint)

renderable TextView of BaseWidget:
  buffer: TextBuffer
  monospace: bool
  
  proc changed()
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_text_view_new()
    connectEvents:
      GtkWidget(state.buffer.gtk).connect(state.changed, "changed", eventCallback)
    disconnectEvents:
      GtkWidget(state.buffer.gtk).disconnect(state.changed)
  
  hooks monospace:
    property:
      gtk_text_view_set_monospace(state.internalWidget, cbool(ord(state.monospace)))
  
  hooks buffer:
    property:
      if state.buffer.isNil:
        raise newException(ValueError, "TextView.buffer must not be nil")
      gtk_text_view_set_buffer(state.internalWidget, state.buffer.gtk)

renderable ListBoxRow of BaseWidget:
  child: Widget
  
  proc activate()
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_list_box_row_new()
    connectEvents:
      state.internalWidget.connect(state.activate, "activate", eventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.activate)
  
  hooks child:
    build: buildBin(state, widget, gtk_list_box_row_set_child)
    update: updateBin(state, widget, gtk_list_box_row_set_child)
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a ListBoxRow. Use a Box widget to display multiple widgets in a ListBoxRow.")
    widget.hasChild = true
    widget.valChild = child

  
  example:
    ListBox:
      for it in 0..<10:
        ListBoxRow {.addRow.}:
          proc activate() =
            echo it
          Label(text = $it)

type SelectionMode* = enum
  SelectionNone, SelectionSingle, SelectionBrowse, SelectionMultiple

renderable ListBox of BaseWidget:
  rows: seq[Widget]
  selectionMode: SelectionMode
  selected: HashSet[int]
  
  proc select(rows: HashSet[int])
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_list_box_new()
    connectEvents:
      state.internalWidget.connect(state.select, "selected-rows-changed", listBoxEventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.select)
  
  hooks rows:
    build:
      for row in widget.valRows:
        row.assignApp(widget.app)
        let rowState = row.build()
        state.rows.add(rowState)
        let rowWidget = rowState.unwrapInternalWidget()
        gtk_list_box_append(state.internalWidget, rowWidget)
    update:
      var it = 0
      while it < widget.valRows.len and it < state.rows.len:
        widget.valRows[it].assignApp(state.app)
        let newRow = widget.valRows[it].update(state.rows[it])
        if not newRow.isNil:
          gtk_list_box_remove(state.internalWidget, state.rows[it].unwrapInternalWidget())
          gtk_list_box_insert(state.internalWidget, newRow.unwrapInternalWidget(), it.cint)
          state.rows[it] = newRow
        it += 1
      
      while it < widget.valRows.len:
        widget.valRows[it].assignApp(state.app)
        let
          rowState = widget.valRows[it].build()
          rowWidget = rowState.unwrapInternalWidget()
        state.rows.add(rowState)
        gtk_list_box_append(state.internalWidget, rowWidget)
        it += 1
      
      while it < state.rows.len:
        let row = unwrapRenderable(state.rows.pop()).internalWidget
        gtk_list_box_remove(state.internalWidget, row)
  
  hooks selectionMode:
    property:
      gtk_list_box_set_selection_mode(state.internalWidget,
        GtkSelectionMode(ord(state.selectionMode))
      )
  
  hooks selected:
    (build, update):
      if widget.hasSelected:
        for index in state.selected - widget.valSelected:
          if index >= state.rows.len:
            continue
          let row = state.rows[index].unwrapInternalWidget()
          gtk_list_box_unselect_row(state.internalWidget, row)
        for index in widget.valSelected - state.selected:
          let row = state.rows[index].unwrapInternalWidget()
          gtk_list_box_select_row(state.internalWidget, row)
        state.selected = widget.valSelected
        for row in state.selected:
          if row >= state.rows.len:
            raise newException(IndexDefect, "Unable to select row " & $row & ", since there are only " & $state.rows.len & " rows in the ListBox.")
  
  adder addRow:
    widget.hasRows = true
    widget.valRows.add(child)
  
  adder add:
    if child of ListBoxRow:
      widget.addRow(ListBoxRow(child))
    else:
      widget.addRow(ListBoxRow(hasChild: true, valChild: child))
  
  example:
    ListBox:
      for it in 0..<10:
        Label(text = $it)

renderable FlowBoxChild of BaseWidget:
  child: Widget
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_flow_box_child_new()
  
  hooks child:
    build: buildBin(state, widget, gtk_flow_box_child_set_child)
    update: updateBin(state, widget, gtk_flow_box_child_set_child)
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a FlowBoxChild. Use a Box widget to display multiple widgets in a FlowBoxChild.")
    widget.hasChild = true
    widget.valChild = child
  
  example:
    FlowBox:
      columns = 1..5
      for it in 0..<10:
        FlowBoxChild {.addChild.}:
          Label(text = $it)

renderable FlowBox of BaseWidget:
  homogeneous: bool
  rowSpacing: int
  columnSpacing: int
  columns: HSlice[int, int] = 1..5
  selectionMode: SelectionMode
  children: seq[Widget]
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_flow_box_new()
  
  hooks homogeneous:
    property:
      gtk_flow_box_set_homogeneous(state.internalWidget, cbool(ord(state.homogeneous)))
  
  hooks rowSpacing:
    property:
      gtk_flow_box_set_row_spacing(state.internalWidget, cuint(state.rowSpacing))
  
  hooks columnSpacing:
    property:
      gtk_flow_box_set_column_spacing(state.internalWidget, cuint(state.columnSpacing))
  
  hooks columns:
    property:
      gtk_flow_box_set_min_children_per_line(state.internalWidget, cuint(state.columns.a))
      gtk_flow_box_set_max_children_per_line(state.internalWidget, cuint(state.columns.b))
  
  hooks selectionMode:
    property:
      gtk_flow_box_set_selection_mode(state.internalWidget,
        GtkSelectionMode(ord(state.selectionMode))
      )
  
  hooks children:
    (build, update):
      var it = 0
      while it < widget.valChildren.len and
            it < state.children.len:
        let childWidget = widget.valChildren[it]
        childWidget.assignApp(state.app)
        let newChild = childWidget.update(state.children[it])
        if not newChild.isNil:
          gtk_flow_box_remove(
            state.internalWidget,
            unwrapRenderable(state.children[it]).internalWidget
          )
          gtk_flow_box_insert(
            state.internalWidget,
            unwrapRenderable(newChild).internalWidget,
            cint(it)
          )
          state.children[it] = newChild
        it += 1
      
      while it < widget.valChildren.len:
        let childWidget = widget.valChildren[it]
        childWidget.assignApp(state.app)
        let
          child = childWidget.build()
          childInternal = unwrapRenderable(child).internalWidget
        gtk_flow_box_append(state.internalWidget, childInternal)
        state.children.add(child)
        it += 1
      
      while it < state.children.len:
        let child = state.children.pop()
        gtk_flow_box_remove(
          state.internalWidget,
          unwrapRenderable(child).internalWidget
        )
  
  adder addChild:
    widget.hasChildren = true
    widget.valChildren.add(child)

  adder add:
    widget.addChild(FlowBoxChild(hasChild: true, valChild: child))
  
  example:
    FlowBox:
      columns = 1..5
      for it in 0..<10:
        Label(text = $it)

renderable Frame of BaseWidget:
  label: string
  align: tuple[x, y: float] = (0.0, 0.0)
  child: Widget
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_frame_new(nil)
  
  hooks label:
    property:
      if state.label.len == 0:
        gtk_frame_set_label(state.internalWidget, nil)
      else:
        gtk_frame_set_label(state.internalWidget, state.label.cstring)
  
  hooks align:
    property:
      gtk_frame_set_label_align(state.internalWidget,
        state.align.x.cfloat, state.align.y.cfloat
      )
  
  hooks child:
    build: buildBin(state, widget, gtk_frame_set_child)
    update: updateBin(state, widget, gtk_frame_set_child)
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a Frame. Use a Box widget to display multiple widgets in a Frame.")
    widget.hasChild = true
    widget.valChild = child 
  
  example:
    Frame:
      label = "Frame Title"
      align = (0.2, 0.0)
      Label:
        text = "Content"

type
  DialogResponseKind* = enum
    DialogCustom, DialogAccept, DialogCancel
  
  DialogResponse* = object
    case kind*: DialogResponseKind:
      of DialogCustom: id*: int
      else: discard

proc toDialogResponse*(id: cint): DialogResponse =
  case id:
    of -3: result = DialogResponse(kind: DialogAccept)
    of -6: result = DialogResponse(kind: DialogCancel)
    else: result = DialogResponse(kind: DialogCustom, id: int(id))

proc toGtk(resp: DialogResponse): cint =
  case resp.kind:
    of DialogCustom: result = resp.id.cint
    of DialogAccept: result = -3
    of DialogCancel: result = -6

renderable DialogButton:
  text: string
  response: DialogResponse
  style: set[ButtonStyle]
  
  setter res: DialogResponseKind

proc `hasRes=`*(button: DialogButton, value: bool) =
  button.hasResponse = value

proc `valRes=`*(button: DialogButton, kind: DialogResponseKind) =
  button.valResponse = DialogResponse(kind: kind)

renderable Dialog of Window:
  buttons: seq[DialogButton]
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_dialog_new_with_buttons("", nil, GTK_DIALOG_USE_HEADER_BAR, nil)
      gtk_window_set_child(state.internalWidget, nil)
  
  hooks buttons:
    build:
      for button in widget.val_buttons:
        let
          buttonWidget = gtk_dialog_add_button(state.internalWidget,
            button.valText.cstring,
            button.valResponse.toGtk
          )
          ctx = gtk_widget_get_style_context(buttonWidget)
        for styleClass in button.valStyle:
          gtk_style_context_add_class(ctx, cstring($styleClass))
  
  adder addButton

proc addButton*(dialog: Dialog, button: DialogButton) =
  dialog.hasButtons = true
  dialog.valButtons.add(button)

renderable BuiltinDialog:
  title: string
  buttons: seq[DialogButton]
  
  hooks buttons:
    build:
      for button in widget.valButtons:
        let
          buttonWidget = gtk_dialog_add_button(state.internalWidget,
            button.valText.cstring,
            button.valResponse.toGtk
          )
          ctx = gtk_widget_get_style_context(buttonWidget)
        for styleClass in button.valStyle:
          gtk_style_context_add_class(ctx, cstring($styleClass))
  
  adder addButton

proc addButton*(dialog: BuiltinDialog, button: DialogButton) =
  dialog.hasButtons = true
  dialog.valButtons.add(button)

type FileChooserAction* = enum
  FileChooserOpen,
  FileChooserSave,
  FileChooserSelectFolder,
  FileChooserCreateFolder

renderable FileChooserDialog of BuiltinDialog:
  action: FileChooserAction
  filename: string
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_file_chooser_dialog_new(
        widget.valTitle.cstring,
        nil,
        GtkFileChooserAction(ord(widget.valAction)),
        nil
      )
  
  hooks filename:
    read:
      let file = gtk_file_chooser_get_file(state.internalWidget)
      if file.isNil:
        state.filename = ""
      else:
        state.filename = $g_file_get_path(file)

renderable ColorChooserDialog of BuiltinDialog:
  color: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0)
  useAlpha: bool = false
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_color_chooser_dialog_new(
        widget.valTitle.cstring,
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
      gtk_color_chooser_set_rgba(state.internalWidget, rgba.addr)
    read:
      var color: GdkRgba
      gtk_color_chooser_get_rgba(state.internalWidget, color.addr)
      state.color = (color.r.float, color.g.float, color.b.float, color.a.float)
  
  hooks useAlpha:
    property:
      gtk_color_chooser_set_use_alpha(state.internalWidget, cbool(ord(state.useAlpha)))

renderable MessageDialog of BuiltinDialog:
  message: string
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_message_dialog_new(
        nil,
        GTK_DIALOG_DESTROY_WITH_PARENT,
        GTK_MESSAGE_INFO,
        GTK_BUTTONS_NONE,
        widget.valMessage.cstring,
        nil
      )

renderable AboutDialog of BaseWidget:
  programName: string
  logo: string
  copyright: string
  version: string
  license: string
  credits: seq[(string, seq[string])]
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_about_dialog_new()
  
  hooks programName:
    property:
      gtk_about_dialog_set_program_name(state.internalWidget, state.programName.cstring)
  
  hooks logo:
    property:
      gtk_about_dialog_set_logo_icon_name(state.internalWidget, state.logo.cstring)
  
  hooks copyright:
    property:
      gtk_about_dialog_set_copyright(state.internalWidget, state.copyright.cstring)
  
  hooks version:
    property:
      gtk_about_dialog_set_version(state.internalWidget, state.version.cstring)
  
  hooks license:
    property:
      gtk_about_dialog_set_license(state.internalWidget, state.license.cstring)
  
  hooks credits:
    build:
      if widget.hasCredits:
        state.credits = widget.valCredits
        for (sectionName, people) in state.credits:
          let names = allocCStringArray(people)
          defer: deallocCStringArray(names)
          gtk_about_dialog_add_credit_section(state.internalWidget, sectionName.cstring, names)

export BaseWidget, BaseWidgetState
export Window, Box, Overlay, Label, Icon, Button, HeaderBar, ScrolledWindow, Entry
export Paned, ColorButton, Switch, LinkButton, ToggleButton, CheckButton
export DrawingArea, GlArea, MenuButton, ModelButton, Separator, Popover, PopoverMenu
export TextView, ListBox, ListBoxRow, ListBoxRowState, FlowBox, FlowBoxChild, Frame
export Dialog, DialogState, DialogButton
export BuiltinDialog, BuiltinDialogState
export FileChooserDialog, FileChooserDialogState
export ColorChooserDialog, ColorChooserDialogState
export MessageDialog, MessageDialogState
export AboutDialog, AboutDialogState
export buildState, updateState, assignAppEvents
