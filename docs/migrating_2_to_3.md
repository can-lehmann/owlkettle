# Migrating from Owlkettle 2.x.x to 3.0.0 (devel)

## Breaking Changes

- `FileChooserDialogState.filename` has been deprecated. Use `filenames` instead.
- The `{.internal.}` pragma has been removed. Use `{.private.}` instead.
  Contrary to `{.internal.}`, `{.private.}` actually does not export the given field.
