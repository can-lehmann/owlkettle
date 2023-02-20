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

import std/[unicode, sets, tables, options]
when defined(nimPreviewSlimSystem):
  import std/assertions
import gtk, widgetdef, cairo, widgetutils

when defined(owlkettleDocs) and isMainModule:
  echo "# Widgets"

type Margin* = object
  top*, bottom*, left*, right*: int

renderable BaseWidget:
  ## The base widget of all widgets. Supports redrawing the entire Application
  ## by calling `<WidgetName>State.app.redraw()
  sensitive: bool = true ## If the widget is interactive
  sizeRequest: tuple[x, y: int] = (-1, -1) ## Requested widget size. A value of -1 means that the natural size of the widget will be used.
  internalMargin {.internal.}: Margin = Margin() ## Allows setting top, bottom, left and right margin of a widget. Margin has those names as fields to set integer values to.
  tooltip: string = "" ## The widget's tooltip is shown on hover
  
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

renderable BaseWindow of BaseWidget:
  defaultSize: tuple[width, height: int] = (800, 600) ## Initial size of the window
  
  proc close() ## Called when the window is closed
  
  hooks:
    connectEvents:
      state.connect(state.close, "destroy", eventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.close)
  
  hooks defaultSize:
    property:
      gtk_window_set_default_size(state.internalWidget,
        state.defaultSize.width.cint,
        state.defaultSize.height.cint
      )

renderable Window of BaseWindow:
  title: string
  titlebar: Widget ## Custom widget set as the titlebar of the window
  child: Widget
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_window_new(GTK_WINDOW_TOPLEVEL)
  
  hooks title:
    property:
      if state.titlebar.isNil:
        gtk_window_set_title(state.internalWidget, state.title.cstring)
  
  hooks titlebar:
    (build, update):
      state.updateChild(state.titlebar, widget.valTitlebar, gtk_window_set_titlebar)
  
  hooks child:
    (build, update):
      state.updateChild(state.child, widget.valChild, gtk_window_set_child)
  
  adder add:
    ## Adds a child to the window. Each window may only have one child.
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a Window. Use a Box widget to display multiple widgets in a Window.")
    widget.hasChild = true
    widget.valChild = child
  
  adder addTitlebar:
    ## Sets a custom titlebar for the window
    widget.hasTitlebar = true
    widget.valTitlebar = child
  
  example:
    Window:
      Label(text = "Hello, world")

type Orient* = enum OrientX, OrientY

proc toGtk(orient: Orient): GtkOrientation =
  result = [GTK_ORIENTATION_HORIZONTAL, GTK_ORIENTATION_VERTICAL][ord(orient)]

type BoxStyle* = enum
  BoxLinked = "linked"
  BoxCard = "card"
  BoxToolbar = "toolbar"
  BoxOsd = "osd"

type BoxChild[T] = object
  widget: T
  expand: bool
  hAlign: Align
  vAlign: Align

proc assignApp[T](child: BoxChild[T], app: Viewable) =
  child.widget.assignApp(app)

renderable Box of BaseWidget:
  ## A Box arranges its child widgets along one dimension.
  orient: Orient ## Orientation of the Box and its containing elements. May be one of OrientX (to orient horizontally) or OrientY (to orient vertically)
  spacing: int ## Spacing between the children of the Box
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
          var sibling: GtkWidget = nil.GtkWidget
          if it > 0:
            sibling = state.children[it - 1].widget.unwrapInternalWidget()
          let newWidget = newChild.unwrapInternalWidget()
          gtk_box_insert_child_after(state.internalWidget, newWidget, sibling)
          state.children[it].widget = newChild
        
        let childWidget = state.children[it].widget.unwrapInternalWidget()
        
        if not newChild.isNil or child.expand != state.children[it].expand:
          case state.orient:
            of OrientX: gtk_widget_set_hexpand(childWidget, child.expand.ord.cbool)
            of OrientY: gtk_widget_set_vexpand(childWidget, child.expand.ord.cbool)
          state.children[it].expand = child.expand
        
        if not newChild.isNil or child.hAlign != state.children[it].hAlign:
          state.children[it].hAlign = child.hAlign
          gtk_widget_set_halign(childWidget, toGtk(child.hAlign))
        
        if not newChild.isNil or child.vAlign != state.children[it].vAlign:
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
    ## Adds a child to the Box.
    ## When expand is true, the child grows to fill up the remaining space in the Box.
    ## The hAlign and vAlign properties allow you to set the horizontal and vertical 
    ## alignment of the child within its allocated area. They may be one of `AlignFill`, 
    ## `AlignStart`, `AlignEnd` or `AlignCenter`.
    ## 
    ## Note: **Any** widgets contained in a Box-Widget get access the `expand` adder, to control their behaviour inside of the Box!
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

