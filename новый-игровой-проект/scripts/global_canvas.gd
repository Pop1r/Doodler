extends Node

signal temporary_folder_clear_started
signal temporary_folder_clear_finished
signal load_layer
signal add_layer
signal update_current_layer(id: int)
signal set_visible_layer(id: int, is_vis: bool)

signal update_layer_pos(new_pos : int, past_pos: int, id_layer: int)

signal get_z_index_layer_starteded(id: int)
signal get_z_index_layer_finished(z_index: int)

var layer_counter : int = 0 
var layers : int = 0 


var current_layer : int = 1
#1103 1562
var canvas_size : Vector2i = Vector2i(1920, 1080)

var past_v : Array = []
var layers_pos : Array = []:
	set(value):
		var dup = find_duplicate(value)
		if dup.size()>0:
			value.pop_at(dup[0]['indices'][-1])
		layers_pos = value
		print_debug(value, 'ДФДФФФ')
			
func find_duplicate(list : Array):
	var seen = {}
	var duplicatee = []
	for i in range(list.size()):
		var element = list[i]
		if seen.has(element):
			duplicatee.append({'element':element,'indices':[seen[element],i]})
		else:
			seen[element] = i
	return duplicatee
func _ready() -> void:
	var size = Global.get_canvas_size()
	canvas_size.x = int(size.x)
	canvas_size.y = int(size.y)
	add_layer.connect(_add_layer)

func  get_current_layer():
	return current_layer

func _add_layer():
	layers += 1

func get_layer_z_index(id: int):
	get_z_index_layer_starteded.emit(current_layer)
		
func set_current_layer(value : int = -1):
	current_layer = value
	update_current_layer.emit(value)
	
	print_debug(current_layer)
	#if 
	
func combine_image_layers(images: Array[Image], size: Vector2i = canvas_size):
	var result = Image.create(size.x,size.y, false, Image.FORMAT_RGBA8)
	
	for img in images:
		if img.get_size() == Vector2i.ZERO:continue
		result.blend_rect(img, Rect2i(Vector2i.ZERO, size), Vector2i.ZERO)
	return result

func get_layers_pos():
	return layers_pos
