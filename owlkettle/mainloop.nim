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

import gtk, widgetdef

type AppConfig* = object
  widget*: Widget
  icons*: seq[string]
  dark_theme*: bool
  stylesheets*: seq[string]

proc setup_app*(config: AppConfig): WidgetState =
  if config.dark_theme:
    let settings = gtk_settings_get_default()
    var value = g_value_new(config.dark_theme)
    g_object_set_property(settings.pointer, "gtk-application-prefer-dark-theme", value.addr)
    g_value_unset(value.addr)
  
  let display = gdk_display_get_default()
  let icon_theme = gtk_icon_theme_get_for_display(display)
  for path in config.icons:
    gtk_icon_theme_add_search_path(icon_theme, path.cstring)
  result = config.widget.build()
  
  for stylesheet in config.stylesheets:
    var error: GError
    let provider = gtk_css_provider_new()
    discard gtk_css_provider_load_from_path(provider, stylesheet.cstring, error.addr)
    if not error.is_nil:
      raise new_exception(IoError, $error[].message)
    gtk_style_context_add_provider_for_display(display, provider, 600)

proc run_mainloop*(state: WidgetState) =
  gtk_window_present(state.unwrap_internal_widget())
  while g_list_model_get_n_items(gtk_window_get_toplevels()) > 0:
    discard g_main_context_iteration(nil, cbool(ord(true)))
