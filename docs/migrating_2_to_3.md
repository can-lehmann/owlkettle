# Migrating from Owlkettle 2.x.x to 3.0.0 (devel)

## Breaking Changes

- The `BaseWidget.style` field now has to be assigned using an array literal (e.g. `style = [ButtonSuggested]`)
  instead of using a set literal (e.g. `style = {ButtonSuggested}`). This change was necessary in order to support
  custom CSS classes. You can add custom CSS classes to widgets like this: `style = [StyleClass("my-css-class")]`.
- `FileChooserDialogState.filename` has been deprecated. Use `filenames` instead.
- The `{.internal.}` pragma has been removed. Use `{.private.}` instead.
  Contrary to `{.internal.}`, `{.private.}` actually does not export the given field.
- The `WindowSurface` widget was renamed to `AdwWindow`. This change was made as part of introducing a new naming scheme where Adwaita widgets with identically named counterparts in GTK will receive the `Adw` prefix to avoid name collisions.
- The compiler flag `-d:adwaita12` was removed. Use `-d:adwminor=<MINOR_VERSION_NUMBER>` (defaults to 0) and/or `-d:adwmajor=<MAJOR_VERSION_NUMBER>` (defaults to 1) instead. This change was necessary to allow more fine-grained control over which Adwaita features are available when compiling for a specific adwaita version.
- The compiler flag `-d:gtk48` was removed. Use `-d:gtkminor=<MINOR_VERSION_NUMBER>` (defaults to 0) instead. This change was necessary to allow more fine-grained control over which features are available when compiling for a specific GTK version.
- The `TextView.changed` event has been removed. Use `TextBuffer.connectChanged` instead.
