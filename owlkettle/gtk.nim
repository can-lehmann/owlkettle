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

# Bindings for GTK 4

import std/[os]

import std/strutils as strutils
{.passl: strutils.strip(gorge("pkg-config --libs gtk4")).}

type cbool* = cint

type GtkWidget* = distinct pointer
proc isNil*(widget: GtkWidget): bool {.borrow.}

type
  GtkWindowType* = enum
    GTK_WINDOW_TOPLEVEL, GTK_WINDOW_POPUP
  
  GtkOrientation* = enum
    GTK_ORIENTATION_HORIZONTAL, GTK_ORIENTATION_VERTICAL
  
  GtkPackType* = enum
    GTK_PACK_START, GTK_PACK_END
  
  GtkAlign* = enum
    GTK_ALIGN_FILL,
    GTK_ALIGN_START,
    GTK_ALIGN_END,
    GTK_ALIGN_CENTER,
    GTK_ALIGN_BASELINE
  
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
  
  GtkShortcutScope* = enum
    GTK_SHORTCUT_SCOPE_LOCAL
    GTK_SHORTCUT_SCOPE_MANAGED
    GTK_SHORTCUT_SCOPE_GLOBAL
  
  GtkPositionType* = enum
    GTK_POS_LEFT
    GTK_POS_RIGHT
    GTK_POS_TOP
    GTK_POS_BOTTOM
  
  GtkContentFit* = enum
    GTK_CONTENT_FIT_FILL
    GTK_CONTENT_FIT_CONTAIN
    GTK_CONTENT_FIT_COVER
    GTK_CONTENT_FIT_SCALE_DOWN
  
  GtkTextIter* = object
    a, b: pointer
    c, d, e, f, g, h: cint
    i, j: pointer
    k, l, m: cint
    n: pointer
  
  GtkDrawingAreaDrawFunc* = proc(area: GtkWidget, ctx: pointer, width, height: cint, data: pointer) {.cdecl.}

type
  GtkTextBuffer* = distinct pointer
  GtkTextTag* = distinct pointer
  GtkTextTagTable* = distinct pointer
  GtkAdjustment* = distinct pointer
  GtkStyleContext* = distinct pointer
  GtkIconTheme* = distinct pointer
  GtkSettings* = distinct pointer
  GtkCssProvider* = distinct pointer
  GtkEventController* = distinct pointer
  GtkShortcut* = distinct pointer
  GtkShortcutTrigger* = distinct pointer
  GtkShortcutAction* = distinct pointer
  GtkExpression* = distinct pointer
  GtkStringObject* = distinct pointer

proc isNil*(obj: GtkTextBuffer): bool {.borrow.}
proc isNil*(obj: GtkTextTag): bool {.borrow.}
proc isNil*(obj: GtkTextTagTable): bool {.borrow.}
proc isNil*(obj: GtkAdjustment): bool {.borrow.}
proc isNil*(obj: GtkStyleContext): bool {.borrow.}
proc isNil*(obj: GtkIconTheme): bool {.borrow.}
proc isNil*(obj: GtkSettings): bool {.borrow.}
proc isNil*(obj: GtkCssProvider): bool {.borrow.}
proc isNil*(obj: GtkEventController): bool {.borrow.}
proc isNil*(obj: GtkShortcut): bool {.borrow.}
proc isNil*(obj: GtkShortcutTrigger): bool {.borrow.}
proc isNil*(obj: GtkShortcutAction): bool {.borrow.}
proc isNil*(obj: GtkExpression): bool {.borrow.}
proc isNil*(obj: GtkStringObject): bool {.borrow.}

template defineBitSet(typ) =
  proc `==`*(a, b: typ): bool {.borrow.}
  proc `or`*(a, b: typ): typ {.borrow.}
  proc `and`*(a, b: typ): typ {.borrow.}
  proc `not`*(mask: typ): typ {.borrow.}
  
  proc `[]=`*(mask: var typ, attr: typ, state: bool) =
    if state:
      mask = mask or attr
    else:
      mask = mask and (not attr)
  
  proc contains*(mask, attr: typ): bool = (mask and attr) == attr

const
  GTK_DIALOG_MODAL* = GtkDialogFlags(1)
  GTK_DIALOG_DESTROY_WITH_PARENT* = GtkDialogFlags(2)
  GTK_DIALOG_USE_HEADER_BAR* = GtkDialogFlags(4)

defineBitSet(GtkDialogFlags)

type
  GdkRgba* = object
    r*: cfloat
    g*: cfloat
    b*: cfloat
    a*: cfloat
  
  GdkDisplay = distinct pointer
  GdkEvent* = distinct pointer
  
  GdkEventType* = enum
    GDK_MOTION_NOTIFY = 1
    GDK_BUTTON_PRESS = 2
    GDK_BUTTON_RELEASE = 3
    GDK_KEY_PRESS = 4
    GDK_KEY_RELEASE = 5
    GDK_SCROLL = 15
    GDK_EVENT_LAST = 29
  
  GdkEventMask* = distinct cint
  GdkModifierType* = distinct cint
  
  GdkScrollDirection* = enum
    GDK_SCROLL_UP, GDK_SCROLL_DOWN,
    GDK_SCROLL_LEFT, GDK_SCROLL_RIGHT,
    GDK_SCROLL_SMOOTH
  
  GdkClipboard* = distinct pointer
  
  GdkRectangle* = object
    x*, y*: cint
    width*, height*: cint 
  
  GdkPixbuf* = distinct pointer
  
  GdkColorspace* = enum
    GDK_COLORSPACE_RGB
  
  GdkInterpType* = enum
    GDK_INTERP_NEAREST
    GDK_INTERP_TILES
    GDK_INTERP_BILINEAR
    GDK_INTERP_HYPER
  
  GdkPixbufRotation* = enum
    GDK_PIXBUF_ROTATE_NONE = 0
    GDK_PIXBUF_ROTATE_COUNTERCLOCKWISE = 90
    GDK_PIXBUF_ROTATE_UPSIDEDOWN = 180
    GDK_PIXBUF_ROTATE_CLOCKWISE = 270

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

defineBitSet(GdkEventMask)
defineBitSet(GdkModifierType)

