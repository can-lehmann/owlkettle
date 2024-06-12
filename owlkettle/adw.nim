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
import widgetdef, widgets, mainloop, widgetutils, common
import ./bindings/[adw, gtk]
import ../owlkettle
import std/[strutils, sequtils, strformat, options, sugar]

export adw.StyleManager
export adw.ColorScheme
export adw.FlapFoldPolicy
export adw.FoldThresholdPolicy
export adw.FlapTransitionType
export adw.ToastPriority
export adw.isNil
export adw.ToolbarStyle
export adw.LengthUnit
export adw.CenteringPolicy
export adw.AdwVersion

when defined(owlkettleDocs) and isMainModule:
  echo "# Libadwaita Widgets\n\n"
  echo "Some widgets are only available when linking against later libadwaita versions."
  echo "Set the target libadwaita version by passing `-d:adwminor=<Minor Version>`."
  echo "\n\n"

renderable AdwWindow of BaseWindow:
  ## A Window that does not have a title bar.
  content: Widget
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_window_new()
  
  hooks content:
    (build, update):
      state.updateChild(state.content, widget.valContent, adw_window_set_content)
  
  adder add:
    ## Adds a child to the window surface. Each window surface may only have one child.
    if widget.hasContent:
      raise newException(ValueError, "Unable to add multiple children to a AdwWindow. Use a Box widget to display multiple widgets in a AdwWindow.")
    widget.hasContent = true
    widget.valContent = child
  
  example:
    AdwWindow:
      Box:
        orient = OrientX
        
        Box {.expand: false.}:
          sizeRequest = (250, -1)
          orient = OrientY
          
          HeaderBar {.expand: false.}:
            showTitleButtons = false
          
          Label(text = "Sidebar")
        
        Separator() {.expand: false.}
        
        Box:
          orient = OrientY
          
          HeaderBar() {.expand: false.}
          Label(text = "Main Content")

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

renderable ButtonContent of BaseWidget:
  label: string
  iconName: string
  useUnderline: bool ## Defines whether you can use `_` on part of the label to make the button accessible via hotkey. If you prefix a character of the label text with `_` it will hide the `_` and activate the button if you press ALT + the key of the character. E.g. `_Button Text` will trigger the button when pressing `ALT + B`.
  canShrink {.since: AdwVersion >= (1, 4).}: bool ## Defines whether the ButtonContent can be smaller than the size of its contents.
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_button_content_new()
  
  hooks label:
    property:
      adw_button_content_set_label(state.internalWidget, state.label.cstring)
    
  hooks iconName:
    property:
      adw_button_content_set_icon_name(state.internalWidget, state.iconName.cstring)
    
  hooks useUnderline:
    property:
      adw_button_content_set_use_underline(state.internalWidget, state.useUnderline.cbool)
  
  hooks canShrink:
    property:
      adw_button_content_set_can_shrink(state.internalWidget, state.canShrink.cbool)

renderable Clamp of BaseWidget:
  maximumSize: int ## Maximum width of the content
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

renderable PreferencesPage of BaseWidget:
  preferences: seq[Widget]
  iconName: string
  name: string
  title: string
  useUnderline: bool
  description {.since: AdwVersion >= (1, 4).}: string
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_preferences_page_new()
  
  hooks preferences:
    (build, update):
      state.updateChildren(
        state.preferences,
        widget.valPreferences,
        adw_preferences_page_add,
        adw_preferences_page_remove
      )
  
  hooks iconName:
    property:
      adw_preferences_page_set_icon_name(state.internalWidget, state.iconName.cstring)
  
  hooks name:
    property:
      adw_preferences_page_set_name(state.internalWidget, state.name.cstring)
      
  hooks title:
    property:
      adw_preferences_page_set_title(state.internalWidget, state.title.cstring)
      
  hooks useUnderline:
    property:
      adw_preferences_page_set_use_underline(state.internalWidget, state.useUnderline.cbool)
      
  hooks description:
    property:
      adw_preferences_page_set_description(state.internalWidget, state.description.cstring)
  
  adder add:
    widget.valPreferences.add(child)
  

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
  expanded: bool = false
  enableExpansion: bool = true
  showEnableSwitch: bool = false
  titleLines {.since: AdwVersion >= (1, 3).}: int ## Determines how many lines of text from the title are shown before it ellipsizes the text. Defaults to 0 which means it never elipsizes and instead adds new lines to show the full text. 
  subtitleLines {.since: AdwVersion >= (1, 3).}: int  ## Determines how many lines of text from the subtitle are shown before it ellipsizes the text. Defaults to 0 which means it never elipsizes and instead adds new lines to show the full text.
  
  proc expand(newExpandState: bool) ## Triggered when row gets expanded
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_expander_row_new()
    connectEvents:
      proc expandCallback(
        widget: GtkWidget,
        pspec: pointer,
        data: ptr EventObj[proc (isExpanded: bool)]
      ) {.cdecl.} =
        let isExpanded = bool(adw_expander_row_get_expanded(widget))
        
        let state = ExpanderRowState(data[].widget)
        state.expanded = isExpanded
        data[].callback(isExpanded)
        data[].redraw()
        
      state.connect(state.expand, "notify::expanded", expandCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.expand)

  hooks subtitle:
    property:
      adw_expander_row_set_subtitle(state.internalWidget, state.subtitle.cstring)
  
  hooks actions:
    (build, update):
      const rowAdder =
        when AdwVersion >= (1, 4):
          adw_expander_row_add_suffix
        else:
          adw_expander_row_add_action
      
      state.updateAlignedChildren(state.actions, widget.valActions,
        rowAdder,
        adw_expander_row_remove
      )
  
  hooks rows:
    (build, update):
      state.updateAlignedChildren(state.rows, widget.valRows,
        adw_expander_row_add_row,
        adw_expander_row_remove
      )
  
  hooks expanded:
    property:
      adw_expander_row_set_expanded(state.internalWidget, state.expanded.cbool)
      
  hooks enableExpansion:
    property:
      adw_expander_row_set_enable_expansion(state.internalWidget, state.enableExpansion.cbool)
        
  hooks showEnableSwitch:
    property:
      adw_expander_row_set_show_enable_switch(state.internalWidget, state.showEnableSwitch.cbool)
      
  hooks titleLines:
    property:
      adw_expander_row_set_title_lines(state.internalWidget, state.titleLines.cint)

  hooks subtitleLines:
    property:
      adw_expander_row_set_subtitle_lines(state.internalWidget, state.subtitleLines.cint)

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