renderable Overlay of BaseWidget:
  child: Widget
  overlays: seq[AlignedChild[Widget]]
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_overlay_new()
  
  hooks child:
    (build, update):
      state.updateChild(state.child, widget.valChild, gtk_overlay_set_child)
  
  hooks overlays:
    (build, update):
      state.updateAlignedChildren(
        state.overlays,
        widget.valOverlays,
        gtk_overlay_add_overlay,
        gtk_overlay_remove_overlay
      )
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a Overlay. You can add overlays using the addOverlay adder.")
    widget.hasChild = true
    widget.valChild = child
  
  adder addOverlay {.hAlign: AlignFill,
                     vAlign: AlignFill.}:
    widget.hasOverlays = true
    widget.valOverlays.add(AlignedChild[Widget](
      widget: child,
      hAlign: hAlign,
      vAlign: vAlign
    ))

type LabelStyle* = enum
  LabelTitle1 = "title-1"
  LabelTitle2 = "title-2"
  LabelTitle3 = "title-3"
  LabelTitle4 = "title-4"
  
  LabelHeading = "heading"
  LabelBody = "body"
  LabelMonospace = "monospace"

type EllipsizeMode* = enum
  ## Determines whether to ellipsize text when text does not fit in a given space
  EllipsizeNone ## Do not ellipsize 
  EllipsizeStart, ## Start ellipsizing at the start of the text
  EllipsizeMiddle, ## Start ellipsizing in the middle of the text
  EllipsizeEnd ## Start ellipsizing at the end of the text

renderable Label of BaseWidget:
  ## The default widget to display text.
  ## Supports rendering [Pango Markup](https://docs.gtk.org/Pango/pango_markup.html#pango-markup) 
  ## if `useMarkup` is enabled.
  text: string ## The text of the Label to render
  xAlign: float = 0.5
  yAlign: float = 0.5
  ellipsize: EllipsizeMode ## Determines whether to ellipsise the text in case space is insufficient to render all of it. May be one of `EllipsizeNone`, `EllipsizeStart`, `EllipsizeMiddle` or `EllipsizeEnd`
  wrap: bool = false ## Enables/Disable wrapping of text.
  useMarkup: bool = false ## Determines whether to interpret the given text as Pango Markup or not.
  
  style: set[LabelStyle] ## The style of the text used. May be one of `LabelHeading`, `LabelBody` or `LabelMonospace`.
  
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
  name: string ## See [recommended_tools.md](recommended_tools.md#icons) for a list of icons.
  pixelSize: int = -1 ## Determines the size of the icon
  
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
  style: set[ButtonStyle] ## Applies special styling to the button. May be one of `ButtonSuggested`, `ButtonDestructive`, `ButtonFlat`, `ButtonPill` or `ButtonCircular`. Consult the [GTK4 documentation](https://developer.gnome.org/hig/patterns/controls/buttons.html?highlight=button#button-styles) for guidance on what to use.
  child: Widget
  shortcut: string ## Keyboard shortcut
  
  proc clicked()
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_button_new()
    connectEvents:
      state.connect(state.clicked, "clicked", eventCallback)
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
    (build, update):
      state.updateChild(state.child, widget.valChild, gtk_button_set_child)
  
  setter text: string
  setter icon: string ## Sets the icon of the Button (see [recommended_tools.md](recommended_tools.md#icons) for a list of icons)
  
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
  
  example:
    Button:
      text = "Copy"
      shortcut = "<Ctrl>C"
      proc clicked() =
        app.writeClipboard("Hello, world!")


proc `hasText=`*(button: Button, value: bool) = button.hasChild = value
proc `valText=`*(button: Button, value: string) =
  button.valChild = Label(hasText: true, valText: value)

proc `hasIcon=`*(button: Button, value: bool) = button.hasChild = value
proc `valIcon=`*(button: Button, name: string) =
  button.valChild = Icon(hasName: true, valName: name)

proc updateChild*(state: Renderable,
                  child: var BoxChild[WidgetState],
                  updater: BoxChild[Widget],
                  setChild: proc(widget, child: GtkWidget) {.cdecl, locks: 0.}) =
  if updater.widget.isNil:
    if not child.widget.isNil:
      child.widget = nil
      setChild(state.internalWidget, nil.GtkWidget)
  else:
    updater.assignApp(state.app)
    let newChild =
      if child.widget.isNil:
        updater.widget.build()
      else:
        updater.widget.update(child.widget)
    
    if not newChild.isNil:
      child.widget = newChild
      setChild(state.internalWidget, unwrapInternalWidget(child.widget))
    
    let childWidget = unwrapInternalWidget(child.widget)
    
    if not newChild.isNil or updater.hAlign != child.hAlign:
      child.hAlign = updater.hAlign
      gtk_widget_set_halign(childWidget, toGtk(child.hAlign))
    
    if not newChild.isNil or updater.vAlign != child.vAlign:
      child.vAlign = updater.vAlign
      gtk_widget_set_valign(childWidget, toGtk(child.vAlign))
    
    if not newChild.isNil or updater.expand != child.expand:
      child.expand = updater.expand
      gtk_widget_set_hexpand(childWidget, child.expand.ord.cbool)

