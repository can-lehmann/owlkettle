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
  iconName: string = "weather-clear-symbolic"
  title: string = "Some Title"
  name: string = "A name"
  description: string = "An example of a Preferences Page"
  useUnderline: bool = false
  
  likeLevel: string 
  reasonForLikingExample: string
  
  likeOptions: seq[string] = @["A bit", "A lot", "very much", "Fantastic!",  "I love it!"]
  
method view(app: AppState): Widget =
  result = gui:
    Window():
      defaultSize = (800, 600)
      title = "Preferences Page Example"
      HeaderBar {.addTitlebar.}:
        insert(app.toAutoFormMenu(sizeRequest = (400, 250))){.addRight.}

      PreferencesPage():
        iconName = app.iconName
        title = app.title
        name = app.name
        description = app.description
        useUnderline = app.useUnderline
        
        PreferencesGroup:
          title = "First group setting"
          description = "Figuring out how cool this example is"

          ComboRow():
            title = "How much do you like this example?"
            items = app.likeOptions
            
            proc select(selectedIndex: int) =
              app.likeLevel = app.likeOptions[selectedIndex]
        
        PreferencesGroup:
          title = "Second group settings"
          description = "Justifying why this example is so cool"

          EntryRow():
            title = "This example is so cool because:"
            subtitle = "Truly, just show your thoughts"
            text = app.reasonForLikingExample
            
            proc changed(newText: string) =
              app.reasonForLikingExample = newText
        
adw.brew(gui(App()))
