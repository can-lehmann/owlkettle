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

when defined(owlkettle_gtk4):
  {.passl: gorge("pkg-config --libs gtk4").}
else:
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
  
  GtkSelectionMode* = enum
    GTK_SELECTION_NONE,
    GTK_SELECTION_SINGLE,
    GTK_SELECTION_BROWSE,
    GTK_SELECTION_MULTIPLE
  
  PangoEllipsizeMode* = enum
    PANGO_ELLIPSIZE_NONE,
    PANGO_ELLIPSIZE_START,
    PANGO_ELLIPSIZE_MIDDLE,
    PANGO_ELLIPSIZE_END
  
  GtkShadowType* = enum
    GTK_SHADOW_NOME,
    GTK_SHADOW_IN,
    GTK_SHADOW_OUT,
    GTK_SHADOW_ETCHED_IN,
    GTK_SHADOW_ETCHED_OUT
  
  GtkFileChooserAction* = enum
    GTK_FILE_CHOOSER_ACTION_OPEN,
    GTK_FILE_CHOOSER_ACTION_SAVE,
    GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER,
    GTK_FILE_CHOOSER_ACTION_CREATE_FOLDER
  
  GtkDialogFlags* = distinct cuint
  
  GtkMessageType* = enum
    GTK_MESSAGE_INFO,
    GTK_MESSAGE_WARNING,
    GTK_MESSAGE_QUESTION,
    GTK_MESSAGE_OTHER
  
  GtkButtonsType* = enum
    GTK_BUTTONS_NONE,
    GTK_BUTTONS_OK,
    GTK_BUTTONS_CLOSE,
    GTK_BUTTONS_CANCEL,
    GTK_BUTTONS_YES_NO,
    GTK_BUTTONS_OK_CANCEL

type
  GtkTextBuffer* = distinct pointer
  GtkTextIter* = distinct pointer
  GtkAdjustment* = distinct pointer
  GtkStyleContext* = distinct pointer
  GtkIconTheme* = distinct pointer
  GtkClipboard* = distinct pointer
  GtkSettings* = distinct pointer
  GtkCssProvider* = distinct pointer

proc is_nil*(obj: GtkTextBuffer): bool {.borrow.}
proc is_nil*(obj: GtkTextIter): bool {.borrow.}
proc is_nil*(obj: GtkAdjustment): bool {.borrow.}
proc is_nil*(obj: GtkStyleContext): bool {.borrow.}
proc is_nil*(obj: GtkIconTheme): bool {.borrow.}
proc is_nil*(obj: GtkClipboard): bool {.borrow.}
proc is_nil*(obj: GtkSettings): bool {.borrow.}
proc is_nil*(obj: GtkCssProvider): bool {.borrow.}

template define_bit_set(Type) =
  proc `==`*(a, b: Type): bool {.borrow.}
  proc `or`*(a, b: Type): Type {.borrow.}
  proc `and`*(a, b: Type): Type {.borrow.}
  proc `not`*(mask: Type): Type {.borrow.}
  
  proc `[]=`*(mask: var Type, attr: Type, state: bool) =
    if state:
      mask = mask or attr
    else:
      mask = mask and (not attr)
  
  proc contains*(mask, attr: Type): bool = (mask and attr) == attr

const
  GTK_DIALOG_MODAL* = GtkDialogFlags(1)
  GTK_DIALOG_DESTROY_WITH_PARENT* = GtkDialogFlags(2)
  GTK_DIALOG_USE_HEADER_BAR* = GtkDialogFlags(4)

define_bit_set(GtkDialogFlags)

type
  GdkRgba* = object
    r*: cdouble
    g*: cdouble
    b*: cdouble
    a*: cdouble
  
  GdkWindow = distinct pointer
  GdkDisplay = distinct pointer
  GdkScreen = distinct pointer
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
  GdkModifierType* = distinct cint
  
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
  
  GdkEventKeyObj* = object
    `type`*: GdkEventType
    window*: GdkWindow
    send_event*: int8
    time*: uint32
    state*: cuint
    keyval*: cuint
    length*: cint
    str*: cstring
    keycode*: uint16
    group*: uint8 
    is_modifier* {.bitsize: 1.}: cuint
  
  GdkEventKey* = ptr GdkEventKeyObj