renderable HeaderBar of BaseWidget:
  title: BoxChild[Widget]
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
      state.updateChildren(
        state.left,
        widget.valLeft,
        gtk_header_bar_pack_start,
        gtk_header_bar_remove
      )
  
  hooks right:
    (build, update):
      state.updateChildren(
        state.right,
        widget.valRight,
        gtk_header_bar_pack_end,
        gtk_header_bar_remove
      )
  
  hooks title:
    (build, update):
      state.updateChild(state.title, widget.valTitle, gtk_header_bar_set_title_widget)
  
  adder addTitle {.expand: false,
                   hAlign: AlignFill,
                   vAlign: AlignFill.}:
    ## Adds a custom title widget to the HeaderBar.
    ## When expand is true, it grows to fill up the remaining space in the headerbar.
    ## The hAlign and vAlign properties allow you to set the horizontal and vertical 
    ## alignment of the child within its allocated area. They may be one of `AlignFill`, 
    ## `AlignStart`, `AlignEnd` or `AlignCenter`.
    if widget.hasTitle:
      raise newException(ValueError, "Unable to add multiple title widgets to a HeaderBar.")
    widget.hasTitle = true
    widget.valTitle = BoxChild[Widget](
      widget: child,
      expand: expand,
      hAlign: hAlign,
      vAlign: vAlign
    )
  
  adder addLeft:
    ## Adds a widget to the left side of the HeaderBar.
    widget.hasLeft = true
    widget.valLeft.add(child)
  
  adder addRight:
    ## Adds a widget to the right side of the HeaderBar.
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
      state.internalWidget = gtk_scrolled_window_new(nil.GtkAdjustment, nil.GtkAdjustment)
  
  hooks child:
    (build, update):
      state.updateChild(state.child, widget.valChild, gtk_scrolled_window_set_child)
  
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
  placeholder: string ## Shown when the Entry is empty.
  width: int = -1
  maxWidth: int = -1
  xAlign: float = 0.0
  visibility: bool = true
  invisibleChar: Rune = '*'.Rune
  
  style: set[EntryStyle]
  
  proc changed(text: string) ## Called when the text in the Entry changed
  proc activate() ## Called when the user presses enter/return

  hooks:
    beforeBuild:
      state.internalWidget = gtk_entry_new()
    connectEvents:
      proc changedCallback(widget: GtkWidget, data: ptr EventObj[proc (text: string)]) {.cdecl.} =
        let text = $gtk_editable_get_text(widget)
        EntryState(data[].widget).text = text
        data[].callback(text)
        data[].redraw()
      
      state.connect(state.changed, "changed", changedCallback)
      state.connect(state.activate, "activate", eventCallback)
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
  orient: Orient ## Orientation of the panes
  initialPosition: int ## Initial position of the separator in pixels
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
  discard data[].app.redraw()
  result = cbool(ord(stopEvent))

proc drawFunc(widget: GtkWidget,
              ctx: pointer,
              width, height: cint,
              data: pointer) {.cdecl.} =
  let
    event = cast[ptr EventObj[proc (ctx: CairoContext, size: (int, int)): bool]](data)
    requiresRedraw = event[].callback(CairoContext(ctx), (int(width), int(height)))
  if requiresRedraw:
    event[].redraw()

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
  ## Allows you to render 2d scenes using cairo.
  ## The `owlkettle/cairo` module provides bindings for cairo.
  
  proc draw(ctx: CairoContext, size: (int, int)): bool ## Called when the widget is rendered. Redraws the application if the callback returns true.
  
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
    data[].redraw()

proc renderEventCallback(widget: GtkWidget,
                         context: pointer,
                         data: ptr EventObj[proc (size: (int, int)): bool]): cbool =
  let
    width = int(gtk_widget_get_allocated_width(widget))
    height = int(gtk_widget_get_allocated_height(widget))
    requiresRedraw = data[].callback((width, height))
  if requiresRedraw:
    data[].redraw()
  result = cbool(ord(true))

