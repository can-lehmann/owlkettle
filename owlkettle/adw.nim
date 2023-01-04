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

when defined(nimPreviewSlimSystem):
  import std/assertions
import gtk, widgetdef, widgets, mainloop, widgetutils

when defined(owlkettleDocs) and isMainModule:
  echo "# Libadwaita Widgets\n\n"

{.passl: "-ladwaita-1".}

type
  StyleManager = distinct pointer
  
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

# Adw.ExpanderRow
proc adw_expander_row_new(): GtkWidget
proc adw_expander_row_set_subtitle(row: GtkWidget, subtitle: cstring)
proc adw_expander_row_add_action(row, child: GtkWidget)
proc adw_expander_row_add_prefix(row, child: GtkWidget)
proc adw_expander_row_add_row(expanderRow, row: GtkWidget)
proc adw_expander_row_remove(row, child: GtkWidget)

# Adw.ComboRow
proc adw_combo_row_new(): GtkWidget
proc adw_combo_row_set_model*(comboRow: GtkWidget, model: GListModel)
proc adw_combo_row_set_selected*(comboRow: GtkWidget, selected: cuint)
proc adw_combo_row_get_selected*(comboRow: GtkWidget): cuint

# Adw.Flap
proc adw_flap_new(): GtkWidget
proc adw_flap_set_content(flap, content: GtkWidget)
proc adw_flap_set_flap(flap, child: GtkWidget)
proc adw_flap_set_separator(flap, child: GtkWidget)
proc adw_flap_set_fold_policy(flap: GtkWidget, foldPolicy: FlapFoldPolicy)
proc adw_flap_set_fold_threshold_policy(flap: GtkWidget, foldThresholdPolicy: FoldThresholdPolicy)
proc adw_flap_set_transition_type(flap: GtkWidget, transitionType: FlapTransitionType)
proc adw_flap_set_reveal_flap(flap: GtkWidget, revealed: cbool)
proc adw_flap_set_modal(flap: GtkWidget, modal: cbool)
proc adw_flap_set_locked(flap: GtkWidget, locked: cbool)
proc adw_flap_set_swipe_to_open(flap: GtkWidget, swipe: cbool)
proc adw_flap_set_swipe_to_close(flap: GtkWidget, swipe: cbool)
proc adw_flap_get_reveal_flap(flap: GtkWidget): cbool
proc adw_flap_get_folded(flap: GtkWidget): cbool
{.pop.}

renderable WindowTitle of BaseWidget:
  title: string
  subtitle: string
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_window_title_new(cstring(""), cstring(""))
  
  hooks title:
    property:
      adw_window_title_set_title(state.internalWidget, state.title.cstring)
  
  hooks subtitle:
    property:
      adw_window_title_set_subtitle(state.internalWidget, state.subtitle.cstring)
  
  example:
    Window:
      HeaderBar {.addTitlebar.}:
        WindowTitle {.addTitle.}:
          title = "Title"
          subtitle = "Subtitle"

renderable Avatar of BaseWidget:
  text: string
  size: int
  showInitials: bool
  iconName: string = "avatar-default-symbolic"
  
  hooks:
    beforeBuild:
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
  
  example:
    Avatar:
      text = "Erika Mustermann"
      size = 100
      showInitials = true

renderable Clamp of BaseWidget:
  maximumSize: int
  child: Widget
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_clamp_new()
  
  hooks maximumSize:
    property:
      adw_clamp_set_maximum_size(state.internalWidget, cint(state.maximumSize))
  
  hooks child:
    (build, update):
      state.updateChild(state.child, widget.valChild, adw_clamp_set_child)
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a Clamp. Use a Box widget to display multiple widgets in a Clamp.")
    widget.hasChild = true
    widget.valChild = child
  
  example:
    Clamp:
      maximumSize = 600
      margin = 12
      
      PreferencesGroup:
        title = "Settings"

renderable PreferencesGroup of BaseWidget:
  title: string
  description: string
  children: seq[Widget]
  suffix: Widget
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_preferences_group_new()
  
  hooks title:
    property:
      adw_preferences_group_set_title(state.internalWidget, state.title.cstring)
  
  hooks description:
    property:
      adw_preferences_group_set_description(state.internalWidget, state.description.cstring)
  
  hooks suffix:
    (build, update):
      state.updateChild(state.suffix, widget.valSuffix, adw_preferences_group_set_header_suffix)
  
  hooks children:
    (build, update):
      state.updateChildren(
        state.children,
        widget.valChildren,
        adw_preferences_group_add,
        adw_preferences_group_remove
      )
  
  adder add:
    widget.hasChildren = true
    widget.valChildren.add(child)
  
  adder addSuffix:
    if widget.hasSuffix:
      raise newException(ValueError, "Unable to add multiple suffixes to a PreferencesGroup. Use a Box widget to display multiple widgets in a PreferencesGroup.")
    widget.hasSuffix = true
    widget.valSuffix = child
  
  example:
    PreferencesGroup:
      title = "Settings"
      description = "Application Settings"
      
      ActionRow:
        title = "My Setting"
        subtitle = "Subtitle"
        Switch() {.addSuffix.}

