import ./bindings/gtk
import std/[strutils, re, macros, xmltree]
export xmltree

type 
  BuilderObj = object
    gtk*: GtkBuilder

  Builder* = ref BuilderObj

proc wrap(builder: GtkBuilder): Builder = Builder(gtk: builder)
  
proc newBuilderFromFile*(filename: string): Builder =
  let builder = gtk_builder_new_from_file(filename.cstring)
  result = builder.wrap()

proc newBuilderFromResource*(resource: string): Builder =
  let builder = gtk_builder_new_from_resource(resource.cstring)
  result = builder.wrap()

proc newBuilderFromString*(uiString: string): Builder =
  let builder = gtk_builder_new_from_string(uiString.cstring, uiString.len().cint)
  result = builder.wrap()

proc newBuilder*(): Builder = gtk_builder_new().wrap()

proc getWidget*(builder: Builder, id: string): GtkWidget =
  let gObj: pointer = gtk_builder_get_object(builder.gtk, id.cstring)  
  return gObj.GtkWidget

proc newWidgetFromString*(uiString: string, id: string = "widget"): GtkWidget =
  let builder = newBuilderFromString(uiString)
  return builder.getWidget(id)

proc newWidgetFromFile*(fileName: string, id: string = "widget"): GtkWidget =
  let builder = newBuilderFromFile(fileName)
  return builder.getWidget(id)

proc newWidgetFromResource*(resource: string, id: string = "widget"): GtkWidget =
  let builder = newBuilderFromResource(resource)
  return builder.getWidget(id)



macro getField*(obj: auto, fieldName: static string): untyped =
  nnkDotExpr.newTree(obj, ident(fieldName))

proc toKebapCase*(camelCase: string): string =
  return findAll(camelCase, re"(^[a-z0-9]+|[A-Z0-9][a-z0-9]*)").join("-").toLower()

type UiTags* = enum
  Object, Property, Child, Interface

proc newNode*(tag: UiTags, children: varargs[XmlNode]): XmlNode =
  result = newElement(($tag).toLower())
  
  for child in children:
    result.add(child)

proc newNode*(tag: UiTags, attributes: XmlAttributes): XmlNode =
  result = newNode(tag)
  result.attrs = attributes

proc newNode*(tag: UiTags, attributes: XmlAttributes, text: string): XmlNode =
  result = newNode(tag, attributes)
  result.add(newText(text))

proc newNode*(tag: UiTags, text: string): XmlNode =
  result = newNode(tag)
  result.add(newText(text))



proc addProperty*(
  rootNode: XMLNode, 
  shortcut: ref object, 
  propertyName: static string, 
  translatable = false
) =
  let hasValue = shortcut.getField("has" & propertyName)
  if not hasValue:
    return

  let attributes = if translatable:
      {"name": propertyName.toKebapCase(), "translatable": "yes"}.toXmlAttributes()
    else:
      {"name": propertyName.toKebapCase()}.toXmlAttributes()
  let fieldValStr = $ shortcut.getField("val" & propertyName)
  let propertyNode = newNode(Property, attributes, fieldValStr)
  
  rootNode.add(propertyNode)

proc addChildNodes*(
  rootNode: XMLNode,
  obj: ref object,
  propertyName: static string
) =
  let hasValue = obj.getField("has" & propertyName)
  if not hasValue:
    return
  
  for childObj in obj.getField("val" & propertyName):    
    let childNode = newNode(Child, childObj.toNode())
    rootNode.add(childNode)