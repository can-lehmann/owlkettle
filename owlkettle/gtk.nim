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

# Bindings for GTK 3

import std/[os]

{.passl: gorge("pkg-config --libs gtk+-3.0").}

type cbool* = cint

type GtkWidget* = distinct pointer
proc is_nil*(widget: GtkWidget): bool {.borrow.}

type
  GtkWindowType* = enum
    GTK_WINDOW_TOPLEVEL, GTK_WINDOW_POPUP
  
  GtkOrientation* = enum
    GTK_ORIENTATION_HORIZONTAL, GTK_ORIENTATION_VERTICAL
  
  GtkPackType* = enum
    GTK_PACK_START, GTK_PACK_END
  
  GConnectFlags* = enum
    G_CONNECT_AFTER, G_CONNECT_SWAPPED # TODO: Correct enum names?
  
  GtkIconSize* = enum
    GTK_ICON_SIZE_INVALID,
    GTK_ICON_SIZE_MENU,
    GTK_ICON_SIZE_SMALL_TOOLBAR,
    GTK_ICON_SIZE_LARGE_TOOLBAR,
    GTK_ICON_SIZE_BUTTON,
    GTK_ICON_SIZE_DND,
    GTK_ICON_SIZE_DIALOG
  
  PangoEllipsizeMode* = enum
    PANGO_ELLIPSIZE_NONE,
    PANGO_ELLIPSIZE_START,
    PANGO_ELLIPSIZE_MIDDLE,
    PANGO_ELLIPSIZE_END

type
  GtkTextBuffer* = distinct pointer
  GtkTextIter* = distinct pointer
  GtkAdjustment* = distinct pointer
  GtkStyleContext* = distinct pointer

proc is_nil*(widget: GtkTextBuffer): bool {.borrow.}
proc is_nil*(widget: GtkTextIter): bool {.borrow.}
proc is_nil*(widget: GtkAdjustment): bool {.borrow.}
proc is_nil*(widget: GtkStyleContext): bool {.borrow.}

type
  GdkRgba* = object
    r*: cdouble
    g*: cdouble
    b*: cdouble
    a*: cdouble
  
  GdkWindow = distinct pointer
  GdkDevice = distinct pointer
  
  GdkEventType* = enum
    GDK_EVENT_NOTHING = -1
    GDK_MOTION_NOTIFY = 3
    GDK_BUTTON_PRESS = 4
    GDK_DOUBLE_BUTTON_PRESS = 5
    GDK_TRIPLE_BUTTON_PRESS = 6
    GDK_BUTTON_RELEASE = 7
    GDK_KEY_PRESS = 8
    GDK_KEY_RELEASE = 9
    GDK_SCROLL = 31
    GDK_EVENT_LAST = 48
  
  GdkEventMask* = distinct cint
  
  GdkScrollDirection* = enum
    GDK_SCROLL_UP, GDK_SCROLL_DOWN,
    GDK_SCROLL_LEFT, GDK_SCROLL_RIGHT,
    GDK_SCROLL_SMOOTH
  
  GdkEventObj* = object
    `type`*: GdkEventType
    window*: GdkWindow
    send_event*: int8
  
  GdkEvent* = ptr GdkEventObj
  
  GdkEventButtonObj* = object
    `type`*: GdkEventType
    window*: GdkWindow
    send_event*: int8
    time*: uint32
    x*, y*: cdouble
    axes*: ptr cdouble
    state*: cuint
    button*: cuint
    device*: GdkDevice
    x_root*, y_root*: cdouble
  
  GdkEventButton* = ptr GdkEventButtonObj
  
  GdkEventMotionObj* = object
    `type`*: GdkEventType
    window*: GdkWindow
    send_event*: int8
    time*: uint32
    x*, y*: cdouble
    axes*: ptr cdouble
    state*: cuint
    is_hint*: int16
    device*: GdkDevice
    x_root*, y_root*: cdouble
  
  GdkEventMotion* = ptr GdkEventMotionObj

const
  GDK_POINTER_MOTION_MASK* = GdkEventMask(1 shl 2)
  GDK_BUTTON_PRESS_MASK* = GdkEventMask(1 shl 8)
  GDK_BUTTON_RELEASE_MASK* = GdkEventMask(1 shl 9)
  GDK_KEY_PRESS_MASK* = GdkEventMask(1 shl 10)
  GDK_KEY_RELEASE_MASK* = GdkEventMask(1 shl 11)
  GDK_SCROLL_MASK* = GdkEventMask(1 shl 21)
  GDK_TOUCH_MASK* = GdkEventMask(1 shl 22)
  GDK_SMOOTH_SCROLL_MASK* = GdkEventMask(1 shl 23)

proc `or`*(a, b: GdkEventMask): GdkEventMask {.borrow.}
proc `and`*(a, b: GdkEventMask): GdkEventMask {.borrow.}
proc `not`*(mask: GdkEventMask): GdkEventMask {.borrow.}

