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
    Window:
      title = "ShortcutsWindow Example"
      defaultSize = (500, 100)
      
      HeaderBar {.addTitlebar.}:
        Button {.addRight.}:
          text = "Shortcuts"
          style = [ButtonFlat]
          proc clicked() =
            discard app.open: gui:
              ShortcutsWindow():
                modal = true

                ShortcutsSection():
                  title = "Editor Shortcuts"
                  sectionName = "editor"
                  
                  ShortcutsGroup():
                    title = "General"
                    
                    ShortcutsShortcut():
                      title = "Global Search"
                      shortcutType = Accelerator        
                      hotkey = (@[Primary], "period")

                    ShortcutsShortcut():
                      title = "Preferences"
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "comma")
                      
                  ShortcutsGroup():
                    title = "Panels"
                    
                    ShortcutsShortcut():
                      title = "Toggle left panel"
                      shortcutType = Accelerator
                      accelerator = "F9"
                      
                    ShortcutsShortcut():
                      title = "Toggle right panel"
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "F9")
                  
                  ShortcutsGroup():
                    title = "Touchpad gestures"
                    
                    ShortcutsShortcut():
                      shortcutType = GestureTwoFingerSwipeRight
                      title = "Switch to the next document"

                    ShortcutsShortcut():
                      shortcutType = GestureTwoFingerSwipeRight
                      title = "Switch to the previous document"
                  
                  ShortcutsGroup():
                    title = "Files"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "n")
                      title = "Create new document"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "o")
                      title = "Open a document"
                      
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "s")
                      title = "Save the document"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "w")
                      title = "Close the document" 
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Alt], "Page_Down")
                      title = "Switch to the next Document"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Alt], "Page_Up")
                      title = "Switch to the previous Document"
                  
                  ShortcutsGroup():
                    title = "Find and replace"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "f")
                      title = "Find"     
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Shift], "g")
                      title = "Find the previous match"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Shift], "k")
                      title = "Clear highlight"
                  
                  ShortcutsGroup():
                    title = "Copy and Paste"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "c")
                      title = "Copy selected text to clipboard"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "x")
                      title = "Cut selected text to clipboard"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "b")
                      title = "Paste text to clipboard"
                  
                  ShortcutsGroup():
                    title = "Undo and Redo"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "z")
                      title = "Undo previous command"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Shift], "z")
                      title = "Redo previous command"
                  
                  ShortcutsGroup():
                    title = "Undo and Redo"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Shift], "a")
                      title = "Increment number at cursor"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Shift], "x")
                      title = "Decrement number at cursor"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Shift], "j")
                      title = "Join selected lines"
                              
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "space")
                      title = "Show completion window"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      accelerator = "Insert"
                      title = "Toggle Overwrite"
                      
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Alt], "i")
                      title = "Reindent line"
                
                  ShortcutsGroup():
                    title = "Navigation"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Alt], "n")
                      title = "Move to next error in file"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Alt], "p")
                      title = "Move to previous error in file"
                          
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Shift, Alt], "Left")
                      title = "Move to previous edit location"
                                
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Shift, Alt], "Right")
                      title = "Move to next edit location"
                                
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Alt], "period")
                      title = "Jump to definition of symbol"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Alt, Shift], "Up")
                      title = "Move sectionport up within the file"
                  
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Alt, Shift], "Down")
                      title = "Move sectionport down within the file"
                  
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Alt, Shift], "End")
                      title = "Move sectionport to end of file"
                  
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Alt, Shift], "Home")
                      title = "Move sectionport to beginning of file"
                          
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "percent")
                      title = "Move to matching bracket"
                
                  ShortcutsGroup():
                    title = "Selections"
                    
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "a")
                      title = "Select all"
                                
                    ShortcutsShortcut():
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "backslash")
                      title = "Unselect all"
                  
                ShortcutsSection():
                  maxHeight = 16
                  title = "Terminal Shortcuts"
                  sectionName = "terminal"
                  
                  ShortcutsGroup():
                    title = "General"
                    
                    ShortcutsShortcut():
                      title = "Global Search"
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "period")
                    
                    ShortcutsShortcut():
                      title = "Preferences"
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "comma")
                                  
                    ShortcutsShortcut():
                      title = "Command Bar"
                      shortcutType = Accelerator
                      hotkey = (@[Primary], "Return")
                                                
                    ShortcutsShortcut():
                      title = "Terminal"
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Shift], "t")

                    ShortcutsShortcut():
                      title = "Keyboard Shortcuts"
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Shift], "question")
                  
                  ShortcutsGroup():
                    title = "Copy and Paste"
                    
                    ShortcutsShortcut():
                      title = "Copy selected text to clipboard"
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Shift], "c")          
                    
                    ShortcutsShortcut():
                      title = "Paste text from clipboard"
                      shortcutType = Accelerator
                      hotkey = (@[Primary, Shift], "v")          
                  
                  ShortcutsGroup():
                    title = "Switching"
                    
                    ShortcutsShortcut():
                      title = "Switch to the n-th tab"
                      shortcutType = Accelerator
                      hotkey = (@[Alt], "1...9")
                  
                  ShortcutsGroup():
                    title = "'Special' combinations"
                    
                    ShortcutsShortcut():
                      title = "You want tea?"
                      shortcutType = Accelerator
                      hotkey = (@[], "t+t")
                                
                    ShortcutsShortcut():
                      title = "Shift Control?"
                      shortcutType = Accelerator
                      hotkey = (@[Shift, Ctrl], "")
                                
                    ShortcutsShortcut():
                      title = "Control Control"
                      shortcutType = Accelerator
                      accelerator = "<ctrl>&<ctrl>"
                                
                    ShortcutsShortcut():
                      title = "Left and right control"
                      shortcutType = Accelerator
                      accelerator = "Control_L&Control_R"
                  
                  ShortcutsGroup():
                    title = "All gestures"
                    
                    ShortcutsShortcut():
                      title = "A stock pinch gesture"
                      shortcutType = GesturePinch            
                    
                    ShortcutsShortcut():
                      title = "A stock stretch gesture"
                      shortcutType = GestureStretch            
                    
                    ShortcutsShortcut():
                      title = "A stock rotation gesture"
                      shortcutType = GestureRotateClockwise            
                    
                    ShortcutsShortcut():
                      title = "A stock rotation gesture"
                      shortcutType = GestureRotateCounterClockwise            
                    
                    ShortcutsShortcut():
                      title = "A stock swipe gesture"
                      shortcutType = GestureTwoFingerSwipeLeft            
                    
                    ShortcutsShortcut():
                      title = "A stock swipe gesture"
                      shortcutType = GestureTwoFingerSwipeRight            
                    
                    ShortcutsShortcut():
                      title = "A stock swipe gesture"
                      shortcutType = GestureSwipeLeft  
                    
                    ShortcutsShortcut():
                      title = "A stock swipe gesture"
                      shortcutType = GestureSwipeRight
                    
adw.brew(gui(App()))