proc isNil*(obj: GdkEvent): bool {.borrow.}
proc isNil*(obj: GdkClipboard): bool {.borrow.}
proc isNil*(obj: GdkPixbuf): bool {.borrow.}

type
  GNotificationPriority* = enum
    G_NOTIFICATION_PRIORITY_NORMAL
    G_NOTIFICATION_PRIORITY_LOW
    G_NOTIFICATION_PRIORITY_HIGH
    G_NOTIFICATION_PRIORITY_URGENT
  
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
  
  GQuark* = distinct uint32
  
  GMainContext* = distinct pointer
  
  GDateTime* = distinct pointer
  
  GSourceFunc* = proc(data: pointer): cbool {.cdecl.}
  GDestroyNotify* = proc(data: pointer) {.cdecl.}
  
  GClosure* = distinct pointer
  GClosureMarshal* = proc(closure: GClosure, ret: ptr GValue, paramCount: cuint, params: ptr UncheckedArray[GValue], invocationHint: pointer, data: pointer) {.cdecl.}
  GCallback* = distinct pointer
  GClosureNotify* = proc(data: pointer, closure: GClosure) {.cdecl.}
  
  GAsyncResult* = distinct pointer
  GAsyncReadyCallback* = proc(obj: pointer, result: GAsyncResult, data: pointer) {.cdecl.}
  
  GResource* = distinct pointer
  GIcon* = distinct pointer
  GApplication* = distinct pointer
  GFile* = distinct pointer
  GInputStream* = distinct pointer
  GNotification* = distinct pointer
  
  GListModel* = distinct pointer
  
  GApplicationFlags = distinct cuint

proc isNil*(obj: GResource): bool {.borrow.}
proc isNil*(obj: GIcon): bool {.borrow.}
proc isNil*(obj: GApplication): bool {.borrow.}
proc isNil*(obj: GFile): bool {.borrow.}
proc isNil*(obj: GInputStream): bool {.borrow.}
proc isNil*(obj: GNotification): bool {.borrow.}
proc isNil*(obj: GListModel): bool {.borrow.}

const
  G_APPLICATION_FLAGS_NONE* = GApplicationFlags(0)

const
  G_TYPE_CHAR* = GType(3 shl 2)
  G_TYPE_UCHAR* = GType(4 shl 2)
  G_TYPE_BOOLEAN* = GType(5 shl 2)
  G_TYPE_INT* = GType(6 shl 2)
  G_TYPE_UINT* = GType(7 shl 2)
  G_TYPE_STRING* = GType(16 shl 2)
  G_TYPE_OBJECT* = GType(20 shl 2)

{.push importc, cdecl.}
# GObject
proc g_signal_handler_disconnect*(widget: GtkWidget,
                                  handlerId: culong)
proc g_signal_connect_data*(widget: pointer,
                            name: cstring,
                            callback, data, dataDestructor: pointer,
                            flags: GConnectFlags): culong
proc g_type_from_name*(name: cstring): GType
proc g_object_new*(typ: GType): pointer {.varargs.}
proc g_object_ref*(obj: pointer)
proc g_object_unref*(obj: pointer)
proc g_object_set_property*(obj: pointer, name: cstring, value: ptr GValue)
proc g_type_fundamental*(id: GType): GType

# GObject.Value
proc g_value_init*(value: ptr GValue, typ: GType): ptr GValue
proc g_value_get_string*(value: ptr GValue): cstring
proc g_value_set_string*(value: ptr GValue, str: cstring)
proc g_value_set_object*(value: ptr GValue, obj: pointer)
proc g_value_set_char*(value: ptr GValue, charVal: cchar)
proc g_value_set_uchar*(value: ptr GValue, charVal: uint8)
proc g_value_set_boolean*(value: ptr GValue, boolVal: cbool)
proc g_value_set_int*(value: ptr GValue, intVal: cint)
proc g_value_set_uint*(value: ptr GValue, intVal: cuint)
proc g_value_unset*(value: ptr GValue)

# GLib
proc g_idle_add_full*(priority: cint, fn: GSourceFunc, data: pointer, notify: GDestroyNotify): cuint
proc g_timeout_add_full*(priority: cint, interval: cuint, fn: GSourceFunc, data: pointer, notify: GDestroyNotify): cuint
proc g_strdup*(str: cstring): pointer

# GLib.Source
proc g_source_remove*(id: cuint): cbool

# GLib.List
proc g_list_free*(list: GList)

# GLib.MainContext
proc g_main_context_iteration*(ctx: GMainContext, blocking: cbool): cbool

# GLib.GDateTime
proc g_date_time_new_from_unix_utc*(unix: int64): GDateTime
proc g_date_time_new_from_unix_local*(unix: int64): GDateTime
proc g_date_time_to_unix*(dateTime: GDateTime): int64
proc g_date_time_to_utc*(dateTime: GDateTime): GDateTime
proc g_date_time_unref*(dateTime: GDateTime)

# GLib.Quark
proc g_quark_from_string*(value: cstring): GQuark

# Gio.Resource
proc g_resource_load*(path: cstring, err: ptr GError): GResource
proc g_resources_register*(res: GResource)

# Gio.Icon
proc g_icon_new_for_string*(name: cstring, err: ptr GError): GIcon

# Gio.Application
proc g_application_get_default*(): GApplication
proc g_application_send_notification*(app: GApplication, id: cstring, notification: GNotification)
proc g_application_withdraw_notification*(app: GApplication, id: cstring)
proc g_application_run*(app: GApplication, argc: cint, argv: cstringArray): cint

# Gio.File
proc g_file_new_for_path*(path: cstring): GFile
proc g_file_read*(file: GFile, cancelable: pointer, error: ptr GError): GInputStream
proc g_file_get_path*(file: GFile): cstring
proc g_file_get_uri*(file: GFile): cstring

# Gio.InputStream
proc g_input_stream_close*(stream: GInputStream, cancelable: pointer, error: ptr GError): cbool

