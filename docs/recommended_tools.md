# Recommended Development Tools

A list of tools to help with developing owlkettle/gtk4 applications.

## Inspecting your applications CSS/Actions/CSS-Nodes and more

Often times you need to figure how much space a given component takes up, play around with the CSS it uses or you may just want to inspect the component tree yourself.

For all kinds of such things, there is a tool provided by GTK called [GTK-Inspector](https://wiki.gnome.org/Projects/GTK/Inspector). You may need to enable it, consult the wiki for further information.

To open it, press CTRL+SHIFT+I.

## Icons

Some Widgets such as [Buttons](https://github.com/can-lehmann/owlkettle/blob/main/docs/widgets.md#button) come with `icon`-setters, that you provide a gtk4-icon-string and it will render the corresponding icon.

For an overview over which icons are available, you can install the [GTK4 Icon-Library Application](https://apps.gnome.org/app/org.gnome.design.IconLibrary).

For using custom icons and icon-sets, you may want to look into [Symbolic-Preview](https://flathub.org/apps/details/org.gnome.design.SymbolicPreview).

## Colors

When usign custom stylesheet with owlkettle and changing colors, you may want to choose colors that integrate well into the color-palette used by the GNOME Desktop Environment.

For an overview over the color-palette used by gnome, you can install [ColorPalette](https://apps.gnome.org/app/org.gnome.design.Palette/).

## Contrast

Generally when developing with custom colors you may want to ensure that the contrast difference between e.g. text and background is sufficient to be easy to read. This is particularly important for accessibility! 

To check if the contrast between 2 pixels on your desktop is large enough, you can install [Contrast](https://flathub.org/apps/details/org.gnome.design.Contrast).

## GTK Documentation

When using Widgets such as [ListBox](https://github.com/can-lehmann/owlkettle/blob/main/docs/widgets.md#listbox) you are likely to stumble over enums whose meaning depends on GTK4.

To look for such symbols in the GTK4 documentation, you can install [DevHelp](https://apps.gnome.org/app/org.gnome.Devhelp/). To download the docs themselves, you will need to install an additional package:
- Fedora/RHEL: gtk4-devel-docs
- Arch: gtk4-docs

## Further applications

You can find more applications to help with development [here](https://tools.design.gnome.org/)
