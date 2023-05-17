# Dataentries Widgets


## NumberEntry

```nim
viewable NumberEntry
```

A entry for entering floating point numbers.

###### Fields

- `value: float`
- `eps: float = 0.000001`
- `placeholder: string`
- `width: int = -1`
- `maxWidth: int = -1`
- `xAlign: float = 0.0`
- `tooltip: string = ""`
- `sizeRequest: tuple[x, y: int] = (-1, -1)`
- `sensitive: bool = true`

###### Events

- changed: `proc (value: float)`

###### Example

```nim
NumberEntry:
  value = app.value
  proc changed(value: float) =
    app.value = value

```


## FormulaEntry

```nim
viewable FormulaEntry of NumberEntry
```

A entry for entering floating point numbers.
The FormulaEntry can evaluate mathematical expressions like `1 + 2 * 3`.

###### Fields

- All fields from [NumberEntry](#NumberEntry)
- `vars: Table[string, float]` Variables that may be used in the expression

###### Example

```nim
FormulaEntry:
  value = app.value
  vars = toTable({"pi": PI})
  proc changed(value: float) =
    app.value = value

```


