all: widgets.md widgets_adwaita.md

widgets.md: ../owlkettle/widgets.nim ../owlkettle/widgetdef.nim
	nim compile -d:owlkettleDocs -o:build_docs ../owlkettle/widgets.nim
	./build_docs > widgets.md

widgets_adwaita.md: ../owlkettle/widgets.nim ../owlkettle/widgetdef.nim
	nim compile -d:owlkettleDocs -o:build_docs ../owlkettle/adw.nim
	./build_docs > widgets_adwaita.md