renderable GlArea of CustomWidget:
  ## Allows you to render 3d scenes using OpenGL.
  
  useEs: bool = false
  requiredVersion: tuple[major, minor: int] = (4, 3)
  hasDepthBuffer: bool = true
  hasStencilBuffer: bool = false
  
  proc setup(size: (int, int)): bool ## Called after the OpenGL Context is initialized. Redraws the application if the callback returns true.
  proc render(size: (int, int)): bool ## Called when the widget is rendered. Your rendering code should be executed here. Redraws the application if the callback returns true.
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_gl_area_new()
    connectEvents:
      state.connect(state.setup, "realize", setupEventCallback)
      state.connect(state.render, "render", renderEventCallback)
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
  color: tuple[r, g, b, a: float] = (0.0, 0.0, 0.0, 1.0) ## Red, Geen, Blue, Alpha as floating point numbers in the range [0.0, 1.0]
  useAlpha: bool = false
  
  proc changed(color: tuple[r, g, b, a: float])
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_color_button_new()
    connectEvents:
      proc colorSetCallback(widget: GtkWidget, data: ptr EventObj[proc (color: tuple[r, g, b, a: float])]) {.cdecl.} =
        var gdkColor: GdkRgba
        gtk_color_chooser_get_rgba(widget, gdkColor.addr)
        let color = (gdkColor.r.float, gdkColor.g.float, gdkColor.b.float, gdkColor.a.float)
        ColorButtonState(data[].widget).color = color
        data[].callback(color)
        data[].redraw()
      
      state.connect(state.changed, "color-set", colorSetCallback)
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
      proc stateSetCallback(widget: GtkWidget, state: cbool, data: ptr EventObj[proc (state: bool)]): cbool {.cdecl.} =
        let state = state != 0
        SwitchState(data[].widget).state = state
        data[].callback(state)
        data[].redraw()
      
      state.connect(state.changed, "state-set", stateSetCallback)
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
      proc toggledCallback(widget: GtkWidget, data: ptr EventObj[proc (state: bool)]) {.cdecl.} =
        let state = gtk_toggle_button_get_active(widget) != 0
        ToggleButtonState(data[].widget).state = state
        data[].callback(state)
        data[].redraw()
      
      state.connect(state.changed, "toggled", toggledCallback)
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
  ## A clickable link.
  
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
      proc toggledCallback(widget: GtkWidget, data: ptr EventObj[proc (state: bool)]) {.cdecl.} =
        let state = gtk_check_button_get_active(widget) != 0
        CheckButtonState(data[].widget).state = state
        data[].callback(state)
        data[].redraw()
      
      state.connect(state.changed, "toggled", toggledCallback)
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

type PopoverPosition* = enum
  PopoverLeft
  PopoverRight
  PopoverTop
  PopoverBottom

proc toGtk(pos: PopoverPosition): GtkPositionType =
  result = GtkPositionType(ord(pos))

renderable BasePopover of BaseWidget:
  hasArrow: bool = true
  offset: tuple[x, y: int] = (0, 0)
  position: PopoverPosition = PopoverBottom
  
  hooks hasArrow:
    property:
      gtk_popover_set_has_arrow(state.internalWidget, cbool(ord(state.hasArrow)))
  
  hooks offset:
    property:
      gtk_popover_set_offset(state.internalWidget,
        cint(state.offset.x),
        cint(state.offset.y)
      )
  
  hooks position:
    property:
      gtk_popover_set_position(state.internalWidget, toGtk(state.position))

renderable Popover of BasePopover:
  child: Widget
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_popover_new(nil.GtkWidget)
  
  hooks child:
    (build, update):
      state.updateChild(state.child, widget.valChild, gtk_popover_set_child)
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a Popover. Use a Box widget to display multiple widgets in a popover.")
    widget.hasChild = true
    widget.valChild = child

renderable PopoverMenu of BasePopover:
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
  
  style: set[ButtonStyle] ## Applies special styling to the button. May be one of `ButtonSuggested`, `ButtonDestructive`, `ButtonFlat`, `ButtonPill` or `ButtonCircular`. Consult the [GTK4 documentation](https://developer.gnome.org/hig/patterns/controls/buttons.html?highlight=button#button-styles) for guidance on what to use.
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_menu_button_new()
  
  hooks child:
    (build, update):
      state.updateChild(state.child, widget.valChild, gtk_menu_button_set_child)
  
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
  setter icon: string ## Sets the icon of the MenuButton. Typically `open-menu` is used. See [recommended_tools.md](recommended_tools.md#icons) for a list of icons.
  
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
  icon: string ## The icon of the ModelButton (see [recommended_tools.md](recommended_tools.md#icons) for a list of icons)
  shortcut: string
  menuName: string
  
  proc clicked()
  
  hooks:
    beforeBuild:
      state.internalWidget = GtkWidget(g_object_new(g_type_from_name("GtkModelButton"), nil))
    connectEvents:
      state.connect(state.clicked, "clicked", eventCallback)
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
        let icon = g_icon_new_for_string(state.icon.cstring, err.addr)
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
  
  hooks shortcut:
    property:
      var value = g_value_new(state.shortcut)
      g_object_set_property(state.internalWidget.pointer, "accel", value.addr)
      g_value_unset(value.addr)

renderable Separator of BaseWidget:
  orient: Orient
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_separator_new(widget.valOrient.toGtk())

type
  UnderlineKind* = enum
    UnderlineNone, UnderlineSingle, UnderlineDouble,
    UnderlineLow, UnderlineError
  
  TagStyle* = object
    background*: Option[string]
    foreground*: Option[string]
    family*: Option[string]
    size*: Option[int]
    strikethrough*: Option[bool]
    weight*: Option[int]
    underline*: Option[UnderlineKind]
    style*: Option[CairoFontSlant]
  
  TextBufferObj = object
    gtk: GtkTextBuffer
  
  TextBuffer* = ref TextBufferObj
  
  TextIter* = GtkTextIter
  TextTag* = GtkTextTag
  TextSlice* = HSlice[TextIter, TextIter]

proc finalizer(buffer: TextBuffer) =
  g_object_unref(pointer(buffer.gtk))

