extends Panel


@onready var play_button : Button = %Play

@onready var layers_contaier := %VBoxContainerLayers
@onready var anim_time_line := %AnimTimeLine

@onready var looped_button := %LoopedButton
@onready var fps_animation := %FPSAnimation

@onready var layer_dialog : ConfirmationDialog = $dialogs/LayerDialog
@onready var frame_dialog : ConfirmationDialog = $dialogs/FrameDialog
var item_layer_scene := preload("res://scene/UI/UI/panel_layer/panel_layer.tscn")
var panel_anim_scene := preload("res://scene/UI/AnimationTimeLine/AnimPanel/anim_panel.tscn")

var layer_pos : Array = []

func _ready() -> void:
	GlobalAnimationTimeline.layer_removed.connect(remove_layer)
	GlobalCanvas.get_z_index_layer_finished.connect(_update_layer_pos)
	print_debug(GlobalCanvas.layers)
	GlobalCanvas.add_layer.connect(add_layer_items)
	GlobalAnimationTimeline.amination_finished.connect(func():_on_play_pressed())
	#await get_tree().create_timer(0.1).timeout
	if Global.config_project['Data'] == {}:
		for i in range(2):
			add_layer_items(i)
		#GlobalCanvas.load_layer.emit()
	fps_animation.value = Global.FPS
	setup_lopped_buuton()
	
func setup_lopped_buuton():
	is_looped_animation = GlobalAnimationTimeline.is_lopped_animation
	if is_looped_animation:
		looped_button.text = 'L'
	else:
		looped_button.text = 'NL'
func _on_left_frame_pressed() -> void:
	GlobalAnimationTimeline.leftframe_button_pressed.emit()


func _on_rightframe_pressed() -> void:
	GlobalAnimationTimeline.ritghframe_button_pressed.emit()



var playing_animation : bool = false
func _on_play_pressed() -> void:
	playing_animation = !playing_animation
	GlobalAnimationTimeline.play_button_pressed.emit()
	if playing_animation:
		play_button.text = 'Stop'
	else:
		play_button.text ='Play'


func _on_save_pressed() -> void:
	
	GlobalAnimationTimeline.save_button_pressed.emit()




func _on_color_picker_button_color_changed(color: Color) -> void:
	GlobalAnimationTimeline.color_change.emit(color)
	
	
	
func add_layer_items(id: int = -1):
	print_debug('ADDLAYERITEMS')
	var layer_item :ItemLayer = item_layer_scene.instantiate()
	var panel_anim : AnimPanel = panel_anim_scene.instantiate()
	
	
	
	if id != -1:
		layer_item.layer_id = id
		panel_anim.set_layer_id(id)
		anim_time_line.add_child(panel_anim)
		layers_contaier.add_child(layer_item)
		layer_pos.append(id)
		GlobalCanvas.layers_pos.append(id)
		return
	var ii : bool = false
	if GlobalCanvas.layers_pos.find(GlobalCanvas.layer_counter-1) != -1:
		var i = GlobalCanvas.layers_pos.get(GlobalCanvas.layer_counter-1)
		panel_anim.set_layer_id(i)
		layer_item.layer_id  = i
		ii = true
	else:
		panel_anim.set_layer_id(GlobalCanvas.layers - 1)
		layer_item.layer_id  = GlobalCanvas.layers - 1
	
	layers_contaier.add_child(layer_item)
	anim_time_line.add_child(panel_anim)	
	print('APPPEND_LAYER_POS')
	layer_pos.append(GlobalCanvas.layers - 1)
	print(layer_pos)
	if GlobalCanvas.layers_pos.size() >= 2:
		if GlobalCanvas.layers_pos[-1] ==  GlobalCanvas.layers_pos[-2]:
			GlobalCanvas.layers_pos.remove_at(-1)
	if GlobalCanvas.layers_pos.size() != GlobalCanvas.layers:
		GlobalCanvas.layers_pos = GlobalCanvas.layers_pos.duplicate()
	if ii != false:return
	GlobalCanvas.layers_pos.append(GlobalCanvas.layers - 1)
	GlobalCanvas.layers_pos = GlobalCanvas.layers_pos.duplicate()

	
func find_index(id:int):
	var children = layers_contaier.get_children()
	for i in range(children.size()):
		if children[i].layer_id == id:return i
	return -1
