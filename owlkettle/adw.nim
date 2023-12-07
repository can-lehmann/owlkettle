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
import widgetdef, widgets, mainloop, widgetutils
import ./bindings/[adw, gtk]
import std/[strutils, sequtils, strformat, options, sugar]

export adw.StyleManager
export adw.ColorScheme
export adw.FlapFoldPolicy
export adw.FoldThresholdPolicy
export adw.FlapTransitionType
export adw.CenteringPolicy
export adw.AdwVersion

when defined(owlkettleDocs) and isMainModule:
  echo "# Libadwaita Widgets\n\n"

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
  canShrink: bool ## Defines whether the ButtonContent can be smaller than the size of its contents. Only available for adwaita version 1.3 or higher. Does nothing if set when compiled for lower adwaita versions.
  
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
      when AdwVersion >= (1, 4):
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

when AdwVersion >= (1, 2) or defined(owlkettleDocs):
  renderable EntryRow of PreferencesRow:
    suffixes: seq[AlignedChild[Widget]]
    text: string
    
    proc changed(text: string)
    
    hooks:
      beforeBuild:
        when AdwVersion >= (1, 2):
          state.internalWidget = adw_entry_row_new()
        else:
          raise newException(ValueError, "Compile for Adwaita version 1.2 or higher with -d:adwMinor=2 to enable the EntryRow widget.")
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
        when AdwVersion >= (1, 2):
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
  
  renderable PasswordEntryRow of EntryRow:
    ## An `EntryRow` that hides the user input
    
    hooks:
      beforeBuild:
        when AdwVersion >= (1, 2):
          state.internalWidget = adw_password_entry_row_new()
    
    example:
      PasswordEntryRow:
        title = "Password"
        text = app.password
        
        proc changed(password: string) =
          app.password = password
  
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

renderable AdwHeaderBar of BaseWidget:
  ## Adwaita Headerbar that combines GTK Headerbar and WindowControls.
  packLeft: seq[Widget]
  packRight: seq[Widget]
  centeringPolicy: CenteringPolicy = CenteringPolicyLoose
  decorationLayout: Option[string] = none(string)
  showRightButtons: bool = true ## Determines whether the buttons in `rightButtons` are shown. Does not affect Widgets in `packRight`.
  showLeftButtons: bool = true ## Determines whether the buttons in `leftButtons` are shown. Does not affect Widgets in `packLeft`.
  titleWidget: Widget ## A widget for the title. Replaces the title string, if there is one.
  showBackButton: bool = true
  showTitle: bool = true ## Determines whether to show or hide the title
  
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
      when AdwVersion >= (1, 4):
        adw_header_bar_set_show_back_button(state.internalWidget, state.showBackButton.cbool)
  
  hooks showTitle:
    property:
      when AdwVersion >= (1, 4):
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

when AdwVersion >= (1, 2) or defined(owlkettleDocs):
  renderable AboutWindow:
    applicationName: string
    developerName: string
    version: string
    supportUrl: string
    issueUrl: string
    website: string
    copyright: string
    license: string
    
    hooks:
      beforeBuild:
        when AdwVersion >= (1, 2):
          state.internalWidget = adw_about_window_new()
    
    hooks applicationName:
      property:
        when AdwVersion >= (1, 2):
          adw_about_window_set_application_name(state.internalWidget, state.applicationName.cstring)

    hooks developerName:
      property:
        when AdwVersion >= (1, 2):
          adw_about_window_set_developer_name(state.internalWidget, state.developerName.cstring)

    hooks version:
      property:
        when AdwVersion >= (1, 2):
          adw_about_window_set_version(state.internalWidget, state.version.cstring)

    hooks supportUrl:
      property:
        when AdwVersion >= (1, 2):
          adw_about_window_set_support_url(state.internalWidget, state.supportUrl.cstring)

    hooks issueUrl:
      property:
        when AdwVersion >= (1, 2):
          adw_about_window_set_issue_url(state.internalWidget, state.issueUrl.cstring)
    
    hooks website:
      property:
        when AdwVersion >= (1, 2):
          adw_about_window_set_website(state.internalWidget, state.website.cstring)

    hooks copyright:
      property:
        when AdwVersion >= (1, 2):
          adw_about_window_set_copyright(state.internalWidget, state.copyright.cstring)

    hooks license:
      property:
        when AdwVersion >= (1, 2):
          adw_about_window_set_license(state.internalWidget, state.license.cstring)
  
  export AboutWindow

when AdwVersion >= (1, 4) or defined(owlkettleDocs):
  renderable SwitchRow of ActionRow:
    active: bool    
    
    proc activated(active: bool)
    
    hooks:
      beforeBuild:
        when AdwVersion >= (1, 4):
          state.internalWidget = adw_switch_row_new()
      connectEvents:
        when AdwVersion >= (1, 4):
          proc activatedCallback(widget: GtkWidget, data: ptr EventObj[proc (active: bool)]) {.cdecl.} =
            let active: bool = adw_switch_row_get_active(widget).bool
            SwitchRowState(data[].widget).active = active
            data[].callback(active)
            data[].redraw()
            
          state.connect(state.activated, "activated", activatedCallback)
      disconnectEvents:
        when AdwVersion >= (1, 4):
          state.internalWidget.disconnect(state.activated)
    
    hooks active:
      property:
        when AdwVersion >= (1, 4):
          adw_switch_row_set_active(state.internalWidget, state.active.cbool)
    
  export SwitchRow
  
when AdwVersion >= (1, 3) or defined(owlkettleDocs):
  renderable Banner of BaseWidget:
    ## A rectangular Box taking up the entire vailable width with an optional button.
    buttonLabel: string ## Label of the optional banner button. Button will only be added to the banner if this Label has a value.
    title: string
    useMarkup: bool = true ## Determines whether using Markup in title is allowed or not.
    revealed: bool = true ## Determines whether the banner is shown.
    
    proc clicked() ## Triggered by clicking the banner button
    
    hooks:
      beforeBuild:
        when AdwVersion >= (1, 3):
          state.internalWidget = adw_banner_new("".cstring)
      connectEvents:
        when AdwVersion >= (1, 3):
          state.connect(state.clicked, "button-clicked", eventCallback)
      disconnectEvents:
        when AdwVersion >= (1, 3):
          state.internalWidget.disconnect(state.clicked)
    hooks buttonLabel:
      property:
        when AdwVersion >= (1, 3):
          adw_banner_set_button_label(state.internalWidget, state.buttonLabel.cstring)
    
    hooks title:
      property:
        when AdwVersion >= (1, 3):
          adw_banner_set_title(state.internalWidget, state.title.cstring)
    
    hooks useMarkup:
      property:
        when AdwVersion >= (1, 3):
          adw_banner_set_use_markup(state.internalWidget, state.useMarkup.cbool)
  
    hooks revealed:
      property:
        when AdwVersion >= (1, 3):
          adw_banner_set_revealed(state.internalWidget, state.revealed.cbool)
  export Banner

export AdwWindow, WindowTitle, AdwHeaderBar, Avatar, ButtonContent, Clamp, PreferencesGroup, PreferencesRow, ActionRow, ExpanderRow, ComboRow, Flap, SplitButton, StatusPage

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
