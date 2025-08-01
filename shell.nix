with import <nixpkgs> { };

mkShell {
  nativeBuildInputs = [
    pkg-config
    gtk4
    libadwaita
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath [
    gtk4.dev
    libadwaita.dev
  ];
}
