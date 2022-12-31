all: widgets.md widgets_adwaita.md widgets_dataentries.md

widgets.md: ../owlkettle/widgets.nim ../owlkettle/widgetdef.nim
	nim compile -d:owlkettleDocs -o:build_docs ../owlkettle/widgets.nim
	./build_docs > widgets.md

widgets_adwaita.md: ../owlkettle/adw.nim ../owlkettle/widgetdef.nim
	nim compile -d:owlkettleDocs -o:build_docs ../owlkettle/adw.nim
	./build_docs > widgets_adwaita.md

widgets_dataentries.md: ../owlkettle/dataentries.nim ../owlkettle/widgetdef.nim
	nim compile -d:owlkettleDocs -o:build_docs ../owlkettle/dataentries.nim
	./build_docs > widgets_dataentries.md

