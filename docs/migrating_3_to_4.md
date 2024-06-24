# Migrating from Owlkettle 3.x.x to 4.0.0 (devel)

## Breaking Changes

- `ListBoxRow` widgets are no longer handled by the `ListBox.add` adder.
  Instead they can be added to a `ListBox` using the `addRow` adder.
- Nim 1.x.x is no longer supported, use at least Nim 2.0.0.