# Gio.Notification
proc g_notification_new*(title: cstring): GNotification
proc g_notification_set_body*(notification: GNotification, body: cstring)
proc g_notification_set_category*(notification: GNotification, category: cstring)
proc g_notification_set_icon*(notification: GNotification, icon: GIcon)
proc g_notification_set_priority*(notification: GNotification, priority: GNotificationPriority)

# Gio.GListModel
proc g_list_model_get_n_items*(list: GListModel): cuint
proc g_list_model_get_item*(list: GListModel, index: cuint): pointer

# Gdk
proc gdk_keyval_to_unicode*(keyVal: cuint): uint32

# Gdk.Event
proc gdk_event_get_event_type*(event: GdkEvent): GdkEventType
proc gdk_event_get_modifier_state*(event: GdkEvent): GdkModifierType
proc gdk_event_get_position*(event: GdkEvent, x: ptr cdouble, y: ptr cdouble): cbool
proc gdk_event_get_time*(event: GdkEvent): uint32

# Gdk.ButtonEvent
proc gdk_button_event_get_button*(event: GdkEvent): cuint

# Gdk.KeyEvent
proc gdk_key_event_get_keycode*(event: GdkEvent): cuint
proc gdk_key_event_get_keyval*(event: GdkEvent): cuint

# Gdk.ScrollEvent
proc gdk_scroll_event_get_deltas*(event: GdkEvent, dx: ptr cdouble, dy: ptr cdouble)
proc gdk_scroll_event_get_direction*(event: GdkEvent): GdkScrollDirection

# Gdk.Display
proc gdk_display_get_default*(): GdkDisplay
proc gtk_style_context_add_provider_for_display*(display: GdkDisplay, provider: GtkCssProvider, priority: cuint)
proc gdk_display_get_clipboard*(display: GdkDisplay): GdkClipboard

# Gdk.Clipboard
proc gdk_clipboard_set_text*(clipboard: GdkClipboard, text: cstring, length: cint)

# Gdk.Pixbuf
proc gdk_pixbuf_new*(colorspace: GdkColorspace,
                     hasAlpha: cbool,
                     bitsPerSample, w, h: cint): GdkPixbuf
proc gdk_pixbuf_new_from_data*(pixels: pointer,
                               colorspace: GdkColorspace,
                               hasAlpha: cbool,
                               bitsPerSample, w, h, stride: cint,
                               destroy: proc(pixels, data: pointer) {.cdecl.},
                               destroyData: pointer): GdkPixbuf
proc gdk_pixbuf_new_from_file*(path: cstring, error: ptr GError): GdkPixbuf
proc gdk_pixbuf_new_from_file_at_scale*(path: cstring,
                                        w, h: cint,
                                        preserveAspectRatio: cbool,
                                        error: ptr GError): GdkPixbuf

proc gdk_pixbuf_new_from_stream_async*(stream: GInputStream,
                                       cancelable: pointer,
                                       callback: GAsyncReadyCallback,
                                       data: pointer)
proc gdk_pixbuf_new_from_stream_at_scale_async*(stream: GInputStream,
                                                w, h: cint,
                                                preserveAspectRatio: cbool,
                                                cancelable: pointer,
                                                callback: GAsyncReadyCallback,
                                                data: pointer)
proc gdk_pixbuf_new_from_stream_finish*(result: GAsyncResult, error: ptr GError): GdkPixbuf

proc gdk_pixbuf_get_colorspace*(pixbuf: GdkPixbuf): GdkColorspace
proc gdk_pixbuf_get_bits_per_sample*(pixbuf: GdkPixbuf): cint
proc gdk_pixbuf_get_width*(pixbuf: GdkPixbuf): cint
proc gdk_pixbuf_get_height*(pixbuf: GdkPixbuf): cint
proc gdk_pixbuf_get_n_channels*(pixbuf: GdkPixbuf): cint
proc gdk_pixbuf_get_has_alpha*(pixbuf: GdkPixbuf): cbool
proc gdk_pixbuf_read_pixels*(pixbuf: GdkPixbuf): ptr byte
proc gdk_pixbuf_get_byte_length*(pixbuf: GdkPixbuf): csize_t


proc gdk_pixbuf_copy*(pixbuf: GdkPixbuf): GdkPixbuf
proc gdk_pixbuf_flip*(pixbuf: GdkPixbuf, horizontal: cbool): GdkPixbuf
proc gdk_pixbuf_copy_area*(src: GdkPixbuf,
                           x, y, w, h: cint,
                           dest: GdkPixbuf,
                           destX, destY: cint)
proc gdk_pixbuf_scale_simple*(pixbuf: GdkPixbuf, w, h: cint, interpolation: GdkInterpType): GdkPixbuf
proc gdk_pixbuf_rotate_simple*(pixbuf: GdkPixbuf, rotation: GdkPixbufRotation): GdkPixbuf

proc gdk_pixbuf_savev*(pixbuf: GdkPixbuf,
                       filename, fileType: cstring,
                       keys, vals: cstringArray,
                       error: ptr GError): bool

# Gtk
proc gtk_init*()

# Gtk.Application
proc gtk_application_new*(id: cstring, flags: GApplicationFlags): GApplication
proc gtk_application_add_window*(app: GApplication, window: GtkWidget)

# Gtk.Settings
proc gtk_settings_get_default*(): GtkSettings