proc newTextBuffer*(): TextBuffer =
  new(result, finalizer=finalizer)
  result.gtk = gtk_text_buffer_new(nil.GtkTextTagTable)

{.push hint[Name]: off.}
proc g_value_new(value: UnderlineKind): GValue =
  discard g_value_init(result.addr, G_TYPE_INT)
  g_value_set_int(result.addr, cint(ord(value)))

proc g_value_new(value: CairoFontSlant): GValue =
  const IDS: array[CairoFontSlant, cint] = [
    FontSlantNormal: cint(0),
    FontSlantItalic: cint(2),
    FontSlantOblique: cint(1)
  ]
  discard g_value_init(result.addr, G_TYPE_INT)
  g_value_set_int(result.addr, IDS[value])
{.pop.}

proc registerTag*(buffer: TextBuffer, name: string, style: TagStyle): TextTag =
  result = gtk_text_buffer_create_tag(buffer.gtk, name.cstring, nil)
  for attr, value in fieldPairs(style):
    if value.isSome:
      var gvalue = g_value_new(get(value))
      g_object_set_property(result.pointer, attr.cstring, gvalue.addr)
      g_value_unset(gvalue.addr)

proc lookupTag*(buffer: TextBuffer, name: string): TextTag =
  let tab = gtk_text_buffer_get_tag_table(buffer.gtk)
  result = gtk_text_tag_table_lookup(tab, name.cstring)

proc unregisterTag*(buffer: TextBuffer, tag: TextTag) =
  let tab = gtk_text_buffer_get_tag_table(buffer.gtk)
  gtk_text_tag_table_remove(tab, tag)

proc unregisterTag*(buffer: TextBuffer, name: string) =
  buffer.unregisterTag(buffer.lookupTag(name))

{.push inline.}
proc lineCount*(buffer: TextBuffer): int =
  result = int(gtk_text_buffer_get_line_count(buffer.gtk))

proc charCount*(buffer: TextBuffer): int =
  result = int(gtk_text_buffer_get_char_count(buffer.gtk))

proc startIter*(buffer: TextBuffer): TextIter =
  gtk_text_buffer_get_start_iter(buffer.gtk, result.addr)

proc endIter*(buffer: TextBuffer): TextIter =
  gtk_text_buffer_get_end_iter(buffer.gtk, result.addr)

proc iterAtLine*(buffer: TextBuffer, line: int): TextIter =
  gtk_text_buffer_get_iter_at_line(buffer.gtk, result.addr, line.cint)

proc iterAtOffset*(buffer: TextBuffer, offset: int): TextIter =
  gtk_text_buffer_get_iter_at_offset(buffer.gtk, result.addr, offset.cint)

proc `text=`*(buffer: TextBuffer, text: string) =
  gtk_text_buffer_set_text(buffer.gtk, text.cstring, text.len.cint)

proc text*(buffer: TextBuffer, start, stop: TextIter, hiddenChars: bool = true): string =
  result = $gtk_text_buffer_get_text(
    buffer.gtk, start.unsafeAddr, stop.unsafeAddr, cbool(ord(hiddenChars))
  )

proc text*(buffer: TextBuffer, slice: TextSlice, hiddenChars: bool = true): string =
  result = buffer.text(slice.a, slice.b, hiddenChars)

proc text*(buffer: TextBuffer, hiddenChars: bool = true): string =
  result = buffer.text(buffer.startIter, buffer.endIter)

proc isModified*(buffer: TextBuffer): bool =
  result = gtk_text_buffer_get_modified(buffer.gtk) != 0

proc hasSelection*(buffer: TextBuffer): bool =
  result = gtk_text_buffer_get_has_selection(buffer.gtk) != 0

proc selection*(buffer: TextBuffer): TextSlice =
  discard gtk_text_buffer_get_selection_bounds(
    buffer.gtk, result.a.addr, result.b.addr
  )

proc placeCursor*(buffer: TextBuffer, iter: TextIter) =
  gtk_text_buffer_place_cursor(buffer.gtk, iter.unsafeAddr)

proc select*(buffer: TextBuffer, insert, other: TextIter) =
  gtk_text_buffer_select_range(buffer.gtk, insert.unsafeAddr, other.unsafeAddr)

proc delete*(buffer: TextBuffer, a, b: TextIter) =
  gtk_text_buffer_delete(buffer.gtk, a.unsafeAddr, b.unsafeAddr)

proc delete*(buffer: TextBuffer, slice: TextSlice) = buffer.delete(slice.a, slice.b)

proc insert*(buffer: TextBuffer, iter: TextIter, text: string) =
  gtk_text_buffer_insert(buffer.gtk, iter.unsafeAddr, cstring(text), cint(text.len))

proc applyTag*(buffer: TextBuffer, name: string, a, b: TextIter) =
  gtk_text_buffer_apply_tag_by_name(buffer.gtk, name.cstring, a.unsafeAddr, b.unsafeAddr)

