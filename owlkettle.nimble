version = "2.2.0"
author = "Can Joshua Lehmann"
description = "A declarative user interface framework based on GTK"
license = "MIT"

requires "nim >= 1.6.0"

import std/[strformat, strutils]

proc findExamples(path: string): seq[string] =
  for file in listFiles(path):
    if file.endsWith(".nim"):
      result.add(file)
  for dir in listDirs(path):
    result.add(findExamples(dir))

task examples, "Build examples":
  when defined(github):
    # Can not compile because they rely on an adwaita version higher than available in test-image of CI pipeline
    let uncompileable: seq[string] = @[
      "widgets/adw/banner.nim",
      "widgets/adw/entry_row.nim",
      "widgets/adw/switch_row.nim",
      "widgets/adw/button_content.nim"
    ]
    let adwaitaFlag = ""
  else:
    let uncompileable: seq[string] = @[] # You should be able to run any example locally assuming you have an up-to-date system.
    let adwaitaFlag = "-d:adwminor=4"
  
  withDir "examples":
    for file in findExamples("."):
      if file in uncompileable:
        continue
        
      let compileCommand = fmt"nim c --hints:off --path:.. --verbosity:0 {adwaitaFlag} {file}" 
      echo "INFO: Compile " & file
      echo compileCommand
      exec compileCommand
      echo "INFO: OK"
      echo "================================================================================"

task genDocs, "Generate owlkettle wigets.md file from widgets.nim":
  exec "make -C docs"

task setupBook, "Compiles the nimibook CLI-binary used for generating the docs":
  exec "nimble install -y nimib@#head nimibook@#head markdown@0.8.5"
  exec "nim c -d:release --mm:refc nbook.nim"

task genBook, "Generate the owlkettle nimibook book docs":
  exec "nimble setupBook"
  echo "BOOK-CLI-GENERATED"

  exec "nimble genDocs"
  echo "WIDGETS-DOCS-GENERATED"

  exec "./nbook --mm:refc init"
  echo "INITIALIZED NIMIBOOK"

  exec "./nbook build --mm:refc --define:owlkettleNimiDocs --path:."
  echo "BUILT NIMIBOOK"

  ## Needed as the nimibook will serve the copied images, while the raw md files
  ## in the repository will serve the originals
  exec "cp -r ./docs/assets ./compiledBook/docs"
