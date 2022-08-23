extends Control

const FRAME = preload("res://assets/pixel_frame.png")
const HOVER = preload("res://assets/pixel_frame_hover.png")

onready var root: Control = global.get_root(self)
onready var canvas: GridContainer = get_parent()
onready var canvas_frame_s: Vector2 = canvas.canvas_frame_start
onready var canvas_frame_e: Vector2 = canvas.canvas_frame_end

var can_fill: bool = true
var cur_tool: String

var x: int
var y: int

func _process(_delta: float) -> void:
	cur_tool = canvas.cur_tool
	
	var lmouse_pos: Vector2 = get_local_mouse_position()
	var gmouse_pos: Vector2 = root.get_global_mouse_position()
	
	if lmouse_pos.x > 0 and lmouse_pos.x <= global.PIXEL_LEN and \
	lmouse_pos.y > 0 and lmouse_pos.y <= global.PIXEL_LEN and \
	gmouse_pos.x >= canvas_frame_s.x and gmouse_pos.x <= canvas_frame_e.x and \
	gmouse_pos.y >= canvas_frame_s.y and gmouse_pos.y <= canvas_frame_e.y:
		$frame.texture = HOVER
		
		if !root.color_picker_icon.pressed:
			
			if cur_tool == canvas.FILL:
				if Input.is_action_just_pressed("right_mouse"):
					fill(true)
				
				elif Input.is_action_just_pressed("left_mouse"):
					fill(false)
					
				for pixel in canvas.get_children():
					pixel.can_fill = true
			
			elif cur_tool == canvas.BRUSH:
				if Input.is_action_pressed("right_mouse"):
					$pixel.modulate = Color(1, 1, 1, 0)
				
				elif Input.is_action_pressed("left_mouse"):
					$pixel.modulate = canvas.color_picker.color
				
			if Input.is_action_just_released("right_mouse") or \
			 Input.is_action_just_released("left_mouse"):
				canvas.root.save_pixels()
		else:
			if Input.is_action_just_pressed("left_mouse") and \
			$pixel.modulate != Color(1, 1, 1, 0):
					canvas.color_picker.color = $pixel.modulate
	
	else:
		$frame.texture = FRAME

func transform_vec(matrix: Array) -> Vector2:
	var a = matrix[0][0] * x + matrix[1][0] * y
	var b = matrix[0][1] * x + matrix[1][1] * y
	return Vector2(a, b)

func fill(erase: bool) -> void:
	can_fill = false
	
	var idx: int = get_index()
	
	var left_pixel: Control = null
	if idx % global.width != global.width - 1:
		left_pixel = canvas.get_child(idx + 1)
	
	var right_pixel: Control = null
	if idx % global.width != 0:
		right_pixel = canvas.get_child(idx - 1)
	
	var up_pixel: Control = null
# warning-ignore:integer_division
	if idx / global.hight != global.hight - 1:
		up_pixel = canvas.get_child(idx + global.width)
	
	var down_pixel: Control = null
# warning-ignore:integer_division
	if idx / global.hight != 0:
		down_pixel = canvas.get_child(idx - global.width)
	
	if left_pixel != null and\
	 left_pixel.can_fill and\
	 left_pixel.get_node("pixel").modulate == $pixel.modulate:
		left_pixel.fill(erase)

	if right_pixel != null and\
	 right_pixel.can_fill and\
	 right_pixel.get_node("pixel").modulate == $pixel.modulate:
		right_pixel.fill(erase)

	if up_pixel != null and\
	 up_pixel.can_fill and\
	 up_pixel.get_node("pixel").modulate == $pixel.modulate:
		up_pixel.fill(erase)

	if down_pixel != null and\
	 down_pixel.can_fill and\
	 down_pixel.get_node("pixel").modulate == $pixel.modulate:
		down_pixel.fill(erase)
	
	if !erase:
		$pixel.modulate = canvas.color_picker.color
	else:
		$pixel.modulate = Color(1, 1, 1, 0)