renderable EntryRow {.since: AdwVersion >= (1, 2).} of PreferencesRow:
  suffixes: seq[AlignedChild[Widget]]
  text: string
  
  proc changed(text: string)
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_entry_row_new()
    connectEvents:
      proc changedCallback(widget: GtkWidget, data: ptr EventObj[proc (text: string)]) {.cdecl.} =
        let text = $gtk_editable_get_text(widget)
        EntryRowState(data[].widget).text = text
        data[].callback(text)
        data[].redraw()
      
      state.connect(state.changed, "changed", changedCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.changed)
  
  hooks suffixes:
    (build, update):
      state.updateAlignedChildren(state.suffixes, widget.valSuffixes,
        adw_entry_row_add_suffix,
        adw_entry_row_remove
      )
  
  hooks text:
    property:
      gtk_editable_set_text(state.internalWidget, state.text.cstring)
    read:
      state.text = $gtk_editable_get_text(state.internalWidget)

  adder addSuffix {.hAlign: AlignFill, vAlign: AlignCenter.}:
    widget.hasSuffixes = true
    widget.valSuffixes.add(AlignedChild[Widget](
      widget: child,
      hAlign: hAlign,
      vAlign: vAlign
    ))
  
  example:
    EntryRow:
      title = "Name"
      text = app.name
      
      proc changed(name: string) =
        app.name = name

renderable PasswordEntryRow {.since: AdwVersion >= (1, 2).} of EntryRow:
  ## An `EntryRow` that hides the user input
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_password_entry_row_new()
  
  example:
    PasswordEntryRow:
      title = "Password"
      text = app.password
      
      proc changed(password: string) =
        app.password = password

when AdwVersion >= (1, 2):
  export EntryRow, PasswordEntryRow

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

renderable OverlaySplitView {.since: AdwVersion >= (1, 4).} of BaseWidget:
  content: Widget
  sidebar: Widget
  collapsed: bool = false
  enableHideGesture: bool = true
  enableShowGesture: bool = true
  maxSidebarWidth: float = 280.0
  minSidebarWidth: float = 180.0
  pinSidebar: bool = false
  showSidebar: bool = true
  sidebarPosition: PackType = PackStart
  widthFraction: float = 0.25
  widthUnit: LengthUnit = LengthScaleIndependent
  
  proc toggle(shown: bool)
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_overlay_split_view_new()
    connectEvents:
      proc toggleCallback(widget: GtkWidget,
                          spec: pointer,
                          data: ptr EventObj[proc (show: bool)]) {.cdecl.} =
        let
          showSidebar = adw_overlay_split_view_get_show_sidebar(widget) != 0
          state = OverlaySplitViewState(data[].widget)
        if showSidebar != state.showSidebar:
          state.showSidebar = showSidebar
          data[].callback(showSidebar)
          data[].redraw()
      
      state.connect(state.toggle, "notify::show-sidebar", toggleCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.toggle)
  
  hooks content:
    (build, update):
      state.updateChild(
        state.content,
        widget.valContent,
        adw_overlay_split_view_set_content
      )
  
  hooks sidebar:
    (build, update):
      state.updateChild(
        state.sidebar,
        widget.valSidebar,
        adw_overlay_split_view_set_sidebar
      )
  
  hooks collapsed:
    property:
      adw_overlay_split_view_set_collapsed(state.internalWidget, state.collapsed.cbool)

  hooks enableHideGesture:
    property:
      adw_overlay_split_view_set_enable_hide_gesture(state.internalWidget, state.enableHideGesture.cbool)

  hooks enableShowGesture:
    property:
      adw_overlay_split_view_set_enable_show_gesture(state.internalWidget, state.enableShowGesture.cbool)

  hooks maxSidebarWidth:
    property:
      adw_overlay_split_view_set_max_sidebar_width(state.internalWidget, state.maxSidebarWidth.cdouble)

  hooks minSidebarWidth:
    property:
      adw_overlay_split_view_set_min_sidebar_width(state.internalWidget, state.minSidebarWidth.cdouble)

  hooks pinSidebar:
    property:
      adw_overlay_split_view_set_pin_sidebar(state.internalWidget, state.pinSidebar.cbool)

  hooks showSidebar:
    property:
      adw_overlay_split_view_set_show_sidebar(state.internalWidget, state.showSidebar.cbool)

  hooks sidebarPosition:
    property:
      adw_overlay_split_view_set_sidebar_position(state.internalWidget, state.sidebarPosition.toGtk())

  hooks widthFraction:
    property:
      adw_overlay_split_view_set_sidebar_width_fraction(state.internalWidget, state.widthFraction.cdouble)

  hooks widthUnit:
    property:
      adw_overlay_split_view_set_sidebar_width_unit(state.internalWidget, state.widthUnit)

  adder add:
    if widget.hasContent:
      raise newException(ValueError, "Unable to add multiple children to a OverlaySplitView. Use a Box widget to display multiple widgets!")
    widget.hasContent = true
    widget.valContent = child
  
  adder addSidebar:
    if widget.hasSidebar:
      raise newException(ValueError, "Unable to add multiple sidebars to a OverlaySplitView. Use a Box widget to display multiple widgets!")
    widget.hasSidebar = true
    widget.valSidebar = child

