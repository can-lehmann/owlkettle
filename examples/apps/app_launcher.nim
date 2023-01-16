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

# This example was originally contributed by @beef331

import owlkettle
import std/[os, strscans, strutils, algorithm, osproc, sequtils, sugar]
when defined(nimPreviewSlimSystem):
  import std/[assertions, syncio]

const appPath = "share" / "applications"
let applicationPaths = [
  "/usr" / appPath,
  getHomeDir() / ".local" / appPath
]

type DesktopFile = ref object
  name, exec, icon: string
  useTerminal: bool

iterator desktopFiles(): DesktopFile =
  type ParseVal = enum
    ParsedName, ParsedExec, ParsedUseTerm
  
  for path in applicationPaths:
    for file in walkPattern(path / "*.desktop"):
      var
        result = DesktopFile()
        parsedVals: set[ParseVal]
      for line in lines(file):
        if ParsedName notin parsedVals and line.scanf("Name=$+", result.name):
          parsedVals.incl ParsedName
        if ParsedExec notin parsedVals and line.scanf("Exec=$+ ", result.exec):
          parsedVals.incl ParsedExec
        var useTerm = ""
        if ParsedUseTerm notin parsedVals and line.scanf("Terminal=$+", useTerm):
          if useTerm.parseBool():
            parsedVals.incl ParsedUseTerm
        discard line.scanf("Icon=$+", result.icon)
      if {ParsedName, ParsedExec}  * parsedVals == {ParsedName, ParsedExec} and
         ParsedUseTerm notin parsedVals:
        yield result

viewable SearchList:
  query: string
  children: seq[(string, Widget)]

func similarity(needle, haystack: string): int =
  if needle.len == 0:
    return 0
  result = low(int)
  for hayInd, _ in haystack:
    var found = -hayInd
    for needleInd, need in needle:
      if needleInd + hayInd >= haystack.len:
        break
      let
        need = need.toLowerAscii()
        hay = haystack[needleInd + hayInd].toLowerAscii()
      if need == hay:
        found += 1
    if found > -hayInd:
      result = max(found, result)

method view(list: SearchListState): Widget =
  var children = list.children.mapIt((list.query.similarity(it[0]), it[1]))
  children.sort((x, y) => cmp(y[0], x[0]))
  result = gui:
    ListBox:
      for (similarity, child) in children:
        if similarity > low(int):
          insert child

proc add(list: SearchList, child: Widget, name: string = "") =
  list.hasChildren = true
  list.valChildren.add((name, child))

viewable App:
  desktopFiles: seq[DesktopFile]
  query: string

proc sortDefault(desktopFiles: var seq[DesktopFile]) =
  desktopFiles.sort((x, y) => cmp(x.name.toLowerAscii(), y.name.toLowerAscii()))

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "App Launcher"
      defaultSize = (600, 400)
      
      HeaderBar {.addTitlebar.}:
        Entry {.addTitle, expand: true.}:
          placeholder = "Search..."
          width = 30
          proc changed(query: string) =
            app.query = query
      
      ScrolledWindow:
        SearchList:
          query = app.query
          
          for desktopFile in app.desktopFiles:
            Button {.name: desktopFile.name.}:
              Box(orient = OrientX, spacing = 12):
                Icon {.expand: false.}:
                  name = desktopFile.icon
                  pixelSize = 32
                Label:
                  text = desktopFile.name
                  xAlign = 0
              
              proc clicked() =
                discard startProcess(desktopFile.exec, options = {poEvalCommand})
                quit()

brew(gui(App(desktopFiles = toSeq(desktopFiles()).dup(sortDefault))))
