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

# Example contributed by @beef331

import owlkettle
import std/[os, strscans, strutils, algorithm, osproc]

const app_path = "share" / "applications"
let application_paths = [
  "/usr" / app_path,
  get_home_dir() / ".local" / app_path
]

type DesktopFile = ref object
  name, exec, icon: string
  use_terminal: bool

iterator desktop_files(): DesktopFile =
  type ParseVal = enum
    ParsedName, ParsedExec, ParsedUseTerm
  
  for path in application_paths:
    for file in walk_pattern(path / "*.desktop"):
      var
        result = DesktopFile()
        parsed_vals: set[ParseVal]
      for line in lines(file):
        if ParsedName notin parsed_vals and line.scanf("Name=$+", result.name):
          parsed_vals.incl ParsedName
        if ParsedExec notin parsed_vals and line.scanf("Exec=$+ ", result.exec):
          parsed_vals.incl ParsedExec
        var use_term = ""
        if ParsedUseTerm notin parsed_vals and line.scanf("Terminal=$+", use_term):
          if use_term.parse_bool():
            parsed_vals.incl ParsedUseTerm
        discard line.scanf("Icon=$+", result.icon)
      if {ParsedName, ParsedExec}  * parsed_vals == {ParsedName, ParsedExec} and
         ParsedUseTerm notin parsed_vals:
        yield result

func similarity(needle, haystack: string): int =
  for hay_ind, _ in haystack:
    var found = 0
    for needle_ind, need in needle:
      if needle_ind + hay_ind < haystack.len:
        let
          need = need.to_lower_ascii()
          hay = haystack[needle_ind + hay_ind].to_lower_ascii()
        if need == hay:
          dec found
      else:
        break
    result = min(found, result)

viewable App:
  desktop_files: seq[(int, DesktopFile)]

proc get_desktop_files(str: string): seq[(int, DesktopFile)] =
  for desktop_file in desktop_files():
    if str.len > 0:
      let similarity = str.similarity(desktop_file.name)
      if similarity < 0:
        result.add (similarity, desktop_file)
    else:
      result.add (0, desktop_file)

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "App Launcher"
      default_size = (600, 400)
      border_width = 12
      
      proc close() = quit()
      
      Box(orient = OrientY, spacing = 6):
        Entry {.expand: false.}:
          proc changed(str: string) =
            app.desktop_files = str.get_desktop_files()
            app.desktop_files.sort proc(x, y: (int, DesktopFile)): int = cmp(x[0], y[0])

        ScrolledWindow:
          ListBox:
            selection_mode = SelectionNone
            for desktop_file in app.desktop_files:
              ListBoxRow:
                Button:
                  Box(orient = OrientX, spacing = 30):
                    Icon {.expand: false.}:
                      name = desktop_file[1].icon
                      pixel_size = 32
                    Label:
                      text = desktop_file[1].name
                      x_align = 0
                  
                  proc clicked() =
                    discard start_process(desktop_file[1].exec, options = {poEvalCommand})
                    quit(1)

brew(gui(App(desktop_files = get_desktop_files(""))))