when AdwVersion >= (1, 4):
  export OverlaySplitView

renderable AdwHeaderBar of BaseWidget:
  ## Adwaita Headerbar that combines GTK Headerbar and WindowControls.
  packLeft: seq[Widget]
  packRight: seq[Widget]
  centeringPolicy: CenteringPolicy = CenteringPolicyLoose
  decorationLayout: Option[string] = none(string)
  showRightButtons: bool = true ## Determines whether the buttons in `rightButtons` are shown. Does not affect Widgets in `packRight`.
  showLeftButtons: bool = true ## Determines whether the buttons in `leftButtons` are shown. Does not affect Widgets in `packLeft`.
  titleWidget: Widget ## A widget for the title. Replaces the title string, if there is one.
  showBackButton {.since: AdwVersion >= (1, 4).}: bool = true
  showTitle {.since: AdwVersion >= (1, 4).}: bool = true ## Determines whether to show or hide the title
  
  setter windowControls: DecorationLayout
  setter windowControls: Option[DecorationLayout]
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_header_bar_new()
  
  hooks packRight:
    (build, update):
      state.updateChildren(
        state.packRight,
        widget.valPackRight,
        adw_header_bar_pack_end,
        adw_header_bar_remove
      )
      
  hooks packLeft:
    (build, update):
      state.updateChildren(
        state.packLeft,
        widget.valPackLeft,
        adw_header_bar_pack_start,
        adw_header_bar_remove
      )
      
  hooks centeringPolicy:
    property:
      adw_header_bar_set_centering_policy(state.internalWidget, state.centeringPolicy)
  
  hooks decorationLayout:
    property:
      if state.decorationLayout.isSome():
        adw_header_bar_set_decoration_layout(state.internalWidget, state.decorationLayout.get().cstring)
      else:
        adw_header_bar_set_decoration_layout(state.internalWidget, nil)
  
  hooks showRightButtons:
    property:
      adw_header_bar_set_show_end_title_buttons(state.internalWidget, state.showRightButtons.cbool)
  
  hooks showLeftButtons:
    property:
      adw_header_bar_set_show_start_title_buttons(state.internalWidget, state.showLeftButtons.cbool)
  
  hooks titleWidget:
    (build, update):
      state.updateChild(
        state.titleWidget,
        widget.valTitleWidget,
        adw_header_bar_set_title_widget
      )
  
  hooks showBackButton:
    property:
      adw_header_bar_set_show_back_button(state.internalWidget, state.showBackButton.cbool)
  
  hooks showTitle:
    property:
      adw_header_bar_set_show_title(state.internalWidget, state.showTitle.cbool)
  
  adder addLeft:
    ## Adds a widget to the left side of the HeaderBar.
    widget.hasPackLeft = true
    widget.valPackLeft.add(child)
  
  adder addRight:
    ## Adds a widget to the right side of the HeaderBar.
    widget.hasPackRight = true
    widget.valPackRight.add(child)
  
  adder addTitle:
    when AdwVersion >= (1, 4):
      if widget.hasTitleWidget:
        raise newException(ValueError, "Unable to add multiple children as title to HeaderBar. Use a Box widget to display multiple widgets.")
      widget.hasTitleWidget = true
      widget.valTitleWidget = child
    else:
      raise newException(ValueError, "Compile for Adwaita version 1.4 or higher with -d:adwMinor=4 to enable setting a Title Widget for Headerbar.")

