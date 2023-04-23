# Cross-Compiling Owlkettle Apps on Linux to Windows

# Warning: This document has not been updated for Owlkettle 2.0.0

## Dynamic linking

Depending on your distribution this can be slightly more involved.

### Debian/Ubuntu

You first either need to build the libraries yourself or fetch [prebuilt](https://github.com/qarmin/gtk_library_store/releases) (not verified; use at your own risk) ones.

After you get the libraries you will now need to make a `config.nims` file.
In this example the mingw-gtk library was extracted at the root of the project to a folder named `mingw64`.
Inside the `config.nims` place the following:

```nim
when defined mingw:
  --passL:"-L mingw64/lib"
```

You can now compile your app using:

```bash
nim compile -d:mingw <my_app>
```

### Fedora

For cross-compiling on Fedora the `mingw64-gtk3` package is required.

```bash
sudo dnf install mingw32-gtk3
sudo dnf install mingw64-gtk3
nim compile -d:mingw <my_app>
```

### Other

If you do not use any of the distributions explicitly listed here, check your package registry for `mingw-gtk3` or a similarly named package.
For example on Arch the package is called `mingw-w64-gtk3`.

Check out [the Nim Compiler User Guide](https://nim-lang.org/docs/nimc.html#crossminuscompilation-for-windows) for more information on cross-compilation in general.

## Distributing

Follow this process:

```shell
# ldd takes the necessary dlls and grep looks for `/mingw`'s libs...
$ ldd bin/myapp.exe | grep '\/mingw.*\.dll' -o | xargs -I{} cp "{}" ./bin

# Then copy some files
$ cp -r /mingw64/lib/gdk-pixbuf-2.0 ./bin/lib/gdk-pixbuf-2.0
$ cp -r /mingw64/share/icons/* ./bin/share/icons/
$ cp /mingw64/share/glib-2.0/schemas/* ./bin/share/glib-2.0/schemas/

# And compile local schemas
$ glib-compile-schemas.exe ./bin/share/glib-2.0/schemas/
```

Note that `*.dll`, `lib/**` and `share/**` are placed next to your `*.exe`.

You now should be able to easily ship the archive, even on Windows.
Also, you can create `tasks` to each step inside your `*.nimble` or `*.nims` file if you want.

If you're using *Adwaita*, don't forget to declare this in your `config.nims` file:

```nims
--define:adwaita12
```

You can read a bit more about it [at this discussion (#57)](https://github.com/can-lehmann/owlkettle/discussions/57)

## Static linking

If you can get cross-compilation statically linked, feel free to PR a writeup here.
