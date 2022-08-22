extends Control

var file_path: String = ""

func _ready() -> void:
	$popup.hide()

func _on_new_pressed() -> void:
	$popup.visible = true

func _on_open_pressed() -> void:
	$open_dialog.popup()
	yield($open_dialog, "file_selected")
	
	var file: File = File.new()
# warning-ignore:return_value_discarded
	file.open(file_path, File.READ)
	var content: String = file.get_as_text()
	
	var width: String = ""
	var hight: String =  ""
	var i: int = 0
	
	while content[i] != " ":
		width += content[i]
		i += 1
	i += 1
	
	while content[i] != "\n":
		hight += content[i]
		i += 1
	i += 1
	
	global.width = int(width)
	global.hight = int(hight)
	
	while content[i] != " ":
		global.file_path += content[i]
		i += 1
	i += 1
	
	while content[i] != "\n":
		global.image_path += content[i]
		i += 1
	i += 1
	
	while i != len(content):
		global.pixels += content[i]
		i += 1
	
	file.close()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/main_scene.tscn")

func _on_Accept_pressed() -> void:
	if int($popup/width.text) <= 0 or int($popup/hight.text) <= 0:
		$AcceptDialog.popup()
	else:
		$popup.visible = false
		global.width = int($popup/width.text)
		global.hight = int($popup/hight.text)
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/main_scene.tscn")

func _on_open_dialog_file_selected(path: String) -> void:
	file_path = path