proc applyTag*(buffer: TextBuffer, name: string, slice: TextSlice) =
  buffer.applyTag(name, slice.a, slice.b)

proc removeTag*(buffer: TextBuffer, name: string, a, b: TextIter) =
  gtk_text_buffer_remove_tag_by_name(buffer.gtk, name.cstring, a.unsafeAddr, b.unsafeAddr)

proc removeTag*(buffer: TextBuffer, name: string, slice: TextSlice) =
  buffer.removeTag(name, slice.a, slice.b)

proc removeAllTags*(buffer: TextBuffer, a, b: TextIter) =
  gtk_text_buffer_remove_all_tags(buffer.gtk, a.unsafeAddr, b.unsafeAddr)

proc removeAllTags*(buffer: TextBuffer, slice: TextSlice) =
  buffer.removeAllTags(slice.a, slice.b)

proc canRedo*(buffer: TextBuffer): bool = bool(gtk_text_buffer_get_can_redo(buffer.gtk) != 0)
proc canUndo*(buffer: TextBuffer): bool = bool(gtk_text_buffer_get_can_undo(buffer.gtk) != 0)
proc redo*(buffer: TextBuffer) = gtk_text_buffer_redo(buffer.gtk)
proc undo*(buffer: TextBuffer) = gtk_text_buffer_undo(buffer.gtk)
{.pop.}

{.push inline.}
proc `==`*(a, b: TextIter): bool =
  result = gtk_text_iter_equal(a.unsafeAddr, b.unsafeAddr) != 0

proc `<`*(a, b: TextIter): bool =
  result = gtk_text_iter_compare(a.unsafeAddr, b.unsafeAddr) < 0

proc `<=`*(a, b: TextIter): bool =
  result = gtk_text_iter_compare(a.unsafeAddr, b.unsafeAddr) <= 0

proc cmp*(a, b: TextIter): int =
  result = int(gtk_text_iter_compare(a.unsafeAddr, b.unsafeAddr))

proc contains*(slice: TextSlice, iter: TextIter): bool =
  ## Checks if `iter` is in [`slice.a`, `slice.b`)
  result = gtk_text_iter_in_range(iter.unsafeAddr, slice.a.unsafeAddr, slice.b.unsafeAddr) != 0

proc forwardChars*(iter: var TextIter, count: int): bool =
  result = gtk_text_iter_forward_to_tag_toggle(iter.addr, nil.GtkTextTag) != 0

proc forwardLine*(iter: var TextIter): bool =
  result = gtk_text_iter_forward_line(iter.addr) != 0

proc forwardToLineEnd*(iter: var TextIter): bool =
  result = gtk_text_iter_forward_to_line_end(iter.addr) != 0

proc forwardToTagToggle*(iter: var TextIter): bool =
  result = gtk_text_iter_forward_to_tag_toggle(iter.addr, nil.GtkTextTag) != 0

proc forwardToTagToggle*(iter: var TextIter, tag: TextTag): bool =
  result = gtk_text_iter_forward_to_tag_toggle(iter.addr, tag) != 0

proc backwardChars*(iter: var TextIter, count: int): bool =
  result = gtk_text_iter_backward_to_tag_toggle(iter.addr, nil.GtkTextTag) != 0

proc backwardLine*(iter: var TextIter): bool =
  result = gtk_text_iter_backward_line(iter.addr) != 0

proc backwardToTagToggle*(iter: var TextIter): bool =
  result = gtk_text_iter_backward_to_tag_toggle(iter.addr, nil.GtkTextTag) != 0

proc backwardToTagToggle*(iter: var TextIter, tag: TextTag): bool =
  result = gtk_text_iter_backward_to_tag_toggle(iter.addr, tag) != 0

proc isStart*(iter: TextIter): bool = gtk_text_iter_is_start(iter.unsafeAddr) != 0
proc isEnd*(iter: TextIter): bool = gtk_text_iter_is_end(iter.unsafeAddr) != 0
proc canInsert*(iter: TextIter): bool = gtk_text_iter_can_insert(iter.unsafeAddr) != 0

proc hasTag*(iter: TextIter, tag: TextTag): bool =
  result = gtk_text_iter_has_tag(iter.unsafeAddr, tag) != 0

proc startsTag*(iter: TextIter, tag: TextTag): bool =
  result = gtk_text_iter_starts_tag(iter.unsafeAddr, tag) != 0

proc endsTag*(iter: TextIter, tag: TextTag): bool =
  result = gtk_text_iter_ends_tag(iter.unsafeAddr, tag) != 0

proc offset*(iter: TextIter): int = gtk_text_iter_get_offset(iter.unsafeAddr)
proc line*(iter: TextIter): int = gtk_text_iter_get_line(iter.unsafeAddr)
proc lineOffset*(iter: TextIter): int = gtk_text_iter_get_line_offset(iter.unsafeAddr)
proc `offset=`*(iter: TextIter, val: int) = gtk_text_iter_set_offset(iter.unsafeAddr, cint(val))
proc `line=`*(iter: TextIter, val: int) = gtk_text_iter_set_line(iter.unsafeAddr, cint(val))
proc `lineOffset=`*(iter: TextIter, val: int) = gtk_text_iter_set_line_offset(iter.unsafeAddr, cint(val))
{.pop.}

