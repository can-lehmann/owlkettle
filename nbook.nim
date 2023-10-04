import nimibook

# Note: Paths inside of sections are relative to the section-file's path.

var book = initBookWithToc:
  entry("Welcome to Owlkettle!", "README.md")
  entry("Installation", "docs/installation.md")
  entry("Tutorial", "docs/tutorial.md")
  entry("Examples", "examples/README.md")

  section("Reference", "book/reference.nim"):
    entry("General Widgets", "../docs/widgets.md")
    entry("Adwaita Widgets", "../docs/widgets_adwaita.md")
    entry("DataEntry Widgets", "../docs/widgets_dataentries.md")

  #entry("Migrating", "docs/migrating_1_to_2.md")
  #entry("Cross Compiling", "docs/cross_compiling.md")

  section("Internals", "book/internals.nim"):
    entry("Custom Widgets", "internals/custom_widgets.nim")

    section("Adders", "internals/adders.nim"):
      entry("Single Adder", "adders/single_adder.nim")
      entry("Adders with Properties", "adders/adders_with_properties.nim")
      entry("Multiple Adders", "adders/multiple_adders.nim")
      entry("Direct Assignment", "adders/direct_assignment.nim")

    section("Hooks", "internals/hooks.nim"):
      entry("Build Hook", "hooks/build_hook.nim")
      entry("BeforeBuild Hook", "hooks/before_build_hook.nim")
      entry("AfterBuild Hook", "hooks/after_build_hook.nim")
      entry("Event Hooks", "hooks/event_hooks.nim")
      entry("Update Hook", "hooks/update_hook.nim")
      entry("Property Hook", "hooks/property_hook.nim")
      entry("Read Hook", "hooks/read_hook.nim")

    entry("Setters", "internals/setters.nim")

  entry("Tooling", "docs/recommended_tools.md")
  
  section("Migration", "book/migration.md"):
    entry("1.x.x to 2.0.0", "../docs/migrating_1_to_2.md")
    entry("2.x.x to 3.0.0 (devel)", "../docs/migrating_2_to_3.md")
  
  section("Contributing", "CONTRIBUTING.md"):
    entry("Wrapping GTK widgets", "book/internals/wrap_gtk_widget.nim")
  
  section("Legal", "book/legal/legal.md"):
    entry("License", "license.md")
    entry("Imprint / Impressum", "imprint.md")

nimibookCli(book)
