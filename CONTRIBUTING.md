# Contributing to Owlkettle

A short introduction to owlkettle's internals can be found [here](https://can-lehmann.github.io/owlkettle/book/internals.html).

## Documentation

When adding a new widget or modifying an existing widget, you will need to update the widget documentation.
Since it is automatically generated from the `owlkettle/widgets.nim` module, running the following command from the project folder will update the documentation to reflect any changes you made to the widgets.

```bash
make -C docs
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

### Images

When adding any images to the nimibook documentation, try to account for light and dark-modes.
You can do so easily by first making sure your image looks good in nimibooks `light` mode,
and then adding a text block containing a css rule like this to your `.md` or `.nim` file:

```html
<style>
.coal img.invertable-image,
.navy img.invertable-image,
.ayu img.invertable-image {
  filter: invert(100%);
  background-color:white;
}
</style>
```

## Style Guide

This style guide is supposed to provide some guidelines for developing owlkettle.
It is currently still under construction and should therefore **not** be viewed as a strict set of rules to follow.

### Identifiers

Owlkettle uses `camelCase` for identifiers.
The names of types and widgets are in `PascalCase`.

### Constructors

The names of constructor procedures for `ref object` types should start with the prefix `new` while constructor procedures for `object` types should start with the prefix `init`.
For example the constructor for a type named `MyType` would be called `newMyType` if it is a `ref object` and `initMyType` if it is an `object`.

Procedures which load data from disk should start with the prefix `load` and take a path as their first argument.
A procedure which loads `MyType` from disk may for example have the signature `proc loadMyType(path: string): MyType`.

### Procedure Calls

Since there are multiple ways to call procedures in nim, it is necessary to have some guidelines on when to use which syntax.
Please note that these are general guidelines and there are exceptions for some specific cases.

Generally `myObject.doSomething(argument1, ...)` and `doSomething(argument1, ...)` are preferred over `myObject.doSomething argument1, ...` and `doSomething argument1, ...`.

There are however a few exceptions to this rule:

- **Echo:** The `echo` procedure should always be called using command syntax (Example: `echo "Hello, world!"`)
- **Getters:** If the called procedure does not have any parameters and is so simple that it may be identified as a  getter for a field, it may be called without parentheses.
- **Type Conversions:** Type conversions may be called without parentheses (Example: `myInt.float`).
- **Imported Procedures:** Procedures imported from C code using `{.importc.}` should always be called using `myProc(argument0, ...)`.
- **Macros/Templates:** Since the preferred way to call a macro heavily depends on the macro itself, macros may be called using any possible syntax.

