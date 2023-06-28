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

## Known Incompatibilities

- When using Nim 1.6.12 or 1.6.14 with ARC/ORC, the Nim code generator produces invalid C code.
  This issue has been fixed in the development version of the Nim compiler.
  The other garbage collectors work as expected.
