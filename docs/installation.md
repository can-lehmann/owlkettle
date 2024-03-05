# Installation

Owlkettle requires GTK 4 to be installed on your system.
Depending on your operating system, you can install GTK 4 using the following commands:

- Fedora: `dnf install gtk4-devel libadwaita-devel`
- Ubuntu: `apt install libgtk-4-dev libadwaita-1-dev`
- Windows (MSYS2): See instructions below

See [the GTK installation guide](https://www.gtk.org/docs/installations/) for more instructions.

We currently recommend installing the development version of owlkettle.

```bash
$ nimble install owlkettle@#head
```

## Properly setting up MSYS2 on Windows

You can install owlkettle on Windows using MSYS2.
Install it from the [official website](https://www.msys2.org/).

You'll need to use a toolchain which includes essential binaries such as compilers, linkers and `pkg-config`.
MSYS2 provides multiple environments, however `CLANG64` is the recommended one when working with Nim.

So, let's start by installing its toolchain:

```bash
$ pacman -Syu mingw-w64-clang-x86_64-toolchain
```

Then add GTK 4 and libadwaita to your environment.

```bash
$ pacman -S mingw-w64-clang-x86_64-gtk4 mingw-w64-clang-x86_64-libadwaita
```

If you encounter any issues, please check out the troubleshooting steps below.
Feel free to ask questions about setting up owlkettle with MSYS2 in [this discussion](https://github.com/can-lehmann/owlkettle/discussions/144). 

### Other environments

If you are an experienced MSYS2 user, you can also install these packages inside other environments.

For the `MINGW64` environment:

```bash
$ pacman -Syu mingw-w64-x86_64-toolchain
$ pacman -S mingw-w64-x86_64-gtk4 mingw-w64-x86_64-libadwaita
```

For the `UCRT64` environment:

```bash
$ pacman -Syu mingw-w64-ucrt-x86_64-toolchain
$ pacman -S mingw-w64-ucrt-x86_64-gtk4 mingw-w64-ucrt-x86_64-libadwaita
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
