version = "2.1.0"
author = "Can Joshua Lehmann"
description = "A declarative user interface framework based on GTK"
license = "MIT"

requires "nim >= 1.6.0"

import std/strutils

proc findExamples(path: string): seq[string] =
  for file in listFiles(path):
    if file.endsWith(".nim"):
      result.add(file)
  for dir in listDirs(path):
    result.add(findExamples(dir))

task examples, "Build examples":
  withDir "examples":
    for file in findExamples("."):
      echo "INFO: Compile " & file
      exec "nim c --hints:off --verbosity:0 " & file
      echo "INFO: OK"
      echo "================================================================================"

task genDocs, "Generate owlkettle docs":
  exec "make -C docs"

task setupBook, "Compiles the nimibook CLI-binary used for generating the docs":
  exec "nimble install -y nimib@#head nimibook@#head"
  exec "nim c -d:release --mm:refc nbook.nim"

task genBook, "Generate the owlkettle nimibook book docs":
  exec "nimble setupBook"
  echo "BOOK-CLI-GENERATED"

  exec "nimble genDocs"
  echo "WIDGETS-DOCS-GENERATED"

  exec "./nbook --mm:refc init"
  echo "INITIALIZED NIMIBOOK"

  try:
    exec "./nbook --mm:refc build"
    echo "BUILT NIMIBOOK"
  except CatchableError:
    discard

  ## Needed as the nimibook will serve these images, while the raw md files 
  ## in the repository will serve the others 
  exec "cp -r ./docs/assets ./compiledBook/docs"