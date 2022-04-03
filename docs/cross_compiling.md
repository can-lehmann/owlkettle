# Cross-Compiling Owlkettle Apps on Linux to Windows

## Dynamic linking

Depending on your distribution this can be slightly more involved.

### Debian/Ubuntu

You first either need to build the libraries yourself or fetch [prebuilt](https://github.com/qarmin/gtk_library_store/releases) ones.

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

Copy all the `.dll`s from `mingw`, place them next to your `.exe` and archive them using your favourite archiver.
You now should be able to easily ship the archive.

## Static linking

If you can get cross-compilation statically linked, feel free to PR a writeup here.