proc `hasWindowControls=`*(widget: AdwHeaderbar, has: bool) =
  widget.hasDecorationLayout = true

proc `valWindowControls=`*(widget: AdwHeaderbar, buttons: DecorationLayout) =
  widget.valDecorationLayout = some(buttons.toLayoutString())

proc `valWindowControls=`*(widget: AdwHeaderbar, buttons: Option[DecorationLayout]) =
  let decorationLayout: Option[string] = buttons.map(controls => controls.toLayoutString())
  widget.valDecorationLayout = decorationLayout
  
renderable SplitButton of BaseWidget:
  child: Widget
  popover: Widget
    
  proc clicked()
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_split_button_new()
    connectEvents:
      state.connect(state.clicked, "clicked", eventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.clicked)
  
  hooks child:
    (build, update):
      state.updateChild(state.child, widget.valChild, adw_split_button_set_child)
  
  hooks popover:
    (build, update):
      state.updateChild(state.popover, widget.valPopover, adw_split_button_set_popover)
  
  setter text: string
  setter icon: string ## Sets the icon of the SplitButton. See [recommended_tools.md](recommended_tools.md#icons) for a list of icons.
  
  adder addChild:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a SplitButton. Use a Box widget to display multiple widgets in a SplitButton.")
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
      raise newException(ValueError, "Unable to add more than two children to SplitButton")

proc `hasText=`*(splitButton: SplitButton, value: bool) = splitButton.hasChild = value
proc `valText=`*(splitButton: SplitButton, value: string) =
  splitButton.valChild = Label(hasText: true, valText: value)

proc `hasIcon=`*(splitButton: SplitButton, value: bool) = splitButton.hasChild = value
proc `valIcon=`*(splitButton: SplitButton, name: string) =
  splitButton.valChild = Icon(hasName: true, valName: name)

renderable StatusPage of BaseWidget:
  iconName: string ## The icon to render in the center of the StatusPage. Setting this overrides paintable. See the [tooling](https://can-lehmann.github.io/owlkettle/docs/recommended_tools.html) section for how to figure out what icon names are available.
  paintable: Widget ## The widget that implements GdkPaintable to render (e.g. IconPaintable, WidgetPaintable) in the center of the StatusPage. Setting this overrides iconName.
  title: string
  description: string
  child: Widget
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_status_page_new()
  
  hooks iconName:
    property:
      adw_status_page_set_icon_name(state.internalWidget, state.iconName.cstring)
  
  hooks paintable:
    (build, update):
      state.updateChild(state.paintable, widget.valPaintable, adw_status_page_set_paintable)
  
  hooks title:
    property:
      adw_status_page_set_title(state.internalWidget, state.title.cstring)
  
  hooks description:
    property:
      adw_status_page_set_description(state.internalWidget, state.description.cstring)
  
  hooks child:
    (build, update):
      state.updateChild(state.child, widget.valChild, adw_status_page_set_child)
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a StatusPage.")
    widget.hasChild = true
    widget.valChild = child
    
  adder addPaintable:
    if widget.hasPaintable:
      raise newException(ValueError, "Unable to add multiple paintables to a StatusPage.")
    widget.hasPaintable = true
    widget.valPaintable = child

renderable ToolbarView {.since: AdwVersion >= (1, 4).} of BaseWidget:
  content: Widget
  bottomBars: seq[Widget]
  topBars: seq[Widget]
  bottomBarStyle: ToolbarStyle = ToolbarFlat
  extendContentToBottomEdge: bool = false
  extendContentToTopEdge: bool = false
  revealBottomBars: bool = true
  revealTopBars: bool = true
  topBarStyle: ToolbarStyle = ToolbarFlat
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_toolbar_view_new()
  
  hooks content:
    (build, update):
      state.updateChild(
        state.content,
        widget.valContent,
        adw_toolbar_view_set_content
      )
  
  hooks bottomBars:
    (build, update):
      state.updateChildren(
        state.bottomBars,
        widget.valBottomBars,
        adw_toolbar_view_add_bottom_bar,
        adw_toolbar_view_remove
      )
  
  hooks topBars:
    (build, update):
      state.updateChildren(
        state.topBars,
        widget.valTopBars,
        adw_toolbar_view_add_top_bar,
        adw_toolbar_view_remove
      )
    
  hooks bottomBarStyle:
    property:
      adw_toolbar_view_set_bottom_bar_style(state.internalWidget, state.bottomBarStyle)
  
  hooks extendContentToBottomEdge:
    property:
      adw_toolbar_view_set_extend_content_to_bottom_edge(state.internalWidget, state.extendContentToBottomEdge.cbool)
  
  hooks extendContentToTopEdge:
    property:
      adw_toolbar_view_set_extend_content_to_top_edge(state.internalWidget, state.extendContentToTopEdge.cbool)
  
  hooks revealBottomBars:
    property:
      adw_toolbar_view_set_reveal_bottom_bars(state.internalWidget, state.revealBottomBars.cbool)
      
  hooks revealTopBars:
    property:
      adw_toolbar_view_set_reveal_top_bars(state.internalWidget, state.revealTopBars.cbool)
      
  hooks topBarStyle:
    property:
      adw_toolbar_view_set_top_bar_style(state.internalWidget, state.topBarStyle)
  
  adder add:
    if widget.hasContent:
      raise newException(ValueError, "Unable to add multiple children to a ToolbarView. Use a Box widget to display multiple widgets!")
    widget.hasContent = true
    widget.valContent = child
  
  adder addBottom:
    widget.hasBottomBars = true
    widget.valBottomBars.add(child)
  
  adder addTop:
    widget.hasTopBars = true
    widget.valTopBars.add(child)

