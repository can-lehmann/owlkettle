# Cross Compiling Owlkettle on Linux to Windows


## Dynamic linking
Depending on your distribution this can be slightly more involved.
If you do not use a Debian derived distro check your package registry for `mingw-gtk3.0` or a similarly named package.

For Fedora the package is named `mingw64-gtk3.0`.
For Arch the package is named `mingw-w64-gtk3`.

### If you do not have `mingw-gtk` package in your package repository
You first either need to build the libraries yourself or fetch [prebuilt](https://github.com/qarmin/gtk_library_store/releases) ones.

After you get the libraries you will now need to make a `config.nims` file.
In this example the mingw-gtk library was extracted at the root of the project to a folder named `mingw64`.
Inside the `config.nims` place the following:
```nim
when defined mingw:
  --passL:"-L mingw64/lib"
```

### Distributing
Copy all the `.dll`s from `mingw` and place them next to your `.exe` and archive them using your favourite archiver.
You now should be able to easily ship the archive.


## Static linking
If you can get cross compilation statically linked, feel free to PR a writeup here.