renderable PreferencesRow of ListBoxRow:
  title: string
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_preferences_row_new()
  
  hooks title:
    property:
      adw_preferences_row_set_title(state.internalWidget, state.title.cstring)

renderable ActionRow of PreferencesRow:
  subtitle: string
  suffixes: seq[AlignedChild[Widget]]
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_action_row_new()
  
  hooks subtitle:
    property:
      adw_action_row_set_subtitle(state.internalWidget, state.subtitle.cstring)
  
  hooks suffixes:
    (build, update):
      state.updateAlignedChildren(state.suffixes, widget.valSuffixes,
        adw_action_row_add_suffix,
        adw_action_row_remove
      )

  adder addSuffix {.hAlign: AlignFill, vAlign: AlignCenter.}:
    widget.hasSuffixes = true
    widget.valSuffixes.add(AlignedChild[Widget](
      widget: child,
      hAlign: hAlign,
      vAlign: vAlign
    ))
  
  example:
    ActionRow:
      title = "Color"
      subtitle = "Color of the object"
      
      ColorButton {.addSuffix.}:
        discard

renderable ExpanderRow of PreferencesRow:
  subtitle: string
  actions: seq[AlignedChild[Widget]]
  rows: seq[AlignedChild[Widget]]
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_expander_row_new()
  
  hooks subtitle:
    property:
      adw_expander_row_set_subtitle(state.internalWidget, state.subtitle.cstring)
  
  hooks actions:
    (build, update):
      state.updateAlignedChildren(state.actions, widget.valActions,
        adw_expander_row_add_action,
        adw_expander_row_remove
      )
  
  hooks rows:
    (build, update):
      state.updateAlignedChildren(state.rows, widget.valRows,
        adw_expander_row_add_row,
        adw_expander_row_remove
      )
  
  adder addAction {.hAlign: AlignFill, vAlign: AlignCenter.}:
    widget.hasActions = true
    widget.valActions.add(AlignedChild[Widget](
      widget: child,
      hAlign: hAlign,
      vAlign: vAlign
    ))
  
  adder addRow {.hAlign: AlignFill, vAlign: AlignFill.}:
    widget.hasRows = true
    widget.valRows.add(AlignedChild[Widget](
      widget: child,
      hAlign: hAlign,
      vAlign: vAlign
    ))
  
  example:
    ExpanderRow:
      title = "Expander Row"
      
      for it in 0..<3:
        ActionRow {.addRow.}:
          title = "Nested Row " & $it

renderable ComboRow of ActionRow:
  items: seq[string]
  selected: int
  
  proc select(item: int)
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_combo_row_new()
    connectEvents:
      proc selectCallback(widget: GtkWidget,
                          pspec: pointer,
                          data: ptr EventObj[proc (item: int)]) {.cdecl.} =
        let
          selected = int(adw_combo_row_get_selected(widget))
          state = ComboRowState(data[].widget)
        if selected != state.selected:
          state.selected = selected
          data[].callback(selected)
          data[].redraw()
      
      state.connect(state.select, "notify::selected", selectCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.select)
  
  hooks items:
    property:
      let items = allocCStringArray(state.items)
      defer: deallocCStringArray(items)
      adw_combo_row_set_model(state.internalWidget, gtk_string_list_new(items))
  
  hooks selected:
    property:
      adw_combo_row_set_selected(state.internalWidget, cuint(state.selected))
  
  example:
    ComboRow:
      title = "Combo Row"
      items = @["Option 1", "Option 2", "Option 3"]
      
      selected = app.selected
      proc select(item: int) =
        app.selected = item

type FlapChild[T] = object
  widget: T
  width: int