# Gtk.Widget
proc gtk_widget_show*(widget: GtkWidget)
proc gtk_widget_hide*(widget: GtkWidget)
proc gtk_widget_get_allocated_width*(widget: GtkWidget): cint
proc gtk_widget_get_allocated_height*(widget: GtkWidget): cint
proc gtk_widget_get_style_context*(widget: GtkWidget): GtkStyleContext
proc gtk_widget_set_sensitive*(widget: GtkWidget, sensitive: cbool)
proc gtk_widget_set_size_request*(widget: GtkWidget, w, h: cint)
proc gtk_widget_set_can_focus*(widget: GtkWidget, sensitive: cbool)
proc gtk_widget_queue_draw*(widget: GtkWidget)
proc gtk_widget_grab_focus*(widget: GtkWidget)
proc gtk_widget_get_display*(widget: GtkWidget): GdkDisplay
proc gtk_widget_set_margin_top*(widget: GtkWidget, margin: cint)
proc gtk_widget_set_margin_bottom*(widget: GtkWidget, margin: cint)
proc gtk_widget_set_margin_start*(widget: GtkWidget, margin: cint)
proc gtk_widget_set_margin_end*(widget: GtkWidget, margin: cint)
proc gtk_widget_set_hexpand*(widget: GtkWidget, expand: cbool)
proc gtk_widget_set_vexpand*(widget: GtkWidget, expand: cbool)
proc gtk_widget_set_halign*(widget: GtkWidget, align: GtkAlign)
proc gtk_widget_set_valign*(widget: GtkWidget, align: GtkAlign)
proc gtk_widget_add_controller*(widget: GtkWidget, cont: GtkEventController)
proc gtk_widget_remove_controller*(widget: GtkWidget, cont: GtkEventController)
proc gtk_widget_translate_coordinates*(src, dest: GtkWidget, srcX, srcY: cdouble, destX, destY: ptr cdouble): cbool
proc gtk_widget_get_root*(widget: GtkWidget): GtkWidget
proc gtk_widget_get_native*(widget: GtkWidget): GtkWidget
proc gtk_widget_get_allocation*(widget: GtkWidget, alloc: ptr GdkRectangle)
proc gtk_widget_set_tooltip_text*(widget: GtkWidget, tooltip: cstring)
proc gtk_widget_set_has_tooltip*(widget: GtkWidget, hasTooltip: cbool)
proc gtk_widget_get_first_child*(widget: GtkWidget): GtkWidget
proc gtk_widget_get_name*(widget: GtkWidget): cstring
proc gtk_widget_measure*(widget: GtkWidget, orient: GtkOrientation, size: cint, min, natural, minBaseline, naturalBaseline: ptr cint)

# Gtk.CssProvider
proc gtk_css_provider_new*(): GtkCssProvider
proc gtk_css_provider_load_from_path*(cssProvider: GtkCssProvider, path: cstring, error: ptr GError): cbool
proc gtk_css_provider_load_from_data*(cssProvider: GtkCssProvider, data: cstring, length: csize_t)

# Gtk.StyleContext
proc gtk_style_context_add_class*(ctx: GtkStyleContext, name: cstring)
proc gtk_style_context_remove_class*(ctx: GtkStyleContext, name: cstring)
proc gtk_style_context_has_class*(ctx: GtkStyleContext, name: cstring): cbool
proc gtk_style_context_add_provider*(ctx: GtkStyleContext, provider: GtkCssProvider, priority: cuint)

# Gtk.Window
proc gtk_window_new*(windowType: GtkWindowType): GtkWidget
proc gtk_window_set_title*(window: GtkWidget, title: cstring)
proc gtk_window_set_titlebar*(window, titlebar: GtkWidget)
proc gtk_window_set_default_size*(window: GtkWidget, width, height: cint)
proc gtk_window_set_transient_for*(window, parent: GtkWidget)
proc gtk_window_set_modal*(window: GtkWidget, modal: cbool)
proc gtk_window_set_focus*(window, focus: GtkWidget)
proc gtk_window_set_child*(window, child: GtkWidget)
proc gtk_window_present*(window: GtkWidget)
proc gtk_window_fullscreen*(window: GtkWidget)
proc gtk_window_unfullscreen*(window: GtkWidget)
proc gtk_window_get_toplevels*(): GListModel
proc gtk_window_close*(window: GtkWidget)
proc gtk_window_destroy*(window: GtkWidget)
proc gtk_window_set_icon_name*(window: GtkWidget, name: cstring)

# Gtk.Button
proc gtk_button_new*(): GtkWidget
proc gtk_button_new_with_label*(label: cstring): GtkWidget
proc gtk_button_set_child*(window, child: GtkWidget)

# Gtk.Label
proc gtk_label_new*(text: cstring): GtkWidget
proc gtk_label_set_text*(label: GtkWidget, text: cstring)
proc gtk_label_set_markup*(label: GtkWidget, text: cstring)
proc gtk_label_set_xalign*(label: GtkWidget, xalign: cfloat)
proc gtk_label_set_yalign*(label: GtkWidget, yalign: cfloat)
proc gtk_label_set_ellipsize*(label: GtkWidget, mode: PangoEllipsizeMode)
proc gtk_label_set_wrap*(label: GtkWidget, state: cbool)
proc gtk_label_set_use_markup*(label: GtkWidget, state: cbool)

# Gtk.Box
proc gtk_box_new*(orientation: GtkOrientation, spacing: cint): GtkWidget
proc gtk_box_append*(box, widget: GtkWidget)
proc gtk_box_prepend*(box, widget: GtkWidget)
proc gtk_box_remove*(box, widget: GtkWidget)
proc gtk_box_insert_child_after*(box, widget, after: GtkWidget)
proc gtk_box_set_spacing*(box: GtkWidget, spacing: cint)

# Gtk.Overlay
proc gtk_overlay_new*(): GtkWidget
proc gtk_overlay_set_child*(overlay, child: GtkWidget)
proc gtk_overlay_add_overlay*(overlay, child: GtkWidget)
proc gtk_overlay_remove_overlay*(overlay, child: GtkWidget)

# Gtk.Editable
proc gtk_editable_set_text*(entry: GtkWidget, text: cstring)
proc gtk_editable_get_text*(entry: GtkWidget): cstring
proc gtk_editable_set_width_chars*(entry: GtkWidget, chars: cint)
proc gtk_editable_set_max_width_chars*(entry: GtkWidget, chars: cint)

# Gtk.Entry
proc gtk_entry_new*(): GtkWidget
proc gtk_entry_set_placeholder_text*(entry: GtkWidget, text: cstring)
proc gtk_entry_get_placeholder_text*(entry: GtkWidget): cstring
proc gtk_entry_set_alignment*(entry: GtkWidget, alignment: cfloat)
proc gtk_entry_set_visibility*(entry: GtkWidget, visibility: cbool)
proc gtk_entry_set_invisible_char*(entry: GtkWidget, ch: uint32)

