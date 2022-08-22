extends TextureButton

onready var canvas: GridContainer

func _ready() -> void:
	var root = global.get_root(self)
	yield(root, "vars_ready")
	canvas = root.canvas
	
	var tool_name: String = ""
	for i in range(6, len(texture_normal.resource_path)):
		var c = texture_normal.resource_path[i]
		if c == '_':
			break
		tool_name += c
	self.name = tool_name


func _on_tool_button_pressed() -> void:
	canvas.cur_tool = self.name
