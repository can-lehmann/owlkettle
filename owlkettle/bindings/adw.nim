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

# Bindings for Adwaita

import ./gtk

const AdwMajor {.intdefine: "adwmajor".}: int = 1 ## Specifies the minimum Adwaita major version required to run an application. Overwriteable via `-d:adwmajor=X`. Defaults to 1.
const AdwMinor {.intdefine: "adwminor".}: int = 0 ## Specifies the minimum Adwaita minor version required to run an application. Overwriteable via `-d:adwinor=X`. Defaults to 0.
const AdwVersion* = (AdwMajor, AdwMinor)

{.passl: "-ladwaita-1".}

type
  StyleManager* = distinct pointer
  
  CenteringPolicy* = enum
    CenteringPolicyLoose
    CenteringPolicyStrict
  
  ColorScheme* = enum
    ColorSchemeDefault,
    ColorSchemeForceLight,
    ColorSchemeForceDark,
    ColorSchemePreferDark,
    ColorSchemePreferLight
  
  FlapFoldPolicy* = enum
    FlapFoldNever,
    FlapFoldAlways,
    FlapFoldAuto
  
  FoldThresholdPolicy* = enum
    FoldThresholdMinimum,
    FoldThresholdNatural
  
  FlapTransitionType* = enum
    FlapTransitionOver
    FlapTransitionUnder
    FlapTransitionSlide

{.push importc, cdecl.}
# Adw
proc adw_init*()

# Adw.Application
proc adw_application_new*(id: cstring, flags: GApplicationFlags): GApplication

# Adw.StyleManager
proc adw_style_manager_get_default*(): StyleManager
proc adw_style_manager_set_color_scheme*(manager: StyleManager, colorScheme: ColorScheme)

# Adw.Window
proc adw_window_new*(): GtkWidget
proc adw_window_set_content*(window, content: GtkWidget)

# Adw.WindowTitle
proc adw_window_title_new*(title, subtitle: cstring): GtkWidget
proc adw_window_title_set_title*(widget: GtkWidget, title: cstring)
proc adw_window_title_set_subtitle*(widget: GtkWidget, subtitle: cstring)

# Adw.Avatar
proc adw_avatar_new*(size: cint, text: cstring, showInitials: cbool): GtkWidget
proc adw_avatar_set_show_initials*(avatar: GtkWidget, value: cbool)
proc adw_avatar_set_size*(avatar: GtkWidget, size: cint)
proc adw_avatar_set_text*(avatar: GtkWidget, text: cstring)
proc adw_avatar_set_icon_name*(avatar: GtkWidget, iconName: cstring)

# Adw.ButtonContent
proc adw_button_content_new*(): GtkWidget
proc adw_button_content_set_icon_name*(self: GtkWidget, icon_name: cstring)
proc adw_button_content_set_label*(self: GtkWidget, label: cstring)
proc adw_button_content_set_use_underline*(self: GtkWidget, use_underline: cbool)
when AdwVersion >= (1, 4):
  proc adw_button_content_set_can_shrink*(self: GtkWidget, can_shrink: cbool)

# Adw.Clamp
proc adw_clamp_new*(): GtkWidget
proc adw_clamp_set_child*(clamp, child: GtkWidget)
proc adw_clamp_set_maximum_size*(clamp: GtkWidget, size: cint)

# Adw.PreferencesGroup
proc adw_preferences_group_new*(): GtkWidget
proc adw_preferences_group_add*(group, child: GtkWidget)
proc adw_preferences_group_remove*(group, child: GtkWidget)
proc adw_preferences_group_set_header_suffix*(group, child: GtkWidget)
proc adw_preferences_group_set_description*(group: GtkWidget, descr: cstring)
proc adw_preferences_group_set_title*(group: GtkWidget, title: cstring)

# Adw.PreferencesRow
proc adw_preferences_row_new*(): GtkWidget
proc adw_preferences_row_set_title*(row: GtkWidget, title: cstring)

# Adw.ActionRow
proc adw_action_row_new*(): GtkWidget
proc adw_action_row_set_subtitle*(row: GtkWidget, subtitle: cstring)
proc adw_action_row_add_prefix*(row, child: GtkWidget)
proc adw_action_row_add_suffix*(row, child: GtkWidget)
proc adw_action_row_remove*(row, child: GtkWidget)
proc adw_action_row_set_activatable_widget*(row, child: GtkWidget)

# Adw.ExpanderRow
proc adw_expander_row_new*(): GtkWidget
proc adw_expander_row_set_subtitle*(row: GtkWidget, subtitle: cstring)
proc adw_expander_row_add_action*(row, child: GtkWidget)
proc adw_expander_row_add_prefix*(row, child: GtkWidget)
proc adw_expander_row_add_row*(expanderRow, row: GtkWidget)
proc adw_expander_row_remove*(row, child: GtkWidget)