const
  GDK_POINTER_MOTION_MASK* = GdkEventMask(1 shl 2)
  GDK_BUTTON_PRESS_MASK* = GdkEventMask(1 shl 8)
  GDK_BUTTON_RELEASE_MASK* = GdkEventMask(1 shl 9)
  GDK_KEY_PRESS_MASK* = GdkEventMask(1 shl 10)
  GDK_KEY_RELEASE_MASK* = GdkEventMask(1 shl 11)
  GDK_SCROLL_MASK* = GdkEventMask(1 shl 21)
  GDK_TOUCH_MASK* = GdkEventMask(1 shl 22)
  GDK_SMOOTH_SCROLL_MASK* = GdkEventMask(1 shl 23)

const
  GDK_SHIFT_MASK* = GdkModifierType(1)
  GDK_CONTROL_MASK* = GdkModifierType(1 shl 2)
  GDK_ALT_MASK* = GdkModifierType(1 shl 3)
  GDK_SUPER_MASK* = GdkModifierType(1 shl 26)
  GDK_HYPER_MASK* = GdkModifierType(1 shl 27)
  GDK_META_MASK* = GdkModifierType(1 shl 28)

define_bit_set(GdkEventMask)
define_bit_set(GdkModifierType)

type
  GType* = distinct csize_t
  GValue* = object
    typ: GType
    data: array[2, uint64]
  
  GListObj* = object
    data*: pointer
    next*: GList
    prev*: GList
  
  GList* = ptr GListObj
  
  GErrorObj* = object
    domain*: uint32
    code*: cint
    message*: cstring
  
  GError* = ptr GErrorObj
  
  GResource* = distinct pointer
  GIcon* = distinct pointer
  GApplication* = distinct pointer
  
  GApplicationFlags = distinct cuint

proc is_nil*(obj: GResource): bool {.borrow.}
proc is_nil*(obj: GIcon): bool {.borrow.}
proc is_nil*(obj: GApplication): bool {.borrow.}

const
  G_APPLICATION_FLAGS_NONE* = GApplicationFlags(0)

const
  G_TYPE_BOOLEAN* = GType(5 shl 2)
  G_TYPE_STRING* = GType(16 shl 2)
  G_TYPE_OBJECT* = GType(20 shl 2)

type ClipboardTextCallback = proc (clipboard: GtkClipboard,
                                   text: cstring,
                                   data: pointer) {.cdecl.}

{.push importc, cdecl.}
# GObject
proc g_signal_handler_disconnect*(widget: GtkWidget,
                                  handler_id: culong)
proc g_signal_connect_data*(widget: pointer,
                            name: cstring,
                            callback, data, destroy_data: pointer,
                            flags: GConnectFlags): culong
proc g_object_unref*(obj: pointer)
proc g_object_set_property*(obj: pointer, name: cstring, value: ptr GValue)
proc g_type_fundamental*(id: GType): GType

# GObject.Value
proc g_value_init*(value: ptr GValue, typ: GType): ptr GValue
proc g_value_get_string*(value: ptr GValue): cstring
proc g_value_set_string*(value: ptr GValue, str: cstring)
proc g_value_set_object*(value: ptr GValue, obj: pointer)
proc g_value_set_boolean*(value: ptr GValue, bool_val: cbool)
proc g_value_unset*(value: ptr GValue)

# GLib.List
proc g_list_free*(list: GList)

# Gio.Resource
proc g_resource_load*(path: cstring, err: ptr GError): GResource
proc g_resources_register*(res: GResource)

# Gio.Icon
proc g_icon_new_for_string*(name: cstring, err: ptr GError): GIcon

# Gio.Application
proc g_application_run*(app: GApplication, argc: cint, argv: cstringArray): cint

# Gdk
proc gdk_keyval_to_unicode*(key_val: cuint): uint32

# Gdk.Event
proc gdk_event_get_state*(event: GdkEvent, state: ptr GdkModifierType): cbool

# Gdk.Screen
proc gdk_screen_get_default*(): GdkScreen
proc gtk_style_context_add_provider_for_screen*(screen: GdkScreen, provider: GtkCssProvider, priority: cuint)

# Gtk
proc gtk_init*(argc: ptr cint, argv: ptr cstringArray)
proc gtk_main*()
proc gtk_main_quit*()

# Gtk.Application
proc gtk_application_new*(id: cstring, flags: GApplicationFlags): GApplication
proc gtk_application_add_window*(app: GApplication, window: GtkWidget)

# Gtk.Clipboard
proc gtk_clipboard_get_default*(display: GdkDisplay): GtkClipboard
proc gtk_clipboard_set_text*(clipboard: GtkClipboard, text: cstring, length: cint)
proc gtk_clipboard_request_text*(clipboard: GtkClipboard,
                                 callback: ClipboardTextCallback,
                                 data: pointer)

# Gtk.Settings
proc gtk_settings_get_default*(): GtkSettings

