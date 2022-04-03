# Contributing to Owlkettle

## Documentation

When adding a new widget or modifying an existing widget, you will need to update the widget documentation.
Since it is automatically generated from the `owlkettle/widgets.nim` module, running the following commands from the project folder will update the documentation to reflect any changed you made to the widgets.

```bash
nim compile -d:owlkettle_docs -o:build_docs owlkettle
./build_docs > docs/widgets.md
```

**Note:** Please do never change the `docs/widgets.md` file manually.
Any changes you make will be removed once it is generated the next time.

### Examples

You can add examples for how to use a widget by using the `example` widget property:

```nim
renderable MyWidget:
  text: string
  
  example:
    MyWidget:
      text = "Hello, world!"
```

All examples you add to widgets in this way will also be included in the widget documentation the next time you regenerate it.

## Style Guide

### Identifiers

Owlkettle uses `snake_case` instead of `camelCase` for identifiers.
The names of types and widgets are in `PascalCase`.

### Procedure Calls

Since there are multiple ways to call procedures in nim, it is necessary to have some guidelines on when to use which syntax.
Please note that these are general guidelines and there are exceptions for some specific cases.

Generally `my_object.do_something(argument1, ...)` and `do_something(argument_1, ...)` are preferred over `my_object.do_something argument_1, ...` and `do_something argument_1, ...`.

There are however a few exceptions to this rule:

- **Getters:** If the called procedure does not have any parameters and is so simple that it may be identified as a  getter for a field, it may be called without parentheses.
- **Type Conversions:** Type conversions may be called without parentheses (Example `my_int.float`).
- **Imported Procedures:** Procedures imported from C code using `{.importc.}` should always be called using `my_proc(argument0, ...)`.
- **Macros:** Since the preferred way to call a macro heavily depends on the macro itself, macros may be called using any possible syntax.