proc `[]=`*(mask: var GdkEventMask, attr: GdkEventMask, state: bool) =
  if state:
    mask = mask or attr
  else:
    mask = mask and (not attr)

{.push importc, cdecl.}
# GObject
proc g_signal_handler_disconnect*(widget: GtkWidget,
                                  handler_id: culong)
proc g_signal_connect_data*(widget: GtkWidget,
                            name: cstring,
                            callback, data, destroy_data: pointer,
                            flags: GConnectFlags): culong
proc g_object_unref*(obj: pointer)

# Gtk
proc gtk_init*(argc: ptr cint, argv: ptr cstringArray)
proc gtk_main*()
proc gtk_main_quit*()

# Gtk.Widget
proc gtk_widget_show*(widget: GtkWidget)
proc gtk_widget_hide*(widget: GtkWidget)
proc gtk_widget_show_all*(widget: GtkWidget)
proc gtk_widget_get_allocated_width*(widget: GtkWidget): cint
proc gtk_widget_get_allocated_height*(widget: GtkWidget): cint
proc gtk_widget_get_style_context*(widget: GtkWidget): GtkStyleContext
proc gtk_widget_set_events*(widget: GtkWidget, events: GdkEventMask)
proc gtk_widget_get_events*(widget: GtkWidget): GdkEventMask
proc gtk_widget_queue_draw*(widget: GtkWidget)

# Gtk.StyleContext
proc gtk_style_context_add_class*(ctx: GtkStyleContext, name: cstring)
proc gtk_style_context_remove_class*(ctx: GtkStyleContext, name: cstring)
proc gtk_style_context_has_class*(ctx: GtkStyleContext, name: cstring): cbool

# Gtk.Container
proc gtk_container_add*(container, widget: GtkWidget)
proc gtk_container_remove*(container, widget: GtkWidget)
proc gtk_container_set_border_width*(container: GtkWidget, border_width: cuint)

# Gtk.Bin
proc gtk_bin_get_child*(bin: GtkWidget): GtkWidget

# Gtk.Window
proc gtk_window_new*(window_type: GtkWindowType): GtkWidget
proc gtk_window_set_title*(window: GtkWidget, title: cstring)
proc gtk_window_set_titlebar*(window, titlebar: GtkWidget)
proc gtk_window_set_default_size*(window: GtkWidget, width, height: cint)

# Gtk.Button
proc gtk_button_new*(): GtkWidget
proc gtk_button_new_with_label*(label: cstring): GtkWidget

# Gtk.Label
proc gtk_label_new*(text: cstring): GtkWidget
proc gtk_label_set_text*(label: GtkWidget, text: cstring)
proc gtk_label_set_markup*(label: GtkWidget, text: cstring)
proc gtk_label_set_xalign*(label: GtkWidget, xalign: cfloat)
proc gtk_label_set_yalign*(label: GtkWidget, yalign: cfloat)
proc gtk_label_set_ellipsize*(label: GtkWidget, mode: PangoEllipsizeMode)

# Gtk.Box
proc gtk_box_new*(orientation: GtkOrientation, spacing: cint): GtkWidget
proc gtk_box_pack_start*(box, widget: GtkWidget, expand, fill: cbool, padding: cuint)
proc gtk_box_pack_end*(box, widget: GtkWidget, expand, fill: cbool, padding: cuint)
proc gtk_box_set_spacing*(box: GtkWidget, spacing: cint)
proc gtk_box_set_child_packing*(box, child: GtkWidget,
                                expand, fill: cbool,
                                padding: cuint,
                                pack_type: GtkPackType)
proc gtk_box_reorder_child*(box, child: GtkWidget, position: cint)

# Gtk.Entry
proc gtk_entry_new*(): GtkWidget
proc gtk_entry_set_text*(entry: GtkWidget, text: cstring)
proc gtk_entry_get_text*(entry: GtkWidget): cstring
proc gtk_entry_set_placeholder_text*(entry: GtkWidget, text: cstring)
proc gtk_entry_get_placeholder_text*(entry: GtkWidget): cstring
proc gtk_entry_set_width_chars*(entry: GtkWidget, chars: cint)
proc gtk_entry_set_alignment*(entry: GtkWidget, alignment: cfloat)

# Gtk.HeaderBar
proc gtk_header_bar_new*(): GtkWidget
proc gtk_header_bar_set_title*(header_bar: GtkWidget, title: cstring)
proc gtk_header_bar_set_subtitle*(header_bar: GtkWidget, title: cstring)
proc gtk_header_bar_set_custom_title*(header_bar, title: GtkWidget)
proc gtk_header_bar_set_show_close_button*(header_bar: GtkWidget, show: cbool)
proc gtk_header_bar_pack_start*(header_bar, child: GtkWidget)
proc gtk_header_bar_pack_end*(header_bar, child: GtkWidget)