# Gtk.HeaderBar
proc gtk_header_bar_new*(): GtkWidget
proc gtk_header_bar_set_show_title_buttons*(headerBar: GtkWidget, show: cbool)
proc gtk_header_bar_pack_start*(headerBar, child: GtkWidget)
proc gtk_header_bar_pack_end*(headerBar, child: GtkWidget)
proc gtk_header_bar_remove*(headerBar, child: GtkWidget)
proc gtk_header_bar_set_title_widget*(headerBar, child: GtkWidget)


# Gtk.Adjustment
proc gtk_adjustment_new*(value, lower, upper, stepIncrement, pageIncrement, pageSize: cdouble): GtkAdjustment
proc gtk_adjustment_set_value*(adjustment: GtkAdjustment, value: cdouble)
proc gtk_adjustment_set_lower*(adjustment: GtkAdjustment, value: cdouble)
proc gtk_adjustment_set_upper*(adjustment: GtkAdjustment, value: cdouble)
proc gtk_adjustment_set_step_increment*(adjustment: GtkAdjustment, value: cdouble)
proc gtk_adjustment_set_page_increment*(adjustment: GtkAdjustment, value: cdouble)
proc gtk_adjustment_set_page_size*(adjustment: GtkAdjustment, value: cdouble)

# Gtk.ScrolledWindow
proc gtk_scrolled_window_new*(hAdjustment, vAdjustment: GtkAdjustment): GtkWidget
proc gtk_scrolled_window_get_hadjustment*(window: GtkWidget): GtkAdjustment
proc gtk_scrolled_window_get_vadjustment*(window: GtkWidget): GtkAdjustment
proc gtk_scrolled_window_set_child*(window, child: GtkWidget)

# Gtk.IconTheme
proc gtk_icon_theme_new*(): GtkIconTheme
proc gtk_icon_theme_get_for_display*(display: GdkDisplay): GtkIconTheme
proc gtk_icon_theme_append_resource_path*(theme: GtkIconTheme, path: cstring)
proc gtk_icon_theme_add_search_path*(theme: GtkIconTheme, path: cstring)

# Gtk.Image
proc gtk_image_new*(): GtkWidget
proc gtk_image_set_from_icon_name*(image: GtkWidget, iconName: cstring, size: GtkIconSize)
proc gtk_image_set_pixel_size*(image: GtkWidget, pixelSize: cint)
proc gtk_image_set_from_pixbuf*(image: GtkWidget, pixbuf: GdkPixbuf)

# Gtk.Picture
proc gtk_picture_new*(): GtkWidget
proc gtk_picture_set_pixbuf*(picture: GtkWidget, pixbuf: GdkPixbuf)
when defined(gtk48):
  proc gtk_picture_set_content_fit*(picture: GtkWidget, fit: GtkContentFit)
else:
  proc gtk_picture_set_keep_aspect_ratio*(picture: GtkWidget, keep: cbool)

# Gtk.Paned
proc gtk_paned_new*(orientation: GtkOrientation): GtkWidget
proc gtk_paned_set_start_child*(paned, child: GtkWidget)
proc gtk_paned_set_shrink_start_child*(paned: GtkWidget, shrink: cbool)
proc gtk_paned_set_resize_start_child*(paned: GtkWidget, resize: cbool)
proc gtk_paned_set_end_child*(paned, child: GtkWidget)
proc gtk_paned_set_shrink_end_child*(paned: GtkWidget, shrink: cbool)
proc gtk_paned_set_resize_end_child*(paned: GtkWidget, resize: cbool)
proc gtk_paned_set_position*(paned: GtkWidget, pos: cint)

# Gtk.DrawingArea
proc gtk_drawing_area_new*(): GtkWidget
proc gtk_drawing_area_set_draw_func*(widget: GtkWidget,
                                     drawFunc: GtkDrawingAreaDrawFunc,
                                     data: pointer,
                                     destroy: GDestroyNotify)

# Gtk.Native
proc gtk_native_get_surface_transform*(native: GtkWidget, x, y: ptr cdouble)

# Gtk.EventController
proc gtk_event_controller_get_widget*(cont: GtkEventController): GtkWidget

# Gtk.EventControllerLegacy
proc gtk_event_controller_legacy_new*(): GtkEventController

# Gtk.GestureSingle
proc gtk_gesture_single_set_button*(gesture: GtkEventController, button: cuint)

# Gtk.GestureClick
proc gtk_gesture_click_new*(): GtkEventController

# Gtk.ShortcutController
proc gtk_shortcut_controller_new*(): GtkEventController
proc gtk_shortcut_controller_add_shortcut*(cont: GtkEventController, shortcut: GtkShortcut)
proc gtk_shortcut_controller_get_scope*(cont: GtkEventController): GtkShortcutScope
proc gtk_shortcut_controller_set_scope*(cont: GtkEventController, scope: GtkShortcutScope)

# Gtk.ShortcutTrigger
proc gtk_shortcut_trigger_parse_string*(str: cstring): GtkShortcutTrigger

# Gtk.ShortcutAction
proc gtk_shortcut_action_parse_string*(str: cstring): GtkShortcutAction

# Gtk.Shortcut
proc gtk_shortcut_new*(trigger: GtkShortcutTrigger, action: GtkShortcutAction): GtkShortcut

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
proc gtk_switch_set_active*(widget: GtkWidget, state: cbool)

# Gtk.ToggleButton
proc gtk_toggle_button_new*(): GtkWidget
proc gtk_toggle_button_set_active*(widget: GtkWidget, state: cbool)
proc gtk_toggle_button_get_active*(widget: GtkWidget): cbool

# Gtk.LinkButton
proc gtk_link_button_new*(uri: cstring): GtkWidget
proc gtk_link_button_set_uri*(button: GtkWidget, uri: cstring)
proc gtk_link_button_set_visited*(button: GtkWidget, visited: cbool)

# Gtk.CheckButton
proc gtk_check_button_new*(): GtkWidget
proc gtk_check_button_set_active*(widget: GtkWidget, state: cbool)
proc gtk_check_button_get_active*(widget: GtkWidget): cbool
proc gtk_check_button_set_group*(widget, group: GtkWidget)

