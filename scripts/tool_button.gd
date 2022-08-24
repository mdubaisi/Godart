extends TextureButton

onready var canvas: GridContainer

func _ready() -> void:
	var root = global.get_root(self)
	yield(root, "vars_ready")
	canvas = root.canvas
	

func _on_tool_button_pressed() -> void:
	canvas.cur_tool = self.name
