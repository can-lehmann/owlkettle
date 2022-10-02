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
proc adw_style_manager_set_color_scheme(manager: StyleManager, colorScheme: ColorScheme)

# Adw.WindowTitle
proc adw_window_title_new(title, subtitle: cstring): GtkWidget
proc adw_window_title_set_title(widget: GtkWidget, title: cstring)
proc adw_window_title_set_subtitle(widget: GtkWidget, subtitle: cstring)

# Adw.Avatar
proc adw_avatar_new(size: cint, text: cstring, showInitials: cbool): GtkWidget
proc adw_avatar_set_show_initials(avatar: GtkWidget, value: cbool)
proc adw_avatar_set_size(avatar: GtkWidget, size: cint)
proc adw_avatar_set_text(avatar: GtkWidget, text: cstring)
proc adw_avatar_set_icon_name(avatar: GtkWidget, iconName: cstring)

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
      state.internalWidget = adw_window_title_new(cstring(""), cstring(""))
  
  hooks title:
    property:
      adw_window_title_set_title(state.internalWidget, state.title.cstring)
  
  hooks subtitle:
    property:
      adw_window_title_set_subtitle(state.internalWidget, state.subtitle.cstring)

renderable Avatar of BaseWidget:
  text: string
  size: int
  showInitials: bool
  iconName: string = "avatar-default-symbolic"
  
  hooks:
    before_build:
      state.internalWidget = adw_avatar_new(
        widget.valSize.cint,
        widget.valText.cstring,
        widget.valShow_initials.ord.cbool
      )
  
  hooks text:
    property:
      adw_avatar_set_text(state.internalWidget, state.text.cstring)
  
  hooks size:
    property:
      adw_avatar_set_size(state.internalWidget, state.size.cint)
  
  hooks showInitials:
    property:
      adw_avatar_set_show_initials(state.internalWidget, state.showInitials.ord.cbool)
  
  hooks iconName:
    property:
      adw_avatar_set_icon_name(state.internalWidget, state.iconName.cstring)

renderable Clamp of BaseWidget:
  maximumSize: int
  child: Widget
  
  hooks:
    before_build:
      state.internalWidget = adw_clamp_new()
  
  hooks maximumSize:
    property:
      adw_clamp_set_maximum_size(state.internalWidget, cint(state.maximumSize))
  
  hooks child:
    build: buildBin(state, widget, adw_clamp_set_child)
    update: updateBin(state, widget, adw_clamp_set_child)
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a Clamp. Use a Box widget to display multiple widgets in a Clamp.")
    widget.hasChild = true
    widget.valChild = child

renderable PreferencesGroup of BaseWidget:
  title: string
  description: string
  children: seq[Widget]
  suffix: Widget
  
  hooks:
    before_build:
      state.internalWidget = adw_preferences_group_new()
  
  hooks title:
    property:
      adw_preferences_group_set_title(state.internalWidget, state.title.cstring)
  
  hooks description:
    property:
      adw_preferences_group_set_description(state.internalWidget, state.description.cstring)
  
  hooks suffix:
    build: buildBin(state, widget, suffix, hasSuffix, valSuffix, adw_preferences_group_set_header_suffix)
    update: updateBin(state, widget, suffix, hasSuffix, valSuffix, adw_preferences_group_set_header_suffix)
  
  hooks children:
    build:
      widget.valChildren.assignApp(state.app)
      for childWidget in widget.valChildren:
        let child = childWidget.build()
        adw_preferences_group_add(state.internalWidget, child.unwrapInternalWidget())
        state.children.add(child)
    update:
      widget.valChildren.assignApp(state.app)
      var
        it = 0
        forceReadd = false
      while it < widget.valChildren.len and it < state.children.len:
        let newChild = widget.valChildren[it].update(state.children[it])
        if not newChild.isNil:
          adw_preferences_group_remove(state.internalWidget, state.children[it].unwrapInternalWidget())
          adw_preferences_group_add(state.internalWidget, newChild.unwrapInternalWidget())
          state.children[it] = newChild
          forceReadd = true
        elif forceReadd:
          let widget = state.children[it].unwrapInternalWidget()
          adw_preferences_group_remove(state.internalWidget, widget)
          adw_preferences_group_add(state.internalWidget, widget)
        it += 1
      
      while it < widget.valChildren.len:
        let child = widget.valChildren[it].build()
        adw_preferences_group_add(state.internalWidget, child.unwrapInternalWidget())
        state.children.add(child)
        it += 1
      
      while it < state.children.len:
        let child = state.children.pop()
        adw_preferences_group_remove(state.internalWidget, child.unwrapInternalWidget())
  
  adder add:
    widget.hasChildren = true
    widget.valChildren.add(child)
  
  adder addSuffix:
    if widget.hasSuffix:
      raise newException(ValueError, "Unable to add multiple suffixes to a PreferencesGroup. Use a Box widget to display multiple widgets in a PreferencesGroup.")
    widget.hasSuffix = true
    widget.valSuffix = child

renderable PreferencesRow of ListBoxRow:
  title: string
  
  hooks:
    before_build:
      state.internalWidget = adw_preferences_row_new()
  
  hooks title:
    property:
      adw_preferences_row_set_title(state.internalWidget, state.title.cstring)

renderable ActionRow of PreferencesRow:
  subtitle: string
  suffixes: seq[Widget]
  
  hooks:
    before_build:
      state.internalWidget = adw_action_row_new()
  
  hooks subtitle:
    property:
      adw_action_row_set_subtitle(state.internalWidget, state.subtitle.cstring)
  
  hooks suffixes:
    build:
      widget.valSuffixes.assignApp(state.app)
      for suffixWidget in widget.valSuffixes:
        let suffix = suffixWidget.build()
        adw_action_row_add_suffix(state.internalWidget, suffix.unwrapInternalWidget())
        state.suffixes.add(suffix)
    update:
      widget.valSuffixes.assignApp(state.app)
      var it = 0
      while it < widget.valSuffixes.len and it < state.suffixes.len:
        let newSuffix = widget.valSuffixes[it].update(state.suffixes[it])
        assert newSuffix.isNil
        it += 1
      
      while it < widget.valSuffixes.len:
        let suffix = widget.valSuffixes[it].build()
        adw_action_row_add_suffix(state.internalWidget, suffix.unwrapInternalWidget())
        state.suffixes.add(suffix)
        it += 1
      
      while it < state.suffixes.len:
        let suffix = state.suffixes.pop()
        adw_action_row_remove(state.internalWidget, suffix.unwrapInternalWidget())

  adder addSuffix:
    widget.hasSuffixes = true
    widget.valSuffixes.add(child)

export WindowTitle, Avatar, Clamp, PreferencesGroup, PreferencesRow, ActionRow

proc brew*(widget: Widget,
           icons: openArray[string] = [],
           colorScheme: ColorScheme = ColorSchemeDefault,
           stylesheets: openArray[string] = []) =
  adw_init()
  let styleManager = adw_style_manager_get_default()
  adw_style_manager_set_color_scheme(styleManager, colorScheme)
  let state = setupApp(AppConfig(
    widget: widget,
    icons: @icons,
    dark_theme: false,
    stylesheets: @stylesheets
  ))
  runMainloop(state)