# Gtk.Popover
proc gtk_popover_new*(relativeTo: GtkWidget): GtkWidget
proc gtk_popover_popup*(popover: GtkWidget)
proc gtk_popover_popdown*(popover: GtkWidget)
proc gtk_popover_present*(popover: GtkWidget)
proc gtk_popover_set_child*(popover, child: GtkWidget)
proc gtk_popover_get_child*(popover: GtkWidget): GtkWidget
proc gtk_popover_set_has_arrow*(popover: GtkWidget, hasArrow: cbool)
proc gtk_popover_set_offset*(popover: GtkWidget, x, y: cint)
proc gtk_popover_set_position*(popover: GtkWidget, pos: GtkPositionType)
proc gtk_popover_set_pointing_to*(popover: GtkWidget, rect: ptr GdkRectangle)

# Gtk.PopoverMenu
proc gtk_popover_menu_new_from_model*(model: pointer): GtkWidget
proc gtk_popover_menu_remove_child*(popover, child: GtkWidget)
proc gtk_popover_menu_add_child*(popover, child: GtkWidget, id: cstring)

# Gtk.Stack
proc gtk_stack_add_named*(stack, child: GtkWidget, name: cstring)
proc gtk_stack_remove*(stack, child: GtkWidget)

# Gtk.MenuButton
proc gtk_menu_button_new*(): GtkWidget
proc gtk_menu_button_set_child*(button, child: GtkWidget)
proc gtk_menu_button_set_popover*(button, popover: GtkWidget)

# Gtk.Separator
proc gtk_separator_new*(orient: GtkOrientation): GtkWidget


# Gtk.TextBuffer
proc gtk_text_buffer_new*(tagTable: GtkTextTagTable): GtkTextBuffer
proc gtk_text_buffer_get_line_count*(buffer: GtkTextBuffer): cint
proc gtk_text_buffer_get_char_count*(buffer: GtkTextBuffer): cint
proc gtk_text_buffer_get_modified*(buffer: GtkTextBuffer): cbool
proc gtk_text_buffer_get_can_redo*(buffer: GtkTextBuffer): cbool
proc gtk_text_buffer_get_can_undo*(buffer: GtkTextBuffer): cbool
proc gtk_text_buffer_redo*(buffer: GtkTextBuffer)
proc gtk_text_buffer_undo*(buffer: GtkTextBuffer)
proc gtk_text_buffer_get_has_selection*(buffer: GtkTextBuffer): cbool
proc gtk_text_buffer_get_selection_bounds*(buffer: GtkTextBuffer, a, b: ptr GtkTextIter): cbool
proc gtk_text_buffer_insert*(buffer: GtkTextBuffer, iter: ptr GtkTextIter, text: cstring, len: cint)
proc gtk_text_buffer_delete*(buffer: GtkTextBuffer, a, b: ptr GtkTextIter)
proc gtk_text_buffer_set_text*(buffer: GtkTextBuffer, text: cstring, len: cint)
proc gtk_text_buffer_get_text*(buffer: GtkTextBuffer,
                               a, b: ptr GtkTextIter,
                               includeHiddenChars: cbool): cstring
proc gtk_text_buffer_begin_user_action*(buffer: GtkTextBuffer)
proc gtk_text_buffer_end_user_action*(buffer: GtkTextBuffer)
proc gtk_text_buffer_get_start_iter*(buffer: GtkTextBuffer, iter: ptr GtkTextIter)
proc gtk_text_buffer_get_end_iter*(buffer: GtkTextBuffer, iter: ptr GtkTextIter)
proc gtk_text_buffer_get_iter_at_line*(buffer: GtkTextBuffer, iter: ptr GtkTextIter, line: cint)
proc gtk_text_buffer_get_iter_at_offset*(buffer: GtkTextBuffer, iter: ptr GtkTextIter, offset: cint)
proc gtk_text_buffer_create_tag*(buffer: GtkTextBuffer, name: cstring): GtkTextTag {.varargs.}
proc gtk_text_buffer_apply_tag*(buffer: GtkTextBuffer, tag: GtkTextTag, a, b: ptr GtkTextIter)
proc gtk_text_buffer_apply_tag_by_name*(buffer: GtkTextBuffer, name: cstring, a, b: ptr GtkTextIter)
proc gtk_text_buffer_remove_tag*(buffer: GtkTextBuffer, tag: GtkTextTag, a, b: ptr GtkTextIter)
proc gtk_text_buffer_remove_all_tags*(buffer: GtkTextBuffer, a, b: ptr GtkTextIter)
proc gtk_text_buffer_remove_tag_by_name*(buffer: GtkTextBuffer, name: cstring, a, b: ptr GtkTextIter)
proc gtk_text_buffer_place_cursor*(buffer: GtkTextBuffer, pos: ptr GtkTextIter)
proc gtk_text_buffer_select_range*(buffer: GtkTextBuffer, insert, other: ptr GtkTextIter)
proc gtk_text_buffer_get_tag_table*(buffer: GtkTextBuffer): GtkTextTagTable

# Gtk.TextIter
proc gtk_text_iter_equal*(a, b: ptr GtkTextIter): cbool
proc gtk_text_iter_compare*(a, b: ptr GtkTextIter): cint
proc gtk_text_iter_in_range*(iter, a, b: ptr GtkTextIter): cbool

proc gtk_text_iter_has_tag*(iter: ptr GtkTextIter, tag: GtkTextTag): cbool
proc gtk_text_iter_starts_tag*(iter: ptr GtkTextIter, tag: GtkTextTag): cbool
proc gtk_text_iter_ends_tag*(iter: ptr GtkTextIter, tag: GtkTextTag): cbool

proc gtk_text_iter_is_start*(iter: ptr GtkTextIter): cbool
proc gtk_text_iter_is_end*(iter: ptr GtkTextIter): cbool
proc gtk_text_iter_can_insert*(iter: ptr GtkTextIter): cbool