renderable Flap:
  content: Widget
  separator: Widget
  flap: FlapChild[Widget]
  revealed: bool = false
  foldPolicy: FlapFoldPolicy = FlapFoldAuto
  foldThresholdPolicy: FoldThresholdPolicy = FoldThresholdNatural
  transitionType: FlapTransitionType = FlapTransitionOver
  modal: bool = true
  locked: bool = false
  swipeToClose: bool = true
  swipeToOpen: bool = true
  
  proc changed(revealed: bool)
  proc fold(folded: bool)
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_flap_new()
    connectEvents:
      proc changedCallback(widget: GtkWidget,
                           pspec: pointer,
                           data: ptr EventObj[proc (state: bool)]) {.cdecl.} =
        let
          revealed = adw_flap_get_reveal_flap(widget) != 0
          state = FlapState(data[].widget)
        if state.revealed != revealed:
          state.revealed = revealed
          data[].callback(revealed)
          data[].redraw()
      
      state.connect(state.changed, "notify::reveal-flap", changedCallback)
      
      proc foldCallback(widget: GtkWidget,
                        pspec: pointer,
                        data: ptr EventObj[proc (state: bool)]) {.cdecl.} =
        data[].callback(adw_flap_get_folded(widget) != 0)
        data[].redraw()
      
      state.connect(state.fold, "notify::folded", foldCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.changed)
      state.internalWidget.disconnect(state.fold)
  
  hooks foldPolicy:
    property:
      adw_flap_set_fold_policy(state.internal_widget, state.foldPolicy)
  
  hooks foldThresholdPolicy:
    property:
      adw_flap_set_fold_threshold_policy(state.internal_widget, state.foldThresholdPolicy)
  
  hooks transitionType:
    property:
      adw_flap_set_transition_type(state.internal_widget, state.transitionType)
  
  hooks revealed:
    property:
      adw_flap_set_reveal_flap(state.internal_widget, cbool(ord(state.revealed)))
  
  hooks modal:
    property:
      adw_flap_set_modal(state.internal_widget, cbool(ord(state.modal)))
  
  hooks locked:
    property:
      adw_flap_set_locked(state.internal_widget, cbool(ord(state.locked)))
  
  hooks swipeToOpen:
    property:
      adw_flap_set_swipe_to_open(state.internal_widget, cbool(ord(state.swipeToOpen)))
  
  hooks swipeToClose:
    property:
      adw_flap_set_swipe_to_close(state.internal_widget, cbool(ord(state.swipeToClose)))
  
  hooks flap:
    (build, update):
      if widget.hasFlap:
        widget.valFlap.widget.assignApp(state.app)
        let newChild =
          if state.flap.widget.isNil:
            widget.valFlap.widget.build()
          else:
            widget.valFlap.widget.update(state.flap.widget)
        if not newChild.isNil:
          let childWidget = newChild.unwrapInternalWidget()
          adw_flap_set_flap(state.internalWidget, childWidget)
          let styleContext = gtk_widget_get_style_context(childWidget)
          gtk_style_context_add_class(styleContext, "background")
          state.flap.widget = newChild
        
        if state.flap.width != widget.valFlap.width:
          state.flap.width = widget.valFlap.width
          let childWidget = state.flap.widget.unwrapInternalWidget()
          gtk_widget_set_size_request(childWidget, cint(state.flap.width), -1)
  
  hooks separator:
    (build, update):
      state.updateChild(state.separator, widget.valSeparator, adw_flap_set_separator)
  
  hooks content:
    (build, update):
      state.updateChild(state.content, widget.valContent, adw_flap_set_content)
  
  setter swipe: bool
  
  adder add:
    if widget.hasContent:
      raise newException(ValueError, "Unable to add multiple children to a adw.Flap. Use a Box widget to display multiple widgets in a adw.Flap.")
    widget.hasContent = true
    widget.valContent = child
  
  adder addSeparator:
    if widget.hasSeparator:
      raise newException(ValueError, "Unable to add multiple separators to a adw.Flap.")
    widget.hasSeparator = true
    widget.valSeparator = child
  
  adder addFlap {.width: -1.}:
    if widget.hasFlap:
      raise newException(ValueError, "Unable to add multiple flaps to a adw.Flap. Use a Box widget to display multiple widgets in a adw.Flap.")
    widget.hasFlap = true
    widget.valFlap = FlapChild[Widget](widget: child, width: width)
  
  example:
    Flap:
      revealed = app.showFlap
      transitionType = FlapTransitionOver
      
      proc changed(revealed: bool) =
        app.showFlap = revealed
      
      Label(text = "Flap") {.addFlap, width: 200.}
      
      Separator() {.addSeparator.}
      
      Box:
        Label:
          text = "Content ".repeat(10)
          wrap = true

proc `hasSwipe=`*(flap: Flap, has: bool) =
  flap.hasSwipeToOpen = has
  flap.hasSwipeToClose = has

proc `valSwipe=`*(flap: Flap, swipe: bool) =
  flap.valSwipeToOpen = swipe
  flap.valSwipeToClose = swipe

export WindowTitle, Avatar, Clamp, PreferencesGroup, PreferencesRow, ActionRow, ExpanderRow, ComboRow, Flap

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
