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

import owlkettle/[gtk, widgetdef, widgets, guidsl]
export widgetdef, widgets, guidsl

proc open*(app: Viewable, widget: Dialog): tuple[res: DialogResponse, state: WidgetState] =
  let
    state = DialogState(widget.build())
    window = app.unwrap_renderable().internal_widget
    dialog = state.unwrap_renderable().internal_widget
  gtk_window_set_transient_for(dialog, window)
  let res = gtk_dialog_run(dialog)
  state.read()
  gtk_widget_destroy(dialog)
  result = (to_dialog_response(res), state)

proc brew*(widget: Widget, icons: openArray[string] = []) =
  gtk_init()
  let icon_theme = gtk_icon_theme_get_default()
  for path in icons:
    gtk_icon_theme_append_search_path(icon_theme, path.cstring)
  let state = widget.build()
  gtk_main()