when AdwVersion >= (1, 4):
  export ToolbarView

type LicenseType* = enum
  LicenseUnknown = 0
  LicenseCustom = 1
  LicenseGPL_2_0 = 2
  LicenseGPL_3_0 = 3
  LicenseLGPL_2_1 = 4
  LicenseLGPL_3_0 = 5
  LicenseBSD = 6
  LicenseMIT_X11 = 7
  LicenseArtistic = 8
  LicenseGPL2_0_Only = 9
  LicenseGPL3_0_Only = 10
  LicenseLGPL2_1_Only = 11
  LicenseLGPL3_0_Only = 12
  LicenseAGPL3_0 = 13
  LicenseAGPL3_0_Only = 14
  LicenseBSD3 = 15
  LicenseAPACHE2_0 = 16
  LicenseMPL2_0 = 17
  License0BSD = 18

proc toGtk(license: LicenseType): GtkLicenseType =
  result = GtkLicenseType(ord(license))

type LegalSection* = object
  title*: string
  copyright*: Option[string]
  licenseType*: LicenseType
  license*: Option[string]

renderable AboutWindow {.since: AdwVersion >= (1, 2).}:
  applicationName: string
  developerName: string
  version: string
  supportUrl: string
  issueUrl: string
  website: string
  copyright: string
  license: string ## A custom license text. If this field is used instead of `licenseType`, `licenseType` has to be empty or `LicenseCustom`.
  licenseType: LicenseType ## A license from the `LicenseType` enum.
  legalSections: seq[LegalSection] ## Adds extra sections to the "Legal" page. You can use these sections for dependency package attributions etc.
  applicationIcon: string
  releaseNotes: string
  comments: string
  debugInfo: string ## Adds a "Troubleshooting" section. Use this field to provide instructions on how to acquire logs or other info you want users of your app to know about when reporting bugs or debugging.
  developers: seq[string]
  designers: seq[string]
  artists: seq[string]
  documenters: seq[string]
  credits: seq[tuple[title: string, people: seq[string]]] ## Additional credit sections with customizable titles
  acknowledgements: seq[tuple[title: string, people: seq[string]]] ## Acknowledgment sections with customizable titles
  links: seq[tuple[title: string, url: string]] ## Additional links placed in the details section
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_about_window_new()
  
  hooks applicationName:
    property:
      adw_about_window_set_application_name(state.internalWidget, state.applicationName.cstring)

  hooks developerName:
    property:
      adw_about_window_set_developer_name(state.internalWidget, state.developerName.cstring)

  hooks version:
    property:
      adw_about_window_set_version(state.internalWidget, state.version.cstring)

  hooks supportUrl:
    property:
      adw_about_window_set_support_url(state.internalWidget, state.supportUrl.cstring)

  hooks issueUrl:
    property:
      adw_about_window_set_issue_url(state.internalWidget, state.issueUrl.cstring)
  
  hooks website:
    property:
      adw_about_window_set_website(state.internalWidget, state.website.cstring)

  hooks copyright:
    property:
      adw_about_window_set_copyright(state.internalWidget, state.copyright.cstring)

  hooks license:
    property:
      adw_about_window_set_license(state.internalWidget, state.license.cstring)

  hooks licenseType:
    property:
      adw_about_window_set_license_type(state.internalWidget, state.licenseType.toGtk())

  hooks legalSections:
    build:
      if widget.hasLegalSections:
        state.legalSections = widget.valLegalSections
        for section in state.legalSections:
          var copyright: cstring
          var license: cstring
          if section.copyright.isSome:
            copyright = section.copyright.get().cstring
          if section.license.isSome:
            license = section.license.get().cstring

          adw_about_window_add_legal_section(
            state.internalWidget,
            section.title,
            copyright,
            section.licenseType.toGtk(),
            license
          )

  hooks applicationIcon:
    property:
      adw_about_window_set_application_icon(state.internalWidget, state.applicationIcon.cstring)

  hooks releaseNotes:
    property:
      adw_about_window_set_release_notes(state.internalWidget, state.releaseNotes.cstring)

  hooks comments:
    property:
      adw_about_window_set_comments(state.internalWidget, state.comments.cstring)

  hooks debugInfo:
    property:
      adw_about_window_set_debug_info(state.internalWidget, state.debugInfo.cstring)

  hooks developers:
    property:
      let developers = allocCStringArray(state.developers)
      defer: deallocCStringArray(developers)
      adw_about_window_set_developers(state.internalWidget, developers)

  hooks designers:
    property:
      let designers = allocCStringArray(state.designers)
      defer: deallocCStringArray(designers)
      adw_about_window_set_designers(state.internalWidget, designers)

  hooks artists:
    property:
      let artists = allocCStringArray(state.artists)
      defer: deallocCStringArray(artists)
      adw_about_window_set_artists(state.internalWidget, artists)

  hooks documenters:
    property:
      let documenters = allocCStringArray(state.documenters)
      defer: deallocCStringArray(documenters)
      adw_about_window_set_documenters(state.internalWidget, documenters)

  hooks credits:
    build:
      if widget.hasCredits:
        state.credits = widget.valCredits
        for (title, people) in state.credits:
          let names = allocCStringArray(people)
          defer: deallocCStringArray(names)
          adw_about_window_add_credit_section(state.internalWidget, title.cstring, names)

  hooks acknowledgements:
    build:
      if widget.hasAcknowledgements:
        state.acknowledgements = widget.valAcknowledgements
        for (title, people) in state.acknowledgements:
          let names = allocCStringArray(people)
          defer: deallocCStringArray(names)
          adw_about_window_add_acknowledgement_section(state.internalWidget, title.cstring, names)

  hooks links:
    build:
      if widget.hasLinks:
        state.links = widget.valLinks
        for (title, url) in state.links:
          adw_about_window_add_link(state.internalWidget, title.cstring, url.cstring)

  example:
    AboutWindow:
      applicationName = "My Application"
      developerName = "Erika Mustermann"
      version = "1.0.0"
      applicationIcon = "application-x-executable"
      supportUrl = "https://github.com/can-lehmann/owlkettle/discussions"
      issueUrl = "https://github.com/can-lehmann/owlkettle/issues"
      website = "https://can-lehmann.github.io/owlkettle/README"
      links = @{
        "Tutorial": "https://can-lehmann.github.io/owlkettle/docs/tutorial.html",
        "Installation": "https://can-lehmann.github.io/owlkettle/docs/installation.html",
      }
      comments = """My Application demonstrates the use of the Adwaita AboutWindow. Comments will be shown on the Details page, above links. <i>Unlike</i> GtkAboutDialog comments, this string can be long and detailed. It can also contain <a href='https://docs.gtk.org/Pango/pango_markup.html'>links</a> and <b>Pango markup</b>."""
      copyright = "Erika Mustermann"
      licenseType = LicenseMIT_X11

