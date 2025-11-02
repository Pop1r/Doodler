extends PanelContainer

class_name AnimPanel


signal update_current_frame(id: int)
signal add_frame(id:int)
var layer_id : int = 0

var fraem_scene := preload("res://scene/UI/UI/Frame/frame_item.tscn")



func _ready() -> void:
	start_frame()
	update_current_frame.connect(func(id: int): GlobalAnimationTimeline.update_c_frame(layer_id,id))
	add_frame.connect(func(id:int): GlobalAnimationTimeline.add_frame(layer_id,id))
	GlobalAnimationTimeline.frame_removed.connect(remove_frame)
	Global.load_items.connect(load_items)
	GlobalAnimationTimeline.frame_added.connect(frame_add_button)

func start_frame(value: bool = false):
	if value:
		var f = fraem_scene.instantiate()

		$HBoxContainer.add_child(f)
		f.set_frame_info(0,layer_id)
		f.set_vis()
		spawn_frame(1000)
	else:
		spawn_frame(1000)
func frame_add_button(l:int,f:int):
	if l != layer_id:return
	var child = $HBoxContainer.get_child(f-1)
	child.set_load()
	
	
func remove_frame(layer: int, frame_id: int, frame_index: int):
	if layer != layer_id:return
	var child = $HBoxContainer.get_child(frame_id - 1)
	child.remove()
	
func set_layer_id(id: int):
	layer_id = id
	
func spawn_frame(len: int ):
	for i in range(1,len):
		var f = fraem_scene.instantiate()
		f.set_frame_info(i,layer_id)
		$HBoxContainer.add_child(f)
	var child = $HBoxContainer.get_child(0)
	child.vis()
	#child.set_vis()
	#GlobalAnimationTimeline.add_frame(layer_id,0)

func load_items(l_id: int , fr:Array):
	if l_id != layer_id:return
	for i in fr:
		var child = $HBoxContainer.get_child(i-1)
		child.set_load()