renderable TextView of BaseWidget:
  buffer: TextBuffer
  monospace: bool = false
  cursorVisible: bool = true
  editable: bool = true
  acceptsTab: bool = true
  indent: int = 0
  
  proc changed()
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_text_view_new()
    connectEvents:
      if not state.changed.isNil:
        state.changed.handler = g_signal_connect(
          GtkWidget(state.buffer.gtk), "changed", eventCallback, state.changed[].addr
        )
    disconnectEvents:
      GtkWidget(state.buffer.gtk).disconnect(state.changed)
  
  hooks monospace:
    property:
      gtk_text_view_set_monospace(state.internalWidget, cbool(ord(state.monospace)))
  
  hooks cursorVisible:
    property:
      gtk_text_view_set_cursor_visible(state.internalWidget, cbool(ord(state.cursorVisible)))
  
  hooks editable:
    property:
      gtk_text_view_set_editable(state.internalWidget, cbool(ord(state.editable)))
  
  hooks acceptsTab:
    property:
      gtk_text_view_set_accepts_tab(state.internalWidget, cbool(ord(state.acceptsTab)))
  
  hooks indent:
    property:
      gtk_text_view_set_indent(state.internalWidget, cint(state.indent))
  
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
      state.connect(state.activate, "activate", eventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.activate)
  
  hooks child:
    (build, update):
      state.updateChild(state.child, widget.valChild, gtk_list_box_row_set_child)
  
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

type ListBoxStyle* = enum
  ListBoxNavigationSidebar = "navigation-sidebar"

type SelectionMode* = enum
  SelectionNone, SelectionSingle, SelectionBrowse, SelectionMultiple

