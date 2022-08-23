extends Node

var width: int = 8
var hight: int = 8
const PIXEL_LEN = 40

var file_path: String = ""
var image_path: String = ""

var pixels: String = ""

var pixels_history: Array = []
var pixels_idx: int = -1

func get_root(cur: Node) -> Node:
	if cur.get_parent().name == "root":
		return cur
	else:
		return get_root(cur.get_parent())

func find_child_of_type(node: Node, type) -> Node: # used only if guaranteed there's only one child of type "type"
	for child in node.get_children():
		if child is type:
			return child
		else:
			var x: Node = find_child_of_type(child, type)
			if x != null:
				return x
	return null
