extends Control

export(Color) var ui_bg: Color = Color("1e1c2f")

onready var tool_container: VBoxContainer = $tool_bar/tool_container
onready var canvas: GridContainer = $ViewportContainer/middle/canvas
onready var color_picker: ColorPicker = $right_side/ColorPicker
onready var color_picker_icon: ToolButton
onready var save_dialog: FileDialog = $save_dialog
onready var export_dialog: FileDialog = $export_dialog

signal vars_ready

func _ready() -> void:
	$right_side/ColorRect.color = ui_bg
	$tool_bar/ColorRect.color = ui_bg
	color_picker_icon = global.find_child_of_type(color_picker, ToolButton)
	emit_signal("vars_ready")
	
	if global.pixels != "":
		var pixels_arr: Array = []
		var rgba: Array = ["", "", "", ""]
		var i: int = 0
		
		for c in global.pixels:
			if c != '[' and c != ']':
				if c == " ":
					if rgba != ["", "", "", ""]:
						pixels_arr.append(Color(float(rgba[0]), float(rgba[1])
						, float(rgba[2]), float(rgba[3])))
						rgba = ["", "", "", ""]
						i = 0
				elif c == ",":
					i += 1
				else:
					rgba[i] += c
		
		for j in canvas.get_child_count() - 1:
			var pixel: TextureRect = canvas.get_children()[j].get_node("pixel")
			pixel.modulate = pixels_arr[j]
	
	get_tree().paused = true
	yield(get_tree().create_timer(0.15), "timeout")
	get_tree().paused = false
	
	save_pixels()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ctrl") and Input.is_action_pressed("shift")\
	 and Input.is_action_just_released("z"):
		if global.pixels_idx < len(global.pixels_history) - 1:
			global.pixels_idx += 1
			set_pixels()

	elif Input.is_action_pressed("ctrl") and Input.is_action_just_released("z"):
		if global.pixels_idx > 0:
			global.pixels_idx -= 1
			set_pixels()
	
	elif Input.is_action_pressed("ctrl"):
		color_picker_icon.pressed = true
	
	
	if Input.is_action_just_pressed("b"):
		canvas.cur_tool = canvas.BRUSH
	
	if Input.is_action_just_pressed("f"):
		canvas.cur_tool = canvas.FILL

func save_pixels() -> void:
	var pixels: Array = []
	for p in canvas.get_children():
		pixels.append(p.get_node("pixel").modulate)
	
	while global.pixels_idx < len(global.pixels_history) - 1:
		global.pixels_history.pop_back()
	global.pixels_history.append(pixels)
	global.pixels_idx += 1

func set_pixels() -> void:
	for i in range(canvas.get_child_count()):
		canvas.get_child(i).get_node("pixel").modulate =\
		global.pixels_history[global.pixels_idx][i]

func _on_save_pressed() -> void:
	save_dialog.popup()

func _on_export_pressed() -> void:
	export_dialog.popup()

func _on_save_dialog_file_selected(path: String) -> void:
	global.file_path = path
	if !global.file_path.ends_with(".txt"):
		global.file_path += ".txt"
	
	var pixels: Array = []
	for p in canvas.get_children():
		pixels.append(p.get_node("pixel").modulate)
	
	var file: File = File.new()
# warning-ignore:return_value_discarded
	file.open(global.file_path, File.WRITE)
	file.store_string(str(global.width) + " " + str(global.hight) + "\n" + 
	global.file_path + " " + global.image_path + "\n" 
	+ str(pixels))
	
	file.close()
	
	yield(get_tree().create_timer(0.15), "timeout")
	get_tree().paused = false

func _on_export_dialog_file_selected(path: String) -> void:
	global.image_path = path
	if !global.image_path.ends_with(".png"):
		global.image_path += ".png"
	
	var img: Image = Image.new()
	img.create(global.width, global.hight, false, Image.FORMAT_RGBA8)
	
	img.lock()
	for p in canvas.get_children():
		var pixel: TextureRect = p.get_node("pixel")
		img.set_pixel(p.x, p.y, pixel.modulate)
	
# warning-ignore:return_value_discarded
	img.save_png(global.image_path)
	
	yield(get_tree().create_timer(0.15), "timeout")
	get_tree().paused = false
