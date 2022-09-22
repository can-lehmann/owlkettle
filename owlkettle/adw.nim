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

# Create libadwaita apps using owlkettle

import gtk, widgetdef, widgets, mainloop

{.passl: "-ladwaita-1".}

type
  StyleManager = distinct pointer
  
  ColorScheme* = enum
    ColorSchemeDefault,
    ColorSchemeForceLight,
    ColorSchemeForceDark,
    ColorSchemePreferDark,
    ColorSchemePreferLight

{.push importc, cdecl.}
# Adw
proc adw_init()

# Adw.StyleManager
proc adw_style_manager_get_default(): StyleManager
proc adw_style_manager_set_color_scheme(manager: StyleManager, color_scheme: ColorScheme)

# Adw.WindowTitle
proc adw_window_title_new(title, subtitle: cstring): GtkWidget
proc adw_window_title_set_title(widget: GtkWidget, title: cstring)
proc adw_window_title_set_subtitle(widget: GtkWidget, subtitle: cstring)

# Adw.Avatar
proc adw_avatar_new(size: cint, text: cstring, show_initials: cbool): GtkWidget
proc adw_avatar_set_show_initials(avatar: GtkWidget, value: cbool)
proc adw_avatar_set_size(avatar: GtkWidget, size: cint)
proc adw_avatar_set_text(avatar: GtkWidget, text: cstring)
proc adw_avatar_set_icon_name(avatar: GtkWidget, icon_name: cstring)

# Adw.Clamp
proc adw_clamp_new(): GtkWidget
proc adw_clamp_set_child(clamp, child: GtkWidget)
proc adw_clamp_set_maximum_size(clamp: GtkWidget, size: cint)

# Adw.PreferencesGroup
proc adw_preferences_group_new(): GtkWidget
proc adw_preferences_group_add(group, child: GtkWidget)
proc adw_preferences_group_remove(group, child: GtkWidget)
proc adw_preferences_group_set_header_suffix(group, child: GtkWidget)
proc adw_preferences_group_set_description(group: GtkWidget, descr: cstring)
proc adw_preferences_group_set_title(group: GtkWidget, title: cstring)

# Adw.PreferencesRow
proc adw_preferences_row_new(): GtkWidget
proc adw_preferences_row_set_title(row: GtkWidget, title: cstring)

# Adw.ActionRow
proc adw_action_row_new(): GtkWidget
proc adw_action_row_set_subtitle(row: GtkWidget, subtitle: cstring)
proc adw_action_row_add_prefix(row, child: GtkWidget)
proc adw_action_row_add_suffix(row, child: GtkWidget)
proc adw_action_row_remove(row, child: GtkWidget)
proc adw_action_row_set_activatable_widget(row, child: GtkWidget)
{.pop.}

renderable WindowTitle of BaseWidget:
  title: string
  subtitle: string
  
  hooks:
    before_build:
      state.internal_widget = adw_window_title_new(cstring(""), cstring(""))
  
  hooks title:
    property:
      adw_window_title_set_title(state.internal_widget, state.title.cstring)
  
  hooks subtitle:
    property:
      adw_window_title_set_subtitle(state.internal_widget, state.subtitle.cstring)

renderable Avatar of BaseWidget:
  text: string
  size: int
  show_initials: bool
  icon_name: string = "avatar-default-symbolic"
  
  hooks:
    before_build:
      state.internal_widget = adw_avatar_new(
        widget.val_size.cint,
        widget.val_text.cstring,
        widget.val_show_initials.ord.cbool
      )
  
  hooks text:
    property:
      adw_avatar_set_text(state.internal_widget, state.text.cstring)
  
  hooks size:
    property:
      adw_avatar_set_size(state.internal_widget, state.size.cint)
  
  hooks show_initials:
    property:
      adw_avatar_set_show_initials(state.internal_widget, state.show_initials.ord.cbool)
  
  hooks icon_name:
    property:
      adw_avatar_set_icon_name(state.internal_widget, state.icon_name.cstring)

renderable Clamp of BaseWidget:
  maximum_size: int
  child: Widget
  
  hooks:
    before_build:
      state.internal_widget = adw_clamp_new()
  
  hooks maximum_size:
    property:
      adw_clamp_set_maximum_size(state.internal_widget, cint(state.maximum_size))
  
  hooks child:
    build: build_bin(state, widget, adw_clamp_set_child)
    update: update_bin(state, widget, adw_clamp_set_child)
  
  adder add

proc add*(clamp: Clamp, child: Widget) =
  if clamp.has_child:
    raise new_exception(ValueError, "Unable to add multiple children to a Clamp. Use a Box widget to display multiple widgets in a Clamp.")
  clamp.has_child = true
  clamp.val_child = child

