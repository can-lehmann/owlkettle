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

import owlkettle, owlkettle/[playground, adw]

viewable App:
  discard

method view(app: AppState): Widget =
  result = gui:
      ShortcutsWindow():
        ShortcutsSection():
          title = "Section1"
          sectionName = "Primary"
          
          ShortcutsGroup():
            title = "Group 1"
            view = "Section1Group1"
            
            ShortcutsShortcut():
              title = "Potato1"
              hotkey = (@[Primary, Shift], "A")
              direction = None
              shortcutType = Accelerator        

            ShortcutsShortcut():
              title = "Potato2"
              hotkey = (@[Primary, Shift], "B")
              direction = None
              shortcutType = Accelerator
              
        ShortcutsSection():
          title = "Section2"
          sectionName = "Secondary"

          ShortcutsGroup():
            title = "Group 2"
            view = "Section2Group2"
            
            ShortcutsShortcut():
              title = "Potato3"
              hotkey = (@[Primary, Shift], "C")
              direction = None
              shortcutType = Accelerator        

            ShortcutsShortcut():
              title = "Potato4"
              hotkey = (@[Primary, Shift], "D")
              direction = None
              shortcutType = Accelerator
      

adw.brew(gui(App()))
