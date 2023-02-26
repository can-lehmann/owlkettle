import nimibook

# Note: Paths inside of sections are relative to the section-file's path.

var book = initBookWithToc:
  entry("Welcome to Owlkettle!", "README.md")
  entry("Tutorial", "docs/tutorial.md")
  entry("General Examples", "examples/README.md")

  entry("Tooling", "docs/recommended_tools.md")

  section("Reference", "book/reference.nim"):
    entry("General Widget Reference", "../docs/widgets.md")
    entry("Adwaita Widget Reference", "../docs/widgets_adwaita.md")
    entry("DataEntry Widget Reference", "../docs/widgets_dataentries.md")

  #entry("Migrating", "docs/migrating_1_to_2.md")
  #entry("Cross Compiling", "docs/cross_compiling.md")

  section("Internals", "book/internals.nim"):
    entry("Custom Widgets", "internals/custom_widgets.nim")

    section("Adders", "internals/adders.nim"):
      entry("One Adder", "adders/one_adder.nim")
      entry("Adders With Properties", "adders/adders_with_properties.nim")
      entry("Multiple Adders", "adders/multiple_adders.nim")

    section("Hooks", "internals/hooks.nim"):
      entry("Build Hook", "hooks/build_hook.nim")
      entry("BeforeBuild Hook", "hooks/before_build_hook.nim")
      entry("AfterBuild Hook", "hooks/after_build_hook.nim")
      entry("Event Hooks", "hooks/event_hooks.nim")
      entry("Update Hook", "hooks/update_hook.nim")
      entry("Property Hook", "hooks/property_hook.nim")
      entry("Read Hook", "hooks/read_hook.nim")

  entry("Contributing", "CONTRIBUTING.md")
nimibookCli(book)
