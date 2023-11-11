# MIT License
# 
# Copyright (c) 2023 Can Joshua Lehmann
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

import owlkettle, owlkettle/[playground, adw]

viewable App:
  subtitle: string = "a very long subtitle that benefits from expander row showing multiple lines for the subtitle by quite a bit and will be elipsized once the end of that line is reached. Some more text to demonstrate it elipsizing."
  enableExpansion: bool = true
  expanded1: bool = false
  expanded2: bool = false
  showEnableSwitch: bool = false
  titleLines: int = 0
  subtitleLines: int = 2

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "Expander Row Example"
      HeaderBar() {.addTitlebar.}:
        insert(app.toAutoFormMenu()) {.addRight.}
      
      Clamp:
        maximumSize = 500
        margin = 12
        
        PreferencesGroup:
          title = "Preferences Group"
          
          ExpanderRow:
            title = "Expander Row"
            subtitle = app.subtitle
            enableExpansion = app.enableExpansion
            showEnableSwitch = app.showEnableSwitch
            titleLines = app.titleLines
            expanded = app.expanded1
            subtitleLines = app.subtitleLines
            
            proc expand(hasExpanded: bool) =
              echo "Expanding First Expander: ", hasExpanded
              app.expanded1 = hasExpanded
            
            for it in 0..<3:
              ActionRow {.addRow.}:
                title = "Nested Row " & $it
          
          ExpanderRow:
            title = "Expander Row"
            subtitle = "with actions"
            enableExpansion = app.enableExpansion
            showEnableSwitch = app.showEnableSwitch
            titleLines = app.titleLines
            subtitleLines = app.subtitleLines
            expanded = app.expanded2
            
            proc expand(hasExpanded: bool) =
              echo "Expanding Second Expander: ", hasExpanded
              app.expanded2 = hasExpanded
              
            Button {.addAction.}:
              text = "Action"
            
            for it in 0..<3:
              ActionRow {.addRow.}:
                title = "Nested Row " & $it

adw.brew(gui(App()))
