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


import owlkettle
import std/[os, strscans, strutils, algorithm, osproc]

const
  appPath = "share" / "applications"
  iconPath = "share" / "icons"

let
  applicationPaths = [
    "/usr" / appPath,
    getHomeDir() / ".local" / appPath
  ]
  iconPaths = [
    getHomeDir() / ".icon",
    getHomeDir() / ".local" / iconPath,
    "/usr" / iconPath
  ]

type DesktopFile = ref object
  name, exec, icon: string
  useTerminal: bool

iterator desktopFiles: DesktopFile =
  type ParseVal = enum
    parsedName, parsedExec, parsedUseTerm
  for path in applicationPaths:
    for file in walkPattern(path / "*.desktop"):
      var
        result = DesktopFile()
        parsedVals: set[ParseVal]
      for line in lines(file):
        if parsedName notin parsedVals and line.scanf("Name=$+", result.name):
          parsedVals.incl parsedName
        if parsedExec notin parsedVals and line.scanf("Exec=$+ ", result.exec):
          parsedVals.incl parsedExec
        var useTerm = ""
        if parsedUseTerm notin parsedVals and line.scanf("Terminal=$+", useTerm):
          if useTerm.parseBool():
            parsedVals.incl parsedUseTerm
        discard line.scanf("Icon=$+", result.icon)
      if {parsedName, parsedExec}  * parsedVals == {parsedName, parsedExec} and parsedUseTerm notin parsedVals:
        yield result


func similarity(needle, haystack: string): int =
  for hayInd, _ in haystack:
    var found = 0
    for needleInd, need in needle:
      if needleInd + hayInd < haystack.len:
        let
          need = need.toLowerAscii()
          hay = haystack[needleInd + hayInd].toLowerAscii()
        if need == hay:
          dec found
      else:
        break
    result = min(found, result)

viewable App:
  desktopFiles: seq[(int, DesktopFile)]


proc getDesktopFiles(str: string): seq[(int, DesktopFile)] =
  for desktopFile in desktopFiles():
    if str.len > 0:
      let similarity = str.similarity(desktopFile.name)
      if similarity < 0:
        result.add (similarity, desktopFile)
    else:
      result.add (0, desktopFile)

method view(app: AppState): Widget =
  result = gui:
    Window:
      defaultSize = (600, 400)
      borderWidth = 10
      Box(orient = OrientY):
        Entry{.expand: false.}:
          proc changed(str: string) =
            app.desktopFiles = str.getDesktopFiles()
            app.desktopFiles.sort proc(x, y: (int, DesktopFile)): int = cmp(x[0], y[0])

        ScrolledWindow:
          ListBox:
            selectionMode = SelectionNone
            for desktopFile in app.desktopFiles:
              ListBoxRow:
                Button:
                  Box(orient = OrientX, spacing = 30):
                    Icon{.expand: false.}:
                      name = desktopFile[1].icon
                      pixelSize = 32
                    Label:
                      text = desktopFile[1].name
                      xAlign = 0
                  proc clicked() =
                    discard startProcess(desktopFile[1].exec, options = {poEvalCommand})
                    quit(1)

brew(gui(App(desktopFiles = getDesktopFiles(""))))
