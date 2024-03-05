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

import owlkettle, owlkettle/[adw, playground]

viewable App:
  sensitive: bool = true
  sizeRequest: tuple[x, y: int] = (-1, 300) 
  tooltip: string = "" 
  
  emoji: string = "😀️"

method view(app: AppState): Widget =
  result = gui:
    Window:
      defaultSize = (450, 350)
      title = "Emoji Chooser Example"
      
      HeaderBar {.addTitlebar.}:
        style = [HeaderBarFlat]
        insert(app.toAutoFormMenu(sizeRequest = (400, 250), ignoreFields = @["emoji"])) {.addRight.}
      
      Box:
        margin = 12
        
        Box {.hAlign: AlignCenter, vAlign: AlignCenter.}:
          orient = OrientY
          spacing = 6
          
          Label {.expand: false.}:
            text = app.emoji
            style = [StyleClass("emoji-preview")]
          
          MenuButton {.expand: false.}:
            text = "Choose"
            style = [ButtonSuggested]
            
            EmojiChooser:
              sensitive = app.sensitive
              sizeRequest = app.sizeRequest
              tooltip = app.tooltip
              
              proc emojiPicked(newEmoji: string) =
                echo "New Emoji: ", newEmoji
                app.emoji = newEmoji
  
adw.brew(gui(App()),
  stylesheets=[newStylesheet("""
    .emoji-preview {
      font-size: 100px;
    }
  """)]
)