when AdwVersion >= (1, 2):
  export AboutWindow

## Adw.Toast
type Toast* = ref object
  title*: string
  customTitle*: Widget
  buttonLabel*: string
  priority*: ToastPriority
  timeout*: int
  dismissalHandler: proc(toast: Toast)
  clickedHandler: proc()
  useMarkup: bool

proc newToast*(
  title: string,
  buttonLabel: string = "", 
  priority: ToastPriority = ToastPriorityNormal, 
  dismissalHandler: proc(toast: Toast) = nil, 
  clickedHandler: proc() = nil,
  timeout: int = 5, 
  useMarkup: bool = false,
  customTitle: Widget = nil.Widget
): Toast =
  result = Toast(
    title: title, 
    buttonLabel: buttonLabel,
    priority: priority,
    timeout: timeout,
    dismissalHandler: dismissalHandler
  )
  
  when AdwVersion >= (1, 2):
    result.clickedHandler = clickedHandler
    result.customTitle = customTitle
  else:
    let isUsingCustomTitle = not customTitle.isNil()
    if isUsingCustomTitle:
      raise newException(LibraryError, "The customTitle field on a Toast instance is not available when compiling for Adwaita versions below 1.2. Compile for Adwaita version 1.2 or higher with -d:adwminor=2 to enable it")

    let isUsingClickedHandler = not clickedHandler.isNil()
    if isUsingClickedHandler:
      raise newException(LibraryError, "The clickedHandler field on a Toast instance is not available when compiling for Adwaita versions below 1.2. Compile for Adwaita version 1.2 or higher with -d:adwminor=2 to enable it")
      
  when AdwVersion >= (1, 4):
    result.useMarkup = useMarkup
  else:
    let isUsingUseMarkup = useMarkup == true
    if isUsingUseMarkup:
      raise newException(LibraryError, "The useMarkup field on a Toast instance is not available when compiling for Adwaita versions below 1.4. Compile for Adwaita version 1.4 or higher with -d:adwminor=4 to enable it")

proc toOwl(adwToast: AdwToast): Toast =
  when AdwVersion >= (1, 4):
    let useMarkup = adw_toast_get_use_markup(adwToast).bool
  else:
    let useMarkup = false
  
  result = newToast(
    title = $adw_toast_get_title(adwToast),
    buttonLabel = $adw_toast_get_button_label(adwToast),
    priority = adw_toast_get_priority(adwToast),
    timeout = adw_toast_get_timeout(adwToast).int,
    useMarkup = useMarkup
  )
  
