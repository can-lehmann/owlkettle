version = "1.3.0"
author = "Can Joshua Lehmann"
description = "A declarative user interface framework based on GTK"
license = "MIT"

requires "nim >= 1.6.0"

import std/strutils

task examples, "Build examples":
  with_dir "examples":
    for file in list_files("."):
      if not file.ends_with(".nim"): continue
      echo "INFO: Compile " & file
      exec "nim c --hints:off --verbosity:0 " & file
      echo "INFO: OK"
      echo "================================================================================"
