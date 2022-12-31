# Dataentries Widgets


## NumberEntry

```nim
viewable NumberEntry
```

###### Fields

- `value: float`
- `eps: float = 0.000001`
- `placeholder: string`
- `width: int = -1`
- `maxWidth: int = -1`
- `xAlign: float = 0.0`

###### Events

- changed: `proc (value: float)`


## FormulaEntry

```nim
viewable FormulaEntry of NumberEntry
```

###### Fields

- All fields from [NumberEntry](#NumberEntry)