proc toGtk(toast: Toast): AdwToast =
  result = adw_toast_new(toast.title.cstring)
  if toast.buttonLabel != "":
    adw_toast_set_button_label(result, toast.buttonLabel.cstring)
  adw_toast_set_priority(result, toast.priority)
  let timeout: cuint = cuint(toast.timeout)
  adw_toast_set_timeout(result, timeout)
  
  # Set Dismissal Handler
  if not toast.dismissalHandler.isNil():
    proc dismissalCallback(dismissedToast: AdwToast, data: ptr EventObj[proc (toast: Toast)]) {.cdecl.} = 
      let event = unwrapSharedCell(data)
      let toast: Toast = dismissedToast.toOwl()
      event.callback(toast)
      # Disconnect event-handler after Toast was dismissed
      g_signal_handler_disconnect(pointer(dismissedToast), event.handler)
    
    let event = EventObj[proc(toast: Toast)]()
    let data = allocSharedCell(event)
    data.callback = toast.dismissalHandler
    data.handler = g_signal_connect(result, "dismissed".cstring, dismissalCallback, data)
  
  when AdwVersion >= (1, 2):
    if not toast.customTitle.isNil():
      let customTitleWidget = toast.customTitle.build().unwrapInternalWidget()
      adw_toast_set_custom_title(result, customTitleWidget)

    # Set Clicked Handler
    if not toast.clickedHandler.isNil():
      proc clickCallback(dismissedToast: AdwToast, data: ptr EventObj[proc()]) {.cdecl.} =
        let event = unwrapSharedCell(data)
        event.callback()
        # Disconnect event-handler after first click as that will dismisses the toast
        g_signal_handler_disconnect(pointer(dismissedToast), event.handler)
      
      let event = EventObj[proc()]()
      let data = allocSharedCell(event)
      data.callback = toast.clickedHandler
      data.handler = g_signal_connect(result, "button-clicked".cstring, clickCallback, data)

  when AdwVersion >= (1, 4):
    adw_toast_set_use_markup(result, toast.useMarkup.cbool)

renderable ToastOverlay of BaseWidget:
  ## An overlay to display Toast messages that can be dismissed manually and automatically!<br>
  ## Use `newToast` to create a `Toast`.
  ## `Toast` has the following properties that can be assigned to:
  ## - actionName
  ## - actionTarget
  ## - buttonLabel: If set, the Toast will contain a button with this string as its text. If not set, the Toast will not contain a button.
  ## - detailedActionName
  ## - priority: Defines the behaviour of the toast. `ToastPriorityNormal` will put the toast at the end of the queue of toasts to display. `ToastPriorityHigh` will display the toast **immediately**, ignoring any others.
  ## - timeout: The time in seconds after showing the toast after which it is dismissed automatically. Disables automatic dismissal if set to 0. Defaults to 5. 
  ## - title: The text to display in the toast. Gets hidden if customTitle is set.
  ## - customTitle: A Widget to display in the toast. Causes title to be hidden if it is set. Only available when compiling for Adwaita version 1.2 or higher.
  ## - dismissalHandler: An event-handler proc that gets called when this specific toast gets dismissed
  ## - clickedHandler: An event-handler proc that gets called when the User clicks on the toast's button that appears if `buttonLabel` is defined. Only available when compiling for Adwaita version 1.4 or higher.

  child: Widget
  toasts: seq[Toast] ## The Toasts to display. Toasts of priority `ToastPriorityNormal` are displayed in order of a First-In-First-Out queue, after toasts of priority `ToastPriorityHigh` which are displayed in order of a Last-In-First-Out queue.

  hooks:
    beforeBuild:
      state.internalWidget = adw_toast_overlay_new()
  
  hooks child:
    (build, update):
      state.updateChild(state.child, widget.valChild, adw_toast_overlay_set_child)
  
  hooks toasts:
    property:
      for toast in state.toasts:
        let adwToast: AdwToast = toast.toGtk()
        adw_toast_overlay_add_toast(state.internalWidget, adwToast)
  
  setter toast: Toast
  
  adder add:
    if widget.hasChild:
      raise newException(ValueError, "Unable to add multiple children to a Toast Overlay.")
    widget.hasChild = true
    widget.valChild = child

proc `hasToast=`*(overlay: ToastOverlay, has: bool) =
  overlay.hasToasts = has

proc `valToast=`*(overlay: ToastOverlay, toast: Toast) =
  overlay.valToasts = @[toast]
    
renderable SwitchRow {.since: AdwVersion >= (1, 4).} of ActionRow:
  active: bool
  
  proc activated(active: bool)
  
  hooks:
    beforeBuild:
        state.internalWidget = adw_switch_row_new()
    connectEvents:
      proc activatedCallback(widget: GtkWidget, data: ptr EventObj[proc (active: bool)]) {.cdecl.} =
        let active: bool = adw_switch_row_get_active(widget).bool
        SwitchRowState(data[].widget).active = active
        data[].callback(active)
        data[].redraw()
        
      state.connect(state.activated, "activated", activatedCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.activated)
  
  hooks active:
    property:
      adw_switch_row_set_active(state.internalWidget, state.active.cbool)

