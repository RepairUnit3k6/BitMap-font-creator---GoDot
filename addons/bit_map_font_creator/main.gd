tool
extends EditorPlugin
var dock
var sav_path_line
var tex_path_line
var can = false
enum mode {new,edit,none}
var actual_mode = mode.none
func _enter_tree():
	dock = preload("res://addons/bit_map_font_creator/main.tscn").instance()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	sav_path_line = dock.get_node("sav_path")
	sav_path_line.connect("text_changed",self,"look_for_file")
	dock.get_node("Button").connect("button_down",self,"create")

func look_for_file(var text):
	if File.new().file_exists(text):
		var l = load(text)
		if l.get_class() == "BitmapFont":
			dock.get_node("Label4").text = "File found, will edit it"
			dock.get_node("Button").disabled = false
			dock.get_node("Button").text = "Add char"
			dock.get_node("Label4").add_color_override("font_color", Color("ffffff"))
			dock.get_node("tex_path").text = "Not needed"
			dock.get_node("tex_path").editable = false
			actual_mode = mode.edit
		else:
			dock.get_node("Label4").text = "File found, not bitmap font, Can't edit"
			dock.get_node("Label4").add_color_override("font_color", Color("ff0000"))
			dock.get_node("Button").disabled = true
			dock.get_node("tex_path").editable = true
	else:
		dock.get_node("Label4").text = "File not found, will create one"
		dock.get_node("Button").disabled = false
		dock.get_node("Button").text = "Create file"
		dock.get_node("tex_path").editable = true
		dock.get_node("Label4").add_color_override("font_color", Color("ffffff"))
		actual_mode = mode.new

func create():
	if actual_mode != mode.none:
		var bf
		var tex
		if actual_mode == mode.new:
			if File.new().file_exists(dock.get_node("tex_path").text):
				bf = BitmapFont.new()
				tex = load(dock.get_node("tex_path").text)
				bf.add_texture(tex)
			else:
				dock.get_node("Label4").text = "Can't load texture"
				dock.get_node("Label4").add_color_override("font_color", Color("ff0000"))
				return
		elif actual_mode == mode.edit:
			bf = load(dock.get_node("sav_path").text)
			tex = bf.get_texture(0)
		bf.add_char(int(dock.get_node("letter_button1/u").value),0,Rect2(dock.get_node("letter_button1/x").value,dock.get_node("letter_button1/y").value,dock.get_node("letter_button1/w").value,dock.get_node("letter_button1/h").value))
		ResourceSaver.save(dock.get_node("sav_path").text,bf)
		look_for_file(sav_path_line.text)