renderable PreferencesGroup of BaseWidget:
  title: string
  description: string
  children: seq[Widget]
  suffix: Widget
  
  hooks:
    before_build:
      state.internal_widget = adw_preferences_group_new()
  
  hooks title:
    property:
      adw_preferences_group_set_title(state.internal_widget, state.title.cstring)
  
  hooks description:
    property:
      adw_preferences_group_set_description(state.internal_widget, state.description.cstring)
  
  hooks suffix:
    build: build_bin(state, widget, suffix, has_suffix, val_suffix, adw_preferences_group_set_header_suffix)
    update: update_bin(state, widget, suffix, has_suffix, val_suffix, adw_preferences_group_set_header_suffix)
  
  hooks children:
    build:
      widget.val_children.assign_app(state.app)
      for child_widget in widget.val_children:
        let child = child_widget.build()
        adw_preferences_group_add(state.internal_widget, child.unwrap_internal_widget())
        state.children.add(child)
    update:
      widget.val_children.assign_app(state.app)
      var
        it = 0
        force_readd = false
      while it < widget.val_children.len and it < state.children.len:
        let new_child = widget.val_children[it].update(state.children[it])
        if not new_child.is_nil:
          adw_preferences_group_remove(state.internal_widget, state.children[it].unwrap_internal_widget())
          adw_preferences_group_add(state.internal_widget, new_child.unwrap_internal_widget())
          state.children[it] = new_child
          force_readd = true
        elif force_readd:
          let widget = state.children[it].unwrap_internal_widget()
          adw_preferences_group_remove(state.internal_widget, widget)
          adw_preferences_group_add(state.internal_widget, widget)
        it += 1
      
      while it < widget.val_children.len:
        let child = widget.val_children[it].build()
        adw_preferences_group_add(state.internal_widget, child.unwrap_internal_widget())
        state.children.add(child)
        it += 1
      
      while it < state.children.len:
        let child = state.children.pop()
        adw_preferences_group_remove(state.internal_widget, child.unwrap_internal_widget())
  
  adder add
  adder add_suffix

proc add_suffix*(group: PreferencesGroup, suffix: Widget) =
  if group.has_suffix:
    raise new_exception(ValueError, "Unable to add multiple suffixes to a PreferencesGroup. Use a Box widget to display multiple widgets in a PreferencesGroup.")
  group.has_suffix = true
  group.val_suffix = suffix

proc add*(group: PreferencesGroup, row: ListBoxRow) =
  group.has_children = true
  group.val_children.add(row)

renderable PreferencesRow of ListBoxRow:
  title: string
  
  hooks:
    before_build:
      state.internal_widget = adw_preferences_row_new()
  
  hooks title:
    property:
      adw_preferences_row_set_title(state.internal_widget, state.title.cstring)

renderable ActionRow of PreferencesRow:
  subtitle: string
  suffixes: seq[Widget]
  
  hooks:
    before_build:
      state.internal_widget = adw_action_row_new()
  
  hooks subtitle:
    property:
      adw_action_row_set_subtitle(state.internal_widget, state.subtitle.cstring)
  
  hooks suffixes:
    build:
      widget.val_suffixes.assign_app(state.app)
      for suffix_widget in widget.val_suffixes:
        let suffix = suffix_widget.build()
        adw_action_row_add_suffix(state.internal_widget, suffix.unwrap_internal_widget())
        state.suffixes.add(suffix)
    update:
      widget.val_suffixes.assign_app(state.app)
      var it = 0
      while it < widget.val_suffixes.len and it < state.suffixes.len:
        let new_suffix = widget.val_suffixes[it].update(state.suffixes[it])
        assert new_suffix.is_nil
        it += 1
      
      while it < widget.val_suffixes.len:
        let suffix = widget.val_suffixes[it].build()
        adw_action_row_add_suffix(state.internal_widget, suffix.unwrap_internal_widget())
        state.suffixes.add(suffix)
        it += 1
      
      while it < state.suffixes.len:
        let suffix = state.suffixes.pop()
        adw_action_row_remove(state.internal_widget, suffix.unwrap_internal_widget())

proc add_suffix*(row: ActionRow, suffix: Widget) =
  row.has_suffixes = true
  row.val_suffixes.add(suffix)

export WindowTitle, Avatar, Clamp, PreferencesGroup, PreferencesRow, ActionRow

proc brew*(widget: Widget,
           icons: openArray[string] = [],
           color_scheme: ColorScheme = ColorSchemeDefault,
           stylesheets: openArray[string] = []) =
  adw_init()
  let style_manager = adw_style_manager_get_default()
  adw_style_manager_set_color_scheme(style_manager, color_scheme)
  let state = setup_app(AppConfig(
    widget: widget,
    icons: @icons,
    dark_theme: false,
    stylesheets: @stylesheets
  ))
  run_mainloop(state)
