# Recommended Development Tools

A list of tools to help with developing owlkettle/gtk4 applications.

## Inspecting your application's CSS, layout and more

[GTK-Inspector](https://wiki.gnome.org/Projects/GTK/Inspector) allows you to inspect the widget tree.
You may need to enable it, consult the GNOME wiki for further information.

To open it, press CTRL+SHIFT+I.

## Icons

Some Widgets such as [Buttons](https://github.com/can-lehmann/owlkettle/blob/main/docs/widgets.md#button) come with `icon`-setters, that you provide a gtk4-icon-name and it will render the corresponding icon.

For an overview over which icons are available, you can install the [Icon Library](https://apps.gnome.org/app/org.gnome.design.IconLibrary) application.

For using custom icons and icon-sets, you may want to look into [Symbolic Preview](https://flathub.org/apps/details/org.gnome.design.SymbolicPreview).

## Colors

When using custom stylesheet with owlkettle and changing colors, you may want to choose colors that integrate well with the color-palette used by the GNOME Desktop Environment.

For an overview over the color-palette used by gnome, you can install [Color Palette](https://apps.gnome.org/app/org.gnome.design.Palette/).

## Contrast

When developing with custom styling you may want to ensure that the contrast difference between e.g. the text color and the background color is sufficient to be readable.
This is particularly important for accessibility.

To check if the contrast between 2 colors is large enough, you can install [Contrast](https://flathub.org/apps/details/org.gnome.design.Contrast).

## GTK Documentation

When using Widgets such as [ListBox](https://github.com/can-lehmann/owlkettle/blob/main/docs/widgets.md#listbox) you are likely to stumble over enums whose meaning depends on GTK4.

To lookup their meaning in the GTK4 documentation, you can install [Devhelp](https://apps.gnome.org/app/org.gnome.Devhelp/).
To download the docs themselves, you might need to install an additional package:
- Fedora/RHEL: `gtk4-devel-docs`
- Arch: `gtk4-docs`

## Further applications

You can find more applications to help with development [here](https://tools.design.gnome.org/)