# Gtk.Widget
proc gtk_widget_show*(widget: GtkWidget)
proc gtk_widget_hide*(widget: GtkWidget)
proc gtk_widget_show_all*(widget: GtkWidget)
proc gtk_widget_get_allocated_width*(widget: GtkWidget): cint
proc gtk_widget_get_allocated_height*(widget: GtkWidget): cint
proc gtk_widget_get_style_context*(widget: GtkWidget): GtkStyleContext
proc gtk_widget_set_events*(widget: GtkWidget, events: GdkEventMask)
proc gtk_widget_get_events*(widget: GtkWidget): GdkEventMask
proc gtk_widget_set_sensitive*(widget: GtkWidget, sensitive: cbool)
proc gtk_widget_set_size_request*(widget: GtkWidget, w, h: cint)
proc gtk_widget_set_can_focus*(widget: GtkWidget, sensitive: cbool)
proc gtk_widget_queue_draw*(widget: GtkWidget)
proc gtk_widget_destroy*(widget: GtkWidget)
proc gtk_widget_grab_focus*(widget: GtkWidget)
proc gtk_widget_get_display*(widget: GtkWidget): GdkDisplay

# Gtk.CssProvider
proc gtk_css_provider_new*(): GtkCssProvider
proc gtk_css_provider_load_from_path*(css_provider: GtkCssProvider, path: cstring, error: ptr GError): cbool

# Gtk.StyleContext
proc gtk_style_context_add_class*(ctx: GtkStyleContext, name: cstring)
proc gtk_style_context_remove_class*(ctx: GtkStyleContext, name: cstring)
proc gtk_style_context_has_class*(ctx: GtkStyleContext, name: cstring): cbool
proc gtk_style_context_add_provider*(ctx: GtkStyleContext, provider: GtkCssProvider, priority: cuint)

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
proc gtk_window_set_transient_for*(window, parent: GtkWidget)
proc gtk_window_set_modal*(window: GtkWidget, modal: cbool)
proc gtk_window_set_focus*(window, focus: GtkWidget)

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
proc gtk_label_set_line_wrap*(label: GtkWidget, state: cbool)
proc gtk_label_set_use_markup*(label: GtkWidget, state: cbool)

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
proc gtk_entry_set_visibility*(entry: GtkWidget, visibility: cbool)
proc gtk_entry_set_invisible_char*(entry: GtkWidget, ch: uint32)

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
proc gtk_adjustment_set_value*(adjustment: GtkAdjustment, value: cdouble)

# Gtk.ScrolledWindow
proc gtk_scrolled_window_new*(h_adjustment, v_adjustment: GtkAdjustment): GtkWidget
proc gtk_scrolled_window_get_hadjustment*(window: GtkWidget): GtkAdjustment
proc gtk_scrolled_window_get_vadjustment*(window: GtkWidget): GtkAdjustment

# Gtk.IconTheme
proc gtk_icon_theme_new*(): GtkIconTheme
proc gtk_icon_theme_get_default*(): GtkIconTheme
proc gtk_icon_theme_append_resource_path*(theme: GtkIconTheme, path: cstring)
proc gtk_icon_theme_append_search_path*(theme: GtkIconTheme, path: cstring)

# Gtk.Image
proc gtk_image_new*(): GtkWidget
proc gtk_image_set_from_icon_name*(image: GtkWidget, icon_name: cstring, size: GtkIconSize)
proc gtk_image_set_pixel_size*(image: GtkWidget, pixel_size: cint)

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
proc gtk_color_chooser_set_use_alpha*(widget: GtkWidget, button: cbool)

# Gtk.ColorButton
proc gtk_color_button_new*(): GtkWidget

# Gtk.ColorChooserDialog
proc gtk_color_chooser_dialog_new*(title: cstring, parent: GtkWidget): GtkWidget

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

# Gtk.ModelButton
proc gtk_model_button_new*(): GtkWidget

# Gtk.Separator
proc gtk_separator_new*(orient: GtkOrientation): GtkWidget

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

# Gtk.ListBox
proc gtk_list_box_new*(): GtkWidget
proc gtk_list_box_set_selection_mode*(list_box: GtkWidget, mode: GtkSelectionMode)
proc gtk_list_box_get_selected_rows*(list_box: GtkWidget): GList
proc gtk_list_box_select_row*(list_box, row: GtkWidget)
proc gtk_list_box_unselect_row*(list_box, row: GtkWidget)

