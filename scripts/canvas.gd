extends GridContainer

const PIXEL = preload("res://scenes/pixel.tscn")

onready var root: Control = global.get_root(self)
onready var tool_container: VBoxContainer
onready var color_picker: ColorPicker

onready var camera: Camera2D = get_parent().get_node("Camera2D")
export(Vector2) var min_zoom: Vector2 = Vector2(0.250001, 0.250001)
export(Vector2) var max_zoom: Vector2 = Vector2(5, 5)
export(Vector2) var zoom_start_point: Vector2
export(Vector2) var zoom_end_point: Vector2
export(Vector2) var zoom_speed: Vector2 = Vector2(0.01, 0.01)
export(Vector2) var canvas_frame_start: Vector2
export(Vector2) var canvas_frame_end: Vector2
export(float, 0.01, 0.1) var pan_speed: float = 0.02
var panning: bool = false

var cur_tool: String = ""
const BRUSH: String = "brush"
const FILL: String = "fill"

func _ready() -> void:
	yield(root, "vars_ready")
	cur_tool = BRUSH
	tool_container = root.tool_container
	color_picker = root.color_picker
	columns = global.width

	for c in global.width:
		for r in global.hight:
			var pixel = PIXEL.instance()
			pixel.x = r
			pixel.y = c
			add_child(pixel)

func in_boundery() -> bool:
	var mouse_pos: Vector2 = root.get_global_mouse_position()
	return mouse_pos.x >= zoom_start_point.x and mouse_pos.x <= zoom_end_point.x \
	and mouse_pos.y >= zoom_start_point.y and mouse_pos.y <= zoom_end_point.y

func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("middle_mouse"):
		panning = false

	if root.no_popups_visible:
		if event is InputEventMouseButton and in_boundery():
			if event.button_index == BUTTON_WHEEL_DOWN and camera.zoom > min_zoom:
				camera.zoom += zoom_speed
			elif event.button_index == BUTTON_WHEEL_UP and camera.zoom < max_zoom:
				camera.zoom -= zoom_speed
		elif event is InputEventMouseMotion and \
		Input.is_action_pressed("middle_mouse") and (panning or in_boundery()):
			panning = true
			camera.position += event.speed * pan_speed * -1

func transform(matrix: Array) -> void:
	var new_canvas: Array = []
	for _i in range(global.width):
		var a: Array = []
		for _j in range(global.hight):
			a.append(Color(0, 0, 0, 0))
		new_canvas.append(a)

	for pixel in get_children():
		var vec: Vector2 = pixel.transform_vec(matrix)
		if vec.x >= 0 and vec.x <= global.width and vec.y >= 0 and vec.y <= global.hight:
			new_canvas[vec.x][vec.y] = pixel.modulate

	for pixel in get_children():
		pixel.modulate = new_canvas[pixel.x][pixel.y]