proc gtk_text_iter_forward_chars*(iter: ptr GtkTextIter, count: cint): cbool
proc gtk_text_iter_forward_line*(iter: ptr GtkTextIter): cbool
proc gtk_text_iter_forward_to_line_end*(iter: ptr GtkTextIter): cbool
proc gtk_text_iter_forward_to_tag_toggle*(iter: ptr GtkTextIter, tag: GtkTextTag): cbool
proc gtk_text_iter_backward_chars*(iter: ptr GtkTextIter, count: cint): cbool
proc gtk_text_iter_backward_line*(iter: ptr GtkTextIter): cbool
proc gtk_text_iter_backward_to_tag_toggle*(iter: ptr GtkTextIter, tag: GtkTextTag): cbool

proc gtk_text_iter_get_offset*(iter: ptr GtkTextIter): cint
proc gtk_text_iter_get_line*(iter: ptr GtkTextIter): cint
proc gtk_text_iter_get_line_offset*(iter: ptr GtkTextIter): cint
proc gtk_text_iter_set_offset*(iter: ptr GtkTextIter, value: cint)
proc gtk_text_iter_set_line*(iter: ptr GtkTextIter, value: cint)
proc gtk_text_iter_set_line_offset*(iter: ptr GtkTextIter, value: cint)

# Gtk.TextTagTable
proc gtk_text_tag_table_remove*(tab: GtkTextTagTable, tag: GtkTextTag)
proc gtk_text_tag_table_lookup*(tab: GtkTextTagTable, name: cstring): GtkTextTag

# Gtk.TextView
proc gtk_text_view_new*(): GtkWidget
proc gtk_text_view_set_buffer*(textView: GtkWidget, buffer: GtkTextBuffer)
proc gtk_text_view_set_monospace*(textView: GtkWidget, monospace: cbool)
proc gtk_text_view_set_cursor_visible*(textView: GtkWidget, isVisible: cbool)
proc gtk_text_view_set_editable*(textView: GtkWidget, editable: cbool)
proc gtk_text_view_set_accepts_tab*(textView: GtkWidget, acceptsTab: cbool)
proc gtk_text_view_set_indent*(textView: GtkWidget, indent: cint)

# Gtk.ListBox
proc gtk_list_box_new*(): GtkWidget
proc gtk_list_box_set_selection_mode*(listBox: GtkWidget, mode: GtkSelectionMode)
proc gtk_list_box_get_selected_rows*(listBox: GtkWidget): GList
proc gtk_list_box_select_row*(listBox, row: GtkWidget)
proc gtk_list_box_unselect_row*(listBox, row: GtkWidget)
proc gtk_list_box_append*(listBox, row: GtkWidget)
proc gtk_list_box_insert*(listBox, row: GtkWidget, pos: cint)
proc gtk_list_box_remove*(listBox, row: GtkWidget)

# Gtk.ListBoxRow
proc gtk_list_box_row_new*(): GtkWidget
proc gtk_list_box_row_get_index*(row: GtkWidget): cint
proc gtk_list_box_row_is_selected*(row: GtkWidget): cbool
proc gtk_list_box_row_set_child*(row, child: GtkWidget)

# Gtk.FlowBox
proc gtk_flow_box_new*(): GtkWidget
proc gtk_flow_box_insert*(flowBox, child: GtkWidget, pos: cint)
proc gtk_flow_box_append*(flowBox, child: GtkWidget)
proc gtk_flow_box_remove*(flowBox, child: GtkWidget)
proc gtk_flow_box_set_homogeneous*(flowBox: GtkWidget, homogeneous: cbool)
proc gtk_flow_box_set_row_spacing*(flowBox: GtkWidget, spacing: cuint)
proc gtk_flow_box_set_column_spacing*(flowBox: GtkWidget, spacing: cuint)
proc gtk_flow_box_set_selection_mode*(flowBox: GtkWidget, mode: GtkSelectionMode)
proc gtk_flow_box_set_min_children_per_line*(flowBox: GtkWidget, count: cuint)
proc gtk_flow_box_set_max_children_per_line*(flowBox: GtkWidget, count: cuint)

# Gtk.FlowBoxChild
proc gtk_flow_box_child_new*(): GtkWidget
proc gtk_flow_box_child_set_child*(flowBoxChild, child: GtkWidget)

# Gtk.Frame
proc gtk_frame_new*(label: cstring): GtkWidget
proc gtk_frame_set_label*(frame: GtkWidget, label: cstring)
proc gtk_frame_set_label_align*(frame: GtkWidget, x, y: cfloat)
proc gtk_frame_set_shadow_type*(frame: GtkWidget, shadow: GtkShadowType)
proc gtk_frame_set_child*(frame, child: GtkWidget)

# Gtk.GLArea
proc gtk_gl_area_new*(): GtkWidget
proc gtk_gl_area_make_current*(area: GtkWidget)
proc gtk_gl_area_set_has_stencil_buffer*(area: GtkWidget, value: cbool)
proc gtk_gl_area_set_has_depth_buffer*(area: GtkWidget, value: cbool)
proc gtk_gl_area_set_required_version*(area: GtkWidget, major, minor: cint)
proc gtk_gl_area_set_use_es*(area: GtkWidget, useEs: cbool)
proc gtk_gl_area_queue_render*(area: GtkWidget)
proc gtk_gl_area_get_error*(area: GtkWidget): GError

# Gtk.Dialog
proc gtk_dialog_new*(): GtkWidget
proc gtk_dialog_new_with_buttons*(title: cstring,
                                  parent: GtkWidget,
                                  flags: GtkDialogFlags,
                                  firstBtn: cstring): GtkWidget {.varargs.}
proc gtk_dialog_response*(dialog: GtkWidget, response: cint)
proc gtk_dialog_add_button*(dialog: GtkWidget, text: cstring, response: cint): GtkWidget
proc gtk_dialog_get_header_bar*(dialog: GtkWidget): GtkWidget

# Gtk.FileChooser
proc gtk_file_chooser_get_file*(fileChooser: GtkWidget): GFile
proc gtk_file_chooser_get_files*(fileChooser: GtkWidget): GListModel
proc gtk_file_chooser_set_select_multiple*(fileChooser: GtkWidget, select: cbool)
proc gtk_file_chooser_set_current_folder*(fileChooser: GtkWidget, folder: GFile, error: ptr GError): cbool

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

# Gtk.StringList
proc gtk_string_list_new*(strings: cstringArray): GListModel

# Gtk.StringObject
proc gtk_string_object_get_string*(stringObject: GtkStringObject): cstring