# Gtk.ListBoxRow
proc gtk_list_box_row_new*(): GtkWidget
proc gtk_list_box_row_get_index*(row: GtkWidget): cint
proc gtk_list_box_row_is_selected*(row: GtkWidget): cbool

# Gtk.FlowBox
proc gtk_flow_box_new*(): GtkWidget
proc gtk_flow_box_insert*(flow_box, child: GtkWidget, pos: cint)
proc gtk_flow_box_set_homogeneous*(flow_box: GtkWidget, homogeneous: cbool)
proc gtk_flow_box_set_row_spacing*(flow_box: GtkWidget, spacing: cuint)
proc gtk_flow_box_set_column_spacing*(flow_box: GtkWidget, spacing: cuint)
proc gtk_flow_box_set_selection_mode*(flow_box: GtkWidget, mode: GtkSelectionMode)
proc gtk_flow_box_set_min_children_per_line*(flow_box: GtkWidget, count: cuint)
proc gtk_flow_box_set_max_children_per_line*(flow_box: GtkWidget, count: cuint)

# Gtk.FlowBoxChild
proc gtk_flow_box_child_new*(): GtkWidget

# Gtk.Frame
proc gtk_frame_new*(label: cstring): GtkWidget
proc gtk_frame_set_label*(frame: GtkWidget, label: cstring)
proc gtk_frame_set_label_align*(frame: GtkWidget, x, y: cfloat)
proc gtk_frame_set_shadow_type*(frame: GtkWidget, shadow: GtkShadowType)

# Gtk.Dialog
proc gtk_dialog_new*(): GtkWidget
proc gtk_dialog_new_with_buttons*(title: cstring,
                                  parent: GtkWidget,
                                  flags: GtkDialogFlags,
                                  first_btn: cstring): GtkWidget {.varargs.}
proc gtk_dialog_run*(dialog: GtkWidget): cint
proc gtk_dialog_add_button*(dialog: GtkWidget, text: cstring, response: cint): GtkWidget
proc gtk_dialog_get_header_bar*(dialog: GtkWidget): GtkWidget

# Gtk.FileChooser
proc gtk_file_chooser_get_filename*(file_chooser: GtkWidget): cstring

# Gtk.FileChooserDialog
proc gtk_file_chooser_dialog_new*(title: cstring,
                                  parent: GtkWidget,
                                  action: GtkFileChooserAction): GtkWidget {.varargs.}

# Gtk.MessageDialog
proc gtk_message_dialog_new*(parent: GtkWidget,
                             flags: GtkDialogFlags,
                             typ: GtkMessageType,
                             buttons: GtkButtonsType,
                             message: cstring): GtkWidget {.varargs.}

# Gtk.AboutDialog
proc gtk_about_dialog_new*(): GtkWidget
proc gtk_about_dialog_set_copyright*(dialog: GtkWidget, text: cstring)
proc gtk_about_dialog_set_version*(dialog: GtkWidget, text: cstring)
proc gtk_about_dialog_set_program_name*(dialog: GtkWidget, text: cstring)
proc gtk_about_dialog_set_logo_icon_name*(dialog: GtkWidget, name: cstring)
proc gtk_about_dialog_set_license*(dialog: GtkWidget, text: cstring)
proc gtk_about_dialog_add_credit_section*(dialog: GtkWidget, name: cstring, people: cstringArray)
{.pop.}

proc g_value_new*(str: string): GValue =
  discard g_value_init(result.addr, G_TYPE_STRING)
  g_value_set_string(result.addr, str.cstring)

proc g_value_new*(value: bool): GValue =
  discard g_value_init(result.addr, G_TYPE_BOOLEAN)
  g_value_set_boolean(result.addr, cbool(ord(value)))

proc g_signal_connect*(widget: GtkWidget, signal: cstring, closure, data: pointer): culong =
  result = g_signal_connect_data(widget.pointer, signal, closure, data, nil, G_CONNECT_AFTER)

proc g_signal_connect*(app: GApplication, signal: cstring, closure, data: pointer): culong =
  result = g_signal_connect_data(app.pointer, signal, closure, data, nil, G_CONNECT_AFTER)

template with_c_args(argc, argv, body: untyped) =
  block:
    var args: seq[string] = @[]
    for it in 0..param_count():
      args.add(param_str(it))
    var
      argc = cint(param_count() + 1)
      argv = alloc_cstring_array(args)
    defer: argv.dealloc_cstring_array()
    body

proc g_application_run*(app: GApplication): cint =
  with_c_args argc, argv:
    result = g_application_run(app, argc, argv)

proc gtk_init*() =
  with_c_args argc, argv:
    gtk_init(argc.addr, argv.addr)
