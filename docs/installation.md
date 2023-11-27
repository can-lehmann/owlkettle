# Installation

Owlkettle requires GTK 4 to be installed on your system.
Depending on your operating system, you can install GTK 4 using the following commands:

- Fedora: `dnf install gtk4-devel libadwaita-devel`
- Ubuntu: `apt install libgtk-4-dev libadwaita-1-dev`

See [the GTK installation guide](https://www.gtk.org/docs/installations/) for more instructions.

We currently recommend installing the development version of owlkettle.

```bash
$ nimble install owlkettle@#head
```

## Properly setting up MSYS2 on Windows

For the Windows OS you'll need the MSYS2 
that you can install from their [official website](https://www.msys2.org/).

Then, you'll need to use a toolchain with essential binaries as compilers, linkers 
and the `pkg-config` as well.

There are 2 noteworthy toolchain provided by the MSYS2:

A) `CLANG64`: the recommended one for Nim

```bash
$ pacman -Syu mingw-w64-clang-x86_64-toolchain
```

B) `UCRT64`: the recommended one by default for most projects

```bash
$ pacman -Syu mingw-w64-ucrt-x86_64-toolchain
```

Then add the GTK-4 and LibAdwaita to your environment.

A) For `CLANG64`
```bash
$ pacman -S mingw-w64-clang-x86_64-gtk4 mingw-w64-clang-x86_64-libadwaita
```

B) For `UCRT64`

```bash
$ pacman -S mingw-w64-ucrt-x86_64-gtk4 mingw-w64-ucrt-x86_64-libadwaita
```

Feel free to ask questions about the MSYS2 setup in [How to properly set-up your MSYS2 #144](https://github.com/can-lehmann/owlkettle/discussions/144). 

## Troubleshooting

1. Ensure that `pkg-config` is installed and the output of the following command includes `-lgtk-4`.
  ```bash
  pkg-config --libs gtk4
  ```


## Known Incompatibilities

- When using Nim 1.6.12 or 1.6.14 with ARC/ORC, the Nim code generator produces invalid C code.
  This issue has been fixed in the development version of the Nim compiler.
  The other garbage collectors work as expected.