renderable ListBox of BaseWidget:
  rows: seq[Widget]
  selectionMode: SelectionMode
  selected: HashSet[int]
  style: set[ListBoxStyle] = {}
  
  proc select(rows: HashSet[int])
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_list_box_new()
    connectEvents:
      proc selectedRowsChanged(widget: GtkWidget, data: ptr EventObj[proc (state: HashSet[int])]) {.cdecl.} =
        let selected = gtk_list_box_get_selected_rows(widget)
        var
          rows = initHashSet[int]()
          cur = selected
        while not cur.isNil:
          rows.incl(int(gtk_list_box_row_get_index(GtkWidget(cur[].data))))
          cur = cur[].next
        g_list_free(selected)
        ListBoxState(data[].widget).selected = rows
        data[].callback(rows)
        data[].redraw()
      
      state.connect(state.select, "selected-rows-changed", selectedRowsChanged)
    disconnectEvents:
      state.internalWidget.disconnect(state.select)
  
  hooks rows:
    (build, update):
      state.updateChildren(
        state.rows,
        widget.valRows,
        gtk_list_box_append,
        gtk_list_box_insert,
        gtk_list_box_remove
      )
  
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
  
  hooks style:
    (build, update):
      updateStyle(state, widget)
  
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
    (build, update):
      state.updateChild(state.child, widget.valChild, gtk_flow_box_child_set_child)
  
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
      state.updateChildren(
        state.children,
        widget.valChildren,
        gtk_flow_box_append,
        gtk_flow_box_insert,
        gtk_flow_box_remove
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
    (build, update):
      state.updateChild(state.child, widget.valChild, gtk_frame_set_child)
  
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

renderable DropDown of BaseWidget:
  items: seq[string]
  selected: int
  enableSearch: bool
  showArrow: bool = true
  
  proc select(item: int)
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_drop_down_new(GListModel(nil), nil)
      
      proc getString(stringObject: GtkStringObject): pointer {.cdecl.} =
        let str = gtk_string_object_get_string(stringObject)
        result = g_strdup(str)
      
      let expr = gtk_cclosure_expression_new(G_TYPE_STRING, nil, 0, nil, GCallback(getString), nil, nil)
      gtk_drop_down_set_expression(state.internalWidget, expr)
      gtk_expression_unref(expr)
    connectEvents:
      proc selectCallback(widget: GtkWidget,
                          pspec: pointer,
                          data: ptr EventObj[proc (item: int)]) {.cdecl.} =
        let
          selected = int(gtk_drop_down_get_selected(widget))
          state = DropDownState(data[].widget)
        if selected != state.selected:
          state.selected = selected
          data[].callback(selected)
          data[].redraw()
      
      state.connect(state.select, "notify::selected", selectCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.select)
  
  hooks enableSearch:
    property:
      gtk_drop_down_set_enable_search(state.internalWidget, cbool(ord(state.enableSearch)))
  
  hooks items:
    property:
      let items = allocCStringArray(state.items)
      defer: deallocCStringArray(items)
      gtk_drop_down_set_model(state.internalWidget, gtk_string_list_new(items))
  
  hooks selected:
    property:
      gtk_drop_down_set_selected(state.internalWidget, cuint(state.selected))
  
  hooks showArrow:
    property:
      gtk_drop_down_set_show_arrow(state.internalWidget, cbool(ord(state.showArrow)))
  
  example:
    DropDown:
      items = @["Option 1", "Option 2", "Option 3"]
      selected = app.selectedItem
      
      proc select(itemIndex: int) =
        app.selectedItem = itemIndex

renderable ContextMenu:
  ## Adds a context menu to a widget.
  ## Context menus are shown when the user right clicks the widget.
  
  child: Widget
  menu: Widget
  controller: GtkEventController = GtkEventController(nil)
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0)
  
  hooks controller:
    (build, update):
      discard
  
  hooks child:
    (build, update):
      proc addChild(box, child: GtkWidget) {.cdecl.} =
        gtk_widget_set_hexpand(child, 1)
        gtk_box_append(box, child)
      
      state.updateChild(state.child, widget.valChild, addChild, gtk_box_remove)
  
  hooks menu:
    (build, update):
      proc replace(box, oldMenu, newMenu: GtkWidget) {.locks: 0.} =
        if not oldMenu.isNil:
          gtk_widget_remove_controller(box, state.controller)
          state.controller = GtkEventController(nil)
          gtk_box_remove(box, oldMenu)
        assert state.controller.isNil
        
        if not newMenu.isNil:
          const RIGHT_CLICK = cuint(3)
          let cont = gtk_gesture_click_new()
          gtk_gesture_single_set_button(cont, RIGHT_CLICK)
          
          proc pressed(gesture: GtkEventController,
                       n_press: cint,
                       x, y: cdouble,
                       data: pointer) =
            let popover = GtkWidget(data)
            gtk_popover_present(popover)
            var rect = GdkRectangle(x: cint(x), y: cint(y), width: 1, height: 1)
            gtk_popover_set_pointing_to(popover, rect.addr)
            gtk_popover_popup(popover)
          
          discard g_signal_connect(cont, "pressed", pressed, pointer(newMenu))
          
          gtk_widget_add_controller(box, cont)
          state.controller = cont
          
          gtk_widget_set_halign(newMenu, GTK_ALIGN_START)
          gtk_box_append(box, newMenu)
      
      state.updateChild(state.menu, widget.valMenu, replace)
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a ContextMenu.")
    widget.hasChild = true
    widget.valChild = child
  
  adder addMenu:
    if widget.hasMenu:
      raise newException(ValueError, "Unable to add multiple menus to a ContextMenu.")
    widget.hasMenu = true
    widget.valMenu = child
  
  example:
    ContextMenu:
      Label:
        text = "Right click here"
      
      PopoverMenu {.addMenu.}:
        hasArrow = false
        
        Box(orient = OrientY):
          for it in 0..<3:
            ModelButton:
              text = "Menu Entry " & $it

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
  style: set[ButtonStyle] ## Applies special styling to the button. May be one of `ButtonSuggested`, `ButtonDestructive`, `ButtonFlat`, `ButtonPill` or `ButtonCircular`. Consult the [GTK4 documentation](https://developer.gnome.org/hig/patterns/controls/buttons.html?highlight=button#button-styles) for guidance on what to use.
  
  setter res: DialogResponseKind

proc `hasRes=`*(button: DialogButton, value: bool) =
  button.hasResponse = value

proc `valRes=`*(button: DialogButton, kind: DialogResponseKind) =
  button.valResponse = DialogResponse(kind: kind)

renderable Dialog of Window:
  buttons: seq[DialogButton]
  
  hooks:
    beforeBuild:
      state.internalWidget = gtk_dialog_new_with_buttons("", nil.GtkWidget, GTK_DIALOG_USE_HEADER_BAR, nil)
      gtk_window_set_child(state.internalWidget, nil.GtkWidget)
  
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
        nil.GtkWidget,
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
        nil.GtkWidget
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
        nil.GtkWidget,
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
  
  example:
    AboutDialog:
      programName = "My Application"
      logo = "applications-graphics"
      version = "1.0.0"
      credits = @{
        "Code": @[
          "Erika Mustermann",
          "Max Mustermann",
        ],
        "Art": @["Max Mustermann"]
      }

export BaseWidget, BaseWidgetState, BaseWindow, BaseWindowState
export Window, Box, Overlay, Label, Icon, Button, HeaderBar, ScrolledWindow, Entry
export Paned, ColorButton, Switch, LinkButton, ToggleButton, CheckButton
export DrawingArea, GlArea, MenuButton, ModelButton, Separator, Popover, PopoverMenu
export TextView, ListBox, ListBoxRow, ListBoxRowState, FlowBox, FlowBoxChild
export Frame, DropDown, ContextMenu
export Dialog, DialogState, DialogButton
export BuiltinDialog, BuiltinDialogState
export FileChooserDialog, FileChooserDialogState
export ColorChooserDialog, ColorChooserDialogState
export MessageDialog, MessageDialogState
export AboutDialog, AboutDialogState
export buildState, updateState, assignAppEvents
