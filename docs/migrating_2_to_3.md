# Migrating from Owlkettle 2.x.x to 3.0.0 (devel)

## Breaking Changes

- The `BaseWidget.style` field now has to be assigned using an array literal (e.g. `style = [ButtonSuggested]`)
  instead of using a set literal (e.g. `style = {ButtonSuggested}`). This change was necessary in order to support
  custom CSS classes. You can add custom CSS classes to widgets like this: `style = [StyleClass("my-css-class")]`.
- `FileChooserDialogState.filename` has been deprecated. Use `filenames` instead.
- The `{.internal.}` pragma has been removed. Use `{.private.}` instead.
  Contrary to `{.internal.}`, `{.private.}` actually does not export the given field.
- The `WindowSurface` Widget was renamed `AdwWindow`. This change was made as part of introducing a new naming scheme where Adwaita Widgets with identically named counterparts in Gtk will receive the `Adw` prefix to avoid name collisions.