func remove_layer(layer_id:int):
	#var res = GlobalCanvas.layers_pos
	#res.erase(layer_id)
	#for i in range(res.size()):
		#if res[i] > layer_id:
			#var ch = anim_time_line.get_child(i)
			#ch.layer_id -= 1
			#var ch2 = layers_contaier.get_child(i)
			#ch2.layer_id -= 1
	var panel_anims = anim_time_line.get_children()
	var layer_items = layers_contaier.get_children()
	var index = find_index(layer_id)
	panel_anims[index].queue_free()
	layer_items[index].queue_free()
	
		
	
	#for i in range(res.size()):
		#if res[i] > layer_id:
			#res[i] -=1
	await  get_tree().create_timer(0.4).timeout
	#GlobalCanvas.layers_pos = res
	
	print(GlobalCanvas.layers_pos)
	#GlobalCanvas.layer_counter -= 1
	#GlobalCanvas.layers -= 1
	#panel_anims.remove_at(layer_id)
	#layer_items.re	
	
	

func update_layer_pos_in_list(list: Array, layer_id: int, new_pos:int):
	var result = list.duplicate()  # Работаем с копией
	result.erase(layer_id)
	new_pos = clamp(new_pos, 0, result.size())
	result.insert(new_pos, layer_id)
	GlobalCanvas.layers_pos = result
	layer_pos = result.duplicate()
	return result
			
		

var idd : int = 0
var u_d : int = 0
func _on_up_pressed() -> void:
	idd = GlobalCanvas.current_layer
	u_d = -1
	GlobalCanvas.get_layer_z_index(idd)
	#var layer_index : int = GlobalCanvas.get_layer_z_index(id)
	
	#GlobalCanvas.update_layer_pos.emit(layer_index - 1, layer_index,id )
func _update_layer_pos(layer_index: int):
	update_layer_pos(layer_index, idd, u_d)

func _on_down_pressed() -> void:
	idd = GlobalCanvas.current_layer
	u_d = 1
	GlobalCanvas.get_layer_z_index(idd)

func update_layer_pos(layer_index : int, id: int, up_dow: int):
	if ((layer_index + up_dow) >= GlobalCanvas.layers
		or (layer_index + up_dow < 0)):return
	layer_pos = GlobalCanvas.layers_pos
	
	var child_pos : int = layer_pos.find(id) 
	if child_pos + up_dow < 0 or child_pos +up_dow >= layer_pos.size():return
	var child := layers_contaier.get_child(child_pos)
	layer_pos = update_layer_pos_in_list(layer_pos, id, child_pos + up_dow)
	layers_contaier.move_child(child,child_pos + up_dow)
	
	var child_anim  = anim_time_line.get_child(child_pos)
	anim_time_line.move_child(child_anim,child_pos + up_dow)
	GlobalCanvas.update_layer_pos.emit(layer_index + up_dow, layer_index,id )
	#layers_contaier.move_child()
	


func _on_add_layer_pressed() -> void:
	GlobalAnimationTimeline.update_current_cadr(GlobalCanvas.current_layer, GlobalAnimationTimeline.current_cadr)
	GlobalAnimationTimeline.add_layer.emit()


func _on_left_frame_button_pressed() -> void:
	GlobalAnimationTimeline.left_frame()


func _on_right_frame_button_pressed() -> void:
	GlobalAnimationTimeline.right_frame()


func _on_min_frame_button_pressed() -> void:
	GlobalAnimationTimeline.min_frame()


func _on_max_frame_button_pressed() -> void:
	GlobalAnimationTimeline.max_frame()


func _on_fps_animation_value_changed(value: float) -> void:
	Global.set_fps(int(value))

var is_looped_animation : bool = true
func _on_looped_button_pressed() -> void:
	is_looped_animation = !is_looped_animation
	if is_looped_animation:
		looped_button.text = 'L'
	else:
		looped_button.text = 'NL'
	GlobalAnimationTimeline.is_lopped_animation = is_looped_animation


func _on_del_layer_pressed() -> void:
	layer_dialog.show()
	#GlobalAnimationTimeline.remove_layer()


func _on_del_frame_pressed() -> void:
	frame_dialog.show()
	#GlobalAnimationTimeline.remove_frame()


func _on_layer_dialog_confirmed() -> void:
	GlobalAnimationTimeline.remove_layer()


func _on_frame_dialog_confirmed() -> void:
	GlobalAnimationTimeline.remove_frame()


func _on_add_frame_pressed() -> void:
	GlobalAnimationTimeline.add_frame_button()
