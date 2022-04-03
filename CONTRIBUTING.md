# Contributing to Owlkettle

## Documentation

When adding a new widget or modifying an existing widget, you will need to update the widget documentation.
Since it is automatically generated from the `owlkettle/widgets.nim` module, running the following commands from the project folder will update the documentation to reflect any changes you made to the widgets.

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

This style guide is supposed to provide some guidelines for developing owlkettle.
It is currently still under construction and should therefore **not** be viewed as a strict set of rules to follow.

### Identifiers

Owlkettle uses `snake_case` instead of `camelCase` for identifiers.
The names of types and widgets are in `PascalCase`.

### Constructors

The names of constructor procedures for `ref object` types should start with the prefix `new_` while constructor procedures for `object` types should start with the prefix `init_`.
For example the constructor for a type named `MyType` would be called `new_my_type` if it is a `ref object` and `init_my_type` if it is an `object`.

Procedures which load data from disk should start with the prefix `load_` and take a path as their first argument.
A procedure which loads `MyType` from disk may for example have the signature `proc load_my_type(path: string): MyType`.

### Procedure Calls

Since there are multiple ways to call procedures in nim, it is necessary to have some guidelines on when to use which syntax.
Please note that these are general guidelines and there are exceptions for some specific cases.

Generally `my_object.do_something(argument1, ...)` and `do_something(argument_1, ...)` are preferred over `my_object.do_something argument_1, ...` and `do_something argument_1, ...`.

There are however a few exceptions to this rule:

- **Echo:** The `echo` procedure should always be called using command syntax (Example: `echo "Hello, world!"`)
- **Getters:** If the called procedure does not have any parameters and is so simple that it may be identified as a  getter for a field, it may be called without parentheses.
- **Type Conversions:** Type conversions may be called without parentheses (Example: `my_int.float`).
- **Imported Procedures:** Procedures imported from C code using `{.importc.}` should always be called using `my_proc(argument0, ...)`.
- **Macros/Templates:** Since the preferred way to call a macro heavily depends on the macro itself, macros may be called using any possible syntax.

