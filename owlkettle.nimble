version = "2.2.0"
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