when AdwVersion >= (1, 4):
  export SwitchRow

renderable Banner {.since: AdwVersion >= (1, 3).} of BaseWidget:
  ## A rectangular Box taking up the entire vailable width with an optional button.
  buttonLabel: string ## Label of the optional banner button. Button will only be added to the banner if this Label has a value.
  title: string
  useMarkup: bool = true ## Determines whether using Markup in title is allowed or not.
  revealed: bool = true ## Determines whether the banner is shown.
  
  proc clicked() ## Triggered by clicking the banner button
  
  hooks:
    beforeBuild:
      state.internalWidget = adw_banner_new("".cstring)
    connectEvents:
      state.connect(state.clicked, "button-clicked", eventCallback)
    disconnectEvents:
      state.internalWidget.disconnect(state.clicked)
  hooks buttonLabel:
    property:
      adw_banner_set_button_label(state.internalWidget, state.buttonLabel.cstring)
  
  hooks title:
    property:
      adw_banner_set_title(state.internalWidget, state.title.cstring)
  
  hooks useMarkup:
    property:
      adw_banner_set_use_markup(state.internalWidget, state.useMarkup.cbool)

  hooks revealed:
    property:
      adw_banner_set_revealed(state.internalWidget, state.revealed.cbool)

when AdwVersion >= (1, 3):
  export Banner

export ToastOverlay, Toast
export AdwWindow, WindowTitle, AdwHeaderBar, Avatar, ButtonContent, Clamp, PreferencesGroup, PreferencesRow, ActionRow, ExpanderRow, ComboRow, Flap, SplitButton, StatusPage, PreferencesPage

proc defaultStyleManager*(): StyleManager =
  result = adw_style_manager_get_default()

proc colorScheme*(styleManager: StyleManager): ColorScheme =
  result = adw_style_manager_get_color_scheme(styleManager)

proc `colorScheme=`*(styleManager: StyleManager, colorScheme: ColorScheme) =
  adw_style_manager_set_color_scheme(styleManager, colorScheme)

proc dark*(styleManager: StyleManager): bool =
  result = bool(adw_style_manager_get_dark(styleManager))

proc highContrast*(styleManager: StyleManager): bool =
  result = bool(adw_style_manager_get_high_contrast(styleManager))

type AdwAppConfig = object of AppConfig
  colorScheme: ColorScheme

proc setupApp(config: AdwAppConfig): WidgetState =
  let styleManager = adw_style_manager_get_default()
  adw_style_manager_set_color_scheme(styleManager, config.colorScheme)
  
  result = setupApp(AppConfig(config))

proc brew*(widget: Widget,
           icons: openArray[string] = [],
           colorScheme: ColorScheme = ColorSchemeDefault,
           startupEvents: openArray[ApplicationEvent] = [],
           shutdownEvents: openArray[ApplicationEvent] = [],
           stylesheets: openArray[Stylesheet] = []) =
  adw_init()
  let config = AdwAppConfig(
    widget: widget,
    icons: @icons,
    darkTheme: false,
    colorScheme: colorScheme,
    stylesheets: @stylesheets
  )
  let state = setupApp(config)
  
  let context = AppContext[AdwAppConfig](
    config: config,
    state: state,
    startupEvents: @startupEvents,
    shutdownEvents: @shutdownEvents
  )
  
  context.execStartupEvents()
  runMainloop(state)
  context.execShutdownEvents()

proc brew*(id: string,
           widget: Widget,
           icons: openArray[string] = [],
           colorScheme: ColorScheme = ColorSchemeDefault,
           startupEvents: openArray[ApplicationEvent] = [],
           shutdownEvents: openArray[ApplicationEvent] = [],
           stylesheets: openArray[Stylesheet] = []) =
  var config = AdwAppConfig(
    widget: widget,
    icons: @icons,
    darkTheme: false,
    colorScheme: colorScheme,
    stylesheets: @stylesheets
  )
  
  var context = AppContext[AdwAppConfig](
    config: config,
    startupEvents: @startupEvents,
    shutdownEvents: @shutdownEvents
  )
  
  proc activateCallback(app: GApplication, data: ptr AppContext[AdwAppConfig]) {.cdecl.} =
    let
      state = setupApp(data[].config)
      window = state.unwrapRenderable().internalWidget
    gtk_window_present(window)
    gtk_application_add_window(app, window)
    
    data[].state = state
    data[].execStartupEvents()

  let app = adw_application_new(id.cstring, G_APPLICATION_FLAGS_NONE)
  defer: g_object_unref(app.pointer)
  
  proc shutdownCallback(app: GApplication, data: ptr AppContext[AdwAppConfig]) {.cdecl.} =
    data[].execShutdownEvents()
  
  discard g_signal_connect(app, "activate", activateCallback, context.addr)
  discard g_signal_connect(app, "shutdown", shutdownCallback, context.addr)
  discard g_application_run(app)