# Gtk.Adjustment
proc gtk_adjustment_new*(value, lower, upper, step_increment, page_increment, page_size: cdouble): GtkAdjustment

# Gtk.ScrolledWindow
proc gtk_scrolled_window_new*(h_adjustment, v_adjustment: GtkAdjustment): GtkWidget

# Gtk.Image
proc gtk_image_new*(): GtkWidget
proc gtk_image_set_from_icon_name*(image: GtkWidget, icon_name: cstring, size: GtkIconSize)

# Gtk.Paned
proc gtk_paned_new*(orientation: GtkOrientation): GtkWidget
proc gtk_paned_pack1*(paned, child: GtkWidget, resize, shrink: cbool)
proc gtk_paned_pack2*(paned, child: GtkWidget, resize, shrink: cbool)
proc gtk_paned_set_position*(paned: GtkWidget, pos: cint)

# Gtk.DrawingArea
proc gtk_drawing_area_new*(): GtkWidget

# Gtk.ColorChooser
proc gtk_color_chooser_set_rgba*(widget: GtkWidget, rgba: ptr GdkRgba)
proc gtk_color_chooser_get_rgba*(widget: GtkWidget, rgba: ptr GdkRgba)

# Gtk.ColorButton
proc gtk_color_button_new*(): GtkWidget
proc gtk_color_button_set_use_alpha*(widget: GtkWidget, button: cbool)

# Gtk.Switch
proc gtk_switch_new*(): GtkWidget
proc gtk_switch_set_state*(widget: GtkWidget, state: cbool)

# Gtk.ToggleButton
proc gtk_toggle_button_new*(): GtkWidget
proc gtk_toggle_button_set_active*(widget: GtkWidget, state: cbool)
proc gtk_toggle_button_get_active*(widget: GtkWidget): cbool

# Gtk.CheckButton
proc gtk_check_button_new*(): GtkWidget

# Gtk.Popover
proc gtk_popover_new*(relative_to: GtkWidget): GtkWidget
proc gtk_popover_popup*(popover: GtkWidget)
proc gtk_popover_popdown*(popover: GtkWidget)
proc gtk_popover_set_relative_to*(popover, widget: GtkWidget)

# Gtk.MenuButton
proc gtk_menu_button_new*(): GtkWidget
proc gtk_menu_button_set_popover*(button, popover: GtkWidget)

# Gtk.TextBuffer
proc gtk_text_buffer_new*(table: pointer): GtkTextBuffer
proc gtk_text_buffer_get_line_count*(buffer: GtkTextBuffer): cint
proc gtk_text_buffer_get_char_count*(buffer: GtkTextBuffer): cint
proc gtk_text_buffer_get_modified*(buffer: GtkTextBuffer): cbool
proc gtk_text_buffer_insert*(buffer: GtkTextBuffer, iter: GtkTextIter, text: cstring, len: cint)
proc gtk_text_buffer_delete*(buffer: GtkTextBuffer, start, stop: GtkTextIter)
proc gtk_text_buffer_set_text*(buffer: GtkTextBuffer, text: cstring, len: cint)
proc gtk_text_buffer_get_text*(buffer: GtkTextBuffer,
                               start, stop: GtkTextIter,
                               include_hidden_chars: cbool): cstring
proc gtk_text_buffer_begin_user_action*(buffer: GtkTextBuffer)
proc gtk_text_buffer_end_user_action*(buffer: GtkTextBuffer)
proc gtk_text_buffer_get_start_iter*(buffer: GtkTextBuffer, iter: GtkTextIter)
proc gtk_text_buffer_get_end_iter*(buffer: GtkTextBuffer, iter: GtkTextIter)
proc gtk_text_buffer_get_iter_at_line*(buffer: GtkTextBuffer, iter: GtkTextIter, line: cint)
proc gtk_text_buffer_get_iter_at_offset*(buffer: GtkTextBuffer, iter: GtkTextIter, offset: cint)

# Gtk.TextView
proc gtk_text_view_new*(): GtkWidget
proc gtk_text_view_set_buffer*(text_view: GtkWidget, buffer: GtkTextBuffer)
proc gtk_text_view_set_monospace*(text_view: GtkWidget, monospace: cbool)
{.pop.}

proc g_signal_connect*(widget: GtkWidget, signal: cstring, closure, data: pointer): culong =
  result = g_signal_connect_data(widget, signal, closure, data, nil, G_CONNECT_AFTER)

proc gtk_init*() =
  var args: seq[string] = @[]
  for it in 0..param_count():
    args.add(param_str(it))
  var
    argc = cint(param_count() + 1)
    argv = alloc_cstring_array(args)
  defer: argv.dealloc_cstring_array()
  gtk_init(argc.addr, argv.addr)