# Adw.ComboRow
proc adw_combo_row_new*(): GtkWidget
proc adw_combo_row_set_model*(comboRow: GtkWidget, model: GListModel)
proc adw_combo_row_set_selected*(comboRow: GtkWidget, selected: cuint)
proc adw_combo_row_get_selected*(comboRow: GtkWidget): cuint

when AdwVersion >= (1, 2):
  # Adw.EntryRow
  proc adw_entry_row_new*(): GtkWidget
  proc adw_entry_row_add_suffix*(row, child: GtkWidget)
  proc adw_entry_row_remove*(row, child: GtkWidget)

  # Adw.PasswordEntryRow
  proc adw_password_entry_row_new*(): GtkWidget

# Adw.Flap
proc adw_flap_new*(): GtkWidget
proc adw_flap_set_content*(flap, content: GtkWidget)
proc adw_flap_set_flap*(flap, child: GtkWidget)
proc adw_flap_set_separator*(flap, child: GtkWidget)
proc adw_flap_set_fold_policy*(flap: GtkWidget, foldPolicy: FlapFoldPolicy)
proc adw_flap_set_fold_threshold_policy*(flap: GtkWidget, foldThresholdPolicy: FoldThresholdPolicy)
proc adw_flap_set_transition_type*(flap: GtkWidget, transitionType: FlapTransitionType)
proc adw_flap_set_reveal_flap*(flap: GtkWidget, revealed: cbool)
proc adw_flap_set_modal*(flap: GtkWidget, modal: cbool)
proc adw_flap_set_locked*(flap: GtkWidget, locked: cbool)
proc adw_flap_set_swipe_to_open*(flap: GtkWidget, swipe: cbool)
proc adw_flap_set_swipe_to_close*(flap: GtkWidget, swipe: cbool)
proc adw_flap_get_reveal_flap*(flap: GtkWidget): cbool
proc adw_flap_get_folded*(flap: GtkWidget): cbool

# Adw.SplitButton
proc adw_split_button_new*(): GtkWidget
proc adw_split_button_set_child*(button, child: GtkWidget)
proc adw_split_button_set_popover*(button, child: GtkWidget)

# Adw.StatusPage
proc adw_status_page_new*(): GtkWidget
proc adw_status_page_set_child*(self: GtkWidget, child: GtkWidget)
proc adw_status_page_set_description*(self: GtkWidget, description: cstring)
proc adw_status_page_set_icon_name*(self: GtkWidget, icon_name: cstring)
proc adw_status_page_set_paintable*(self: GtkWidget, paintable: GtkWidget)
proc adw_status_page_set_title*(self: GtkWidget, title: cstring)

# Adw.HeaderBar
proc adw_header_bar_new*(): GtkWidget
proc adw_header_bar_pack_end*(self, child: GtkWidget)
proc adw_header_bar_pack_start*(self, child: GtkWidget)
proc adw_header_bar_remove*(self, child: GtkWidget)
proc adw_header_bar_set_centering_policy*(self: GtkWidget, centering_policy: CenteringPolicy)
proc adw_header_bar_set_decoration_layout*(self: GtkWidget, layout: cstring)
proc adw_header_bar_set_show_end_title_buttons*(self: GtkWidget, setting: cbool)
proc adw_header_bar_set_show_start_title_buttons*(self: GtkWidget, setting: cbool)
proc adw_header_bar_set_title_widget*(self, title_widget: GtkWidget)

when AdwVersion >= (1, 4):
  proc adw_header_bar_set_show_back_button*(self: GtkWidget, show_back_button: cbool)
  proc adw_header_bar_set_show_title*(self: GtkWidget, show_title: cbool)

when AdwVersion >= (1, 2):
  # Adw.AboutWindow
  proc adw_about_window_new*(): GtkWidget
  proc adw_about_window_set_application_name*(window: GtkWidget, value: cstring)
  proc adw_about_window_set_developer_name*(window: GtkWidget, value: cstring)
  proc adw_about_window_set_version*(window: GtkWidget, value: cstring)
  proc adw_about_window_set_support_url*(window: GtkWidget, value: cstring)
  proc adw_about_window_set_issue_url*(window: GtkWidget, value: cstring)
  proc adw_about_window_set_website*(window: GtkWidget, value: cstring)
  proc adw_about_window_set_copyright*(window: GtkWidget, value: cstring)
  proc adw_about_window_set_license*(window: GtkWidget, value: cstring)

when AdwVersion >= (1, 4):
  # Adw.SwitchRow
  proc adw_switch_row_new*(): GtkWidget
  proc adw_switch_row_set_active*(self: GtkWidget, is_active: cbool)
  proc adw_switch_row_get_active*(self: GtkWidget): cbool
when AdwVersion >= (1, 3):
  # Adw.Banner
  proc adw_banner_new*(title: cstring): GtkWidget
  proc adw_banner_set_button_label*(self: GtkWidget, label: cstring)
  proc adw_banner_set_title*(self: GtkWidget, title: cstring)
  proc adw_banner_set_use_markup*(self: GtkWidget, use_markup: cbool)
  proc adw_banner_set_revealed*(self: GtkWidget, revealed: cbool)