# Gtk.Expression
proc gtk_expression_unref*(expr: GtkExpression)
proc gtk_cclosure_expression_new*(typ: GType,
                                  marshal: GClosureMarshal,
                                  paramCount: cuint,
                                  params: ptr UncheckedArray[GtkExpression],
                                  callback: GCallback,
                                  data: pointer,
                                  destroy: GClosureNotify): GtkExpression

# Gtk.DropDown
proc gtk_drop_down_new*(model: GListModel, expr: pointer): GtkWidget
proc gtk_drop_down_set_model*(dropDown: GtkWidget, model: GListModel)
proc gtk_drop_down_set_enable_search*(dropDown: GtkWidget, enabled: cbool)
proc gtk_drop_down_set_selected*(dropDown: GtkWidget, selected: cuint)
proc gtk_drop_down_get_selected*(dropDown: GtkWidget): cuint
proc gtk_drop_down_set_show_arrow*(dropDown: GtkWidget, showArrow: cbool)
proc gtk_drop_down_set_expression*(dropDown: GtkWidget, expression: GtkExpression)

# Gtk.Grid
proc gtk_grid_new*(): GtkWidget
proc gtk_grid_attach*(grid, child: GtkWidget,
                      x, y, w, h: cint)
proc gtk_grid_remove*(grid, child: GtkWidget)
proc gtk_grid_set_row_homogeneous*(grid: GtkWidget, homogeneous: cbool)
proc gtk_grid_set_column_homogeneous*(grid: GtkWidget, homogeneous: cbool)
proc gtk_grid_set_row_spacing*(grid: GtkWidget, spacing: cuint)
proc gtk_grid_set_column_spacing*(grid: GtkWidget, spacing: cuint)

# Gtk.Calendar
proc gtk_calendar_new*(): GtkWidget
proc gtk_calendar_set_show_day_names*(widget: GtkWidget, show: cbool)
proc gtk_calendar_set_show_heading*(widget: GtkWidget, show: cbool)
proc gtk_calendar_set_show_week_numbers*(widget: GtkWidget, show: cbool)
proc gtk_calendar_select_day*(widget: GtkWidget, date: GDateTime)
proc gtk_calendar_get_date*(widget: GtkWidget): GDateTime
proc gtk_calendar_clear_marks*(widget: GtkWidget)
proc gtk_calendar_mark_day*(widget: GtkWidget, day: cuint)

# Gtk.Spinner
proc gtk_spinner_new*(): GtkWidget
proc gtk_spinner_set_spinning*(widget: GtkWidget, spinning: cbool)

# Gtk.SpinButton
proc gtk_spin_button_new*(adjustment: GtkAdjustment, climbRate: cdouble, digits: cuint): GtkWidget
proc gtk_spin_button_get_adjustment*(widget: GtkWidget): GtkAdjustment
proc gtk_spin_button_set_value*(widget: GtkWidget, value: cdouble)
proc gtk_spin_button_get_value*(widget: GtkWidget): cdouble
proc gtk_spin_button_set_digits*(widget: GtkWidget, digits: cuint)
proc gtk_spin_button_set_wrap*(widget: GtkWidget, digits: cbool)
proc gtk_spin_button_set_climb_rate*(widget: GtkWidget, digits: cdouble)

# Gtk.Fixed
proc gtk_fixed_new*(): GtkWidget
proc gtk_fixed_put*(widget, child: GtkWidget, x, y: cdouble)
proc gtk_fixed_move*(widget, child: GtkWidget, x, y: cdouble)
proc gtk_fixed_remove*(widget, child: GtkWidget)
{.pop.}

{.push hint[Name]: off.}
proc g_value_new*(str: string): GValue =
  discard g_value_init(result.addr, G_TYPE_STRING)
  g_value_set_string(result.addr, str.cstring)

proc g_value_new*(value: char): GValue =
  discard g_value_init(result.addr, G_TYPE_CHAR)
  g_value_set_char(result.addr, cchar(value))

proc g_value_new*(value: uint8): GValue =
  discard g_value_init(result.addr, G_TYPE_UCHAR)
  g_value_set_uchar(result.addr, value)

proc g_value_new*(value: int): GValue =
  discard g_value_init(result.addr, G_TYPE_INT)
  g_value_set_int(result.addr, cint(value))

proc g_value_new*(value: uint): GValue =
  discard g_value_init(result.addr, G_TYPE_UINT)
  g_value_set_uint(result.addr, cuint(value))

proc g_value_new*(value: bool): GValue =
  discard g_value_init(result.addr, G_TYPE_BOOLEAN)
  g_value_set_boolean(result.addr, cbool(ord(value)))

proc g_value_new*(icon: GIcon): GValue =
  discard g_value_init(result.addr, g_type_from_name("GIcon"))
  g_value_set_object(result.addr, pointer(icon))

proc g_signal_connect*(widget: GtkEventController, signal: cstring, closure, data: pointer): culong =
  result = g_signal_connect_data(widget.pointer, signal, closure, data, nil, G_CONNECT_AFTER)

proc g_signal_connect*(widget: GtkWidget, signal: cstring, closure, data: pointer): culong =
  result = g_signal_connect_data(widget.pointer, signal, closure, data, nil, G_CONNECT_AFTER)

proc g_signal_connect*(app: GApplication, signal: cstring, closure, data: pointer): culong =
  result = g_signal_connect_data(app.pointer, signal, closure, data, nil, G_CONNECT_AFTER)
{.pop.}

template withCArgs(argc, argv, body: untyped) =
  block:
    var args: seq[string] = @[]
    for it in 0..paramCount():
      args.add(paramStr(it))
    var
      argc = cint(paramCount() + 1)
      argv = allocCStringArray(args)
    defer: argv.deallocCStringArray()
    body

iterator items*(model: GListModel): pointer =
  let count = g_list_model_get_n_items(model)
  for it in 0..<count:
    yield g_list_model_get_item(model, it)

{.push hint[Name]: off}
proc g_application_run*(app: GApplication): cint =
  withCArgs argc, argv:
    result = g_application_run(app, argc, argv)
{.pop.}
