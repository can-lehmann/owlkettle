# Migrating from Owlkettle 1.x.x to 2.0.0

Owlkettle Version 2.0.0 targets GTK 4 instead of GTK 3.
You will need install the development packages for GTK 4 and libadwaita in order to link owlkettle apps.
You can install them by running `dnf install gtk4-devel libadwaita-devel` on Fedora or `apt install libgtk-4-dev libadwaita-1-dev` on Ubuntu.

## Breaking Changes

- `border_width`: The `border_width` field has been removed. Use the `Box.margin` field instead.
- The `Bin` and `Container` (abstract) widgets were removed.
- The `ModelButton` widget was removed
- When adding widgets to a `Box`, the `fill` property has been removed.
- The default size for dialogs is now the same as the default size of windows
- The `HeaderBar.subtitle` field has been removed. Use `adw.WindowTitle` instead.
- `set_custom_title` has been renamed to `add_title`
- The `HeaderBar.title` field has been remove. The header bar will automatically use the window title.
