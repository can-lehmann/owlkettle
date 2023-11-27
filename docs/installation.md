# Installation

Owlkettle requires GTK 4 to be installed on your system.
Depending on your operating system, you can install GTK 4 using the following commands:

- Fedora: `dnf install gtk4-devel libadwaita-devel`
- Ubuntu: `apt install libgtk-4-dev libadwaita-1-dev`
- Windows (Msys2): `pacman -S mingw-w64-x86_64-gtk4 mingw-w64-x86_64-libadwaita`

See [the GTK installation guide](https://www.gtk.org/docs/installations/) for more instructions.

We currently recommend installing the development version of owlkettle.

```bash
$ nimble install owlkettle@#head
```

## Troubleshooting

1. Ensure that `pkg-config` is installed and the output of the following command includes `-lgtk-4`.
  ```bash
  pkg-config --libs gtk4
  ```

### Properly setting up MSYS2 on Windows

If you want to make sure you have the `pkg-config` in your system, 
you need to install your MSYS2's environment toolchain.

The 2 noteworthy toolchain provided by the MSYS2 are:
A) CLANG64: the recommended one for Nim
B) UCRT64: the recommended one by default for most projects

You can choose one of them by using these commands:

```bash
$ pacman --sync --refresh --sysupgrade mingw-w64-clang-x86_64-toolchain  # CLANG64
$ pacman --sync --refresh --sysupgrade mingw-w64-ucrt-x86_64-toolchain   # UCRT64
```

Feel free to ask questions about the MSYS2 setup in [How to properly set-up your MSYS2 #144](https://github.com/can-lehmann/owlkettle/discussions/144). 


## Known Incompatibilities

- When using Nim 1.6.12 or 1.6.14 with ARC/ORC, the Nim code generator produces invalid C code.
  This issue has been fixed in the development version of the Nim compiler.
  The other garbage collectors work as expected.
