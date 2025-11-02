extends Control


var draw_canvas_scene = preload("res://scene/draw_canvas/drawcanvas.tscn")
var canvas_size = Vector2(1920 ,1080)

var is_polet : bool = false
var delta_pos : Vector2 = Vector2.ZERO

@onready var sub_viewport #= $Control/Control/SubViewportContainer/SubViewport
@onready var canvas_draw #= $Control/Control/SubViewportContainer/SubViewport/drawcanvas
@onready var subviewport_container := $Control/Control/SubViewportContainer


var zoom_speed: float = 0.1
var min_zoom: float = 0.01
var max_zoom: float = 50.0
var current_zoom: float = 1.0


var layers : Array = []
var viewports : Array[SubViewportContainer] = []
var backround_color : Color = Color.WHITE

func _ready() -> void:
	GlobalAnimationTimeline.layer_removed.connect(remove_layer)
	Global.get_image_to_save.connect(get_images_to_save)
	#canvas_size = Global.get_canvas_size()
	canvas_size = GlobalCanvas.canvas_size
	backround_color = Global.get_background_color()
	GlobalCanvas.get_z_index_layer_starteded.connect(get_z_index_layer)
	GlobalCanvas.update_current_layer.connect(update_current_layer)
	GlobalCanvas.update_layer_pos.connect(update_z_index_layer)
	GlobalAnimationTimeline.save_button_pressed.connect(get_canvas_images)
	GlobalAnimationTimeline.add_layer.connect(func():add_layer(Color.TRANSPARENT))
	GlobalCanvas.load_layer.connect(func():add_layer(Color.TRANSPARENT))
	if GlobalCanvas.layers == 0:
		add_layer(backround_color)
		add_layer(Color.TRANSPARENT)
	else:
		await get_tree().create_timer(0.1).timeout
		var col = GlobalCanvas.layers
		GlobalCanvas.layers = 0
		GlobalCanvas.layer_counter = 0
		print('LAYERPOS', GlobalCanvas.layers_pos)
		for i in range(col):
			add_layer(Color.TRANSPARENT, GlobalCanvas.layers_pos[i])
		await get_tree().create_timer(0.1).timeout
		if not Global.frames_load.is_empty():
			Global.load_frame_in_canvas()
	GlobalAnimationTimeline.brush_size.connect(set_brush_size)
	GlobalAnimationTimeline.color_change.connect(upd_color)
	
	
	
func upd_color(color:Color):
	for i in layers:
		i.set_brush_color(color)
func set_brush_size(value: float):
	for i in layers:
		i.set_brush_size(value)
	print(canvas_draw.brush_size)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			is_polet = true
			delta_pos = event.position - position
		else:
			is_polet = false
			
	if event is InputEventMouseMotion and is_polet:
		position = event.position - delta_pos
	
	
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in(get_global_mouse_position())
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out(get_global_mouse_position())
			get_viewport().set_input_as_handled()
		
	if Input.is_action_just_pressed('ui_accept'):
		get_images()
		

func zoom_in(mouse_position: Vector2):
	var new_zoom = current_zoom * (1 + zoom_speed)
	if new_zoom <= max_zoom:
		set_zoom_centered(new_zoom, mouse_position)
		
func zoom_out(mouse_position: Vector2):
	var new_zoom = current_zoom * (1 - zoom_speed)
	if new_zoom >= min_zoom:
		set_zoom_centered(new_zoom, mouse_position)
		
func set_zoom_centered(new_zoom: float, mouse_position: Vector2):
	var mouse_local = (mouse_position - global_position) / current_zoom
	current_zoom = new_zoom
	scale = Vector2(current_zoom, current_zoom)
	var new_mouse_local = mouse_local * current_zoom
	var offset = mouse_position - new_mouse_local - global_position
	global_position += offset
	
func add_layer(color_background: Color, l_id :int = -1):
	
	var new_subviewport_containar := CanvasContainer.new()
	new_subviewport_containar.size = canvas_size
	#new_subviewport_containar.
	new_subviewport_containar.z_index = viewports.size()
	if l_id == -1:
		new_subviewport_containar.set_layer_id(GlobalCanvas.layer_counter)
	else:
		new_subviewport_containar.set_layer_id(l_id)
	new_subviewport_containar.name = 'SubViewPortContainer '+str(viewports.size())
	new_subviewport_containar.position.x -= canvas_size.x /2
	new_subviewport_containar.position.y -= canvas_size.y / 2
	$Control/Control.add_child(new_subviewport_containar)
	
	var new_subviewport = SubViewport.new()
	#new_subviewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	new_subviewport.size = canvas_size
	new_subviewport.handle_input_locally = false
	new_subviewport.transparent_bg = true
	new_subviewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
	new_subviewport.canvas_item_default_texture_repeat = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_REPEAT_ENABLED
	new_subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	new_subviewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED 
	#new_subviewport.msaa_2d = Viewport.MSAA_MAX
	#new_subviewport.use_taa = true
	#new_subviewport.msaa_2d = Viewport.MSAA_DISABLED
	#new_subviewport.anisotropic_filtering_level = Viewport.ANISOTROPY_16X
	new_subviewport_containar.add_child(new_subviewport)
	
	
	
	var new_canvas  = draw_canvas_scene.instantiate()
	#new_canvas.position = get_viewport().get_visible_rect().size / 2 - new_canvas.size / 2
	if l_id == -1:
		
		new_canvas.set_layer(GlobalCanvas.layer_counter)
	else:
		new_canvas.set_layer(l_id)
	if l_id == 0:
		color_background = Global.config_project['BackgoundColor']
	new_canvas.set_backround(color_background)
	new_canvas.texture_filter =CanvasItem.TEXTURE_FILTER_LINEAR
	#new_canvas.position = 
	new_subviewport.add_child(new_canvas)
	canvas_draw = new_canvas
	GlobalCanvas.layer_counter += 1
	GlobalCanvas.add_layer.emit()
	
	
	new_canvas.size = canvas_size
	new_canvas.setup_canvas_signal.emit()
	
	
	for i in range(2):
		
		var textrure_rect = TextureRect.new()
		textrure_rect.texture_filter =CanvasItem.TEXTURE_FILTER_LINEAR
		textrure_rect.size = canvas_size
		textrure_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if i == 0:
			textrure_rect.name = 'PastFrame'
			textrure_rect.z_index = -1
		else:
			textrure_rect.name = 'NextFrame'
		new_subviewport_containar.add_child(textrure_rect)
	
	
	viewports.append(new_subviewport_containar)
	layers.append(new_canvas)
	
	
	new_subviewport_containar.work_started.emit()
	GlobalCanvas.set_current_layer(GlobalCanvas.current_layer)
	
func remove_layer(layer_id : int):
	#for i in range(layer_id + 1, layers.size()):
		#layers[i].layer_id -= 1
		#viewports[i].layer_id -= 1
	GlobalCanvas.layer_counter -= 1
	GlobalCanvas.layers -= 1
	GlobalCanvas.layers_pos.erase(layer_id)
	var pos_layer = GlobalCanvas.layers_pos
	var index = pos_layer.find(layer_id)
	layers[layer_id].queue_free()
	viewports[layer_id].queue_free()
	layers.remove_at(layer_id)
	viewports.remove_at(layer_id)
	print(GlobalCanvas.layers_pos, 'SIZE')
	#await get_tree().

	


func update_z_index_layer(new_pos: int, past_pos:int, id_layer: int):
	var index = find_index(id_layer)
	for i in viewports:
		if i.z_index == new_pos:
			i.z_index = past_pos
			break
	viewports[index].z_index = new_pos
	
func get_canvas_images():
	var layer_pos : Array = GlobalCanvas.get_layers_pos()
	var result : Array = []
	for id in GlobalCanvas.layers_pos:
		var index = find_child_index(id)
		result.append(layers[index].frames)
	GlobalAnimationTimeline.combine_frames_layers_starteded.emit(result)
func find_child_index(id:int):
	for i in range(layers.size()):
		if layers[i].layer_id == id:
			return i
	return -1
	

func get_images():
	var images : Array[Image] = []
	for id in GlobalCanvas.layers_pos:
		var index = find_child_index(id)
		images.append(layers[index].get_image())
		print('ID ', id,' Index ', index )
	print(images)
	var result_image : Image= GlobalCanvas.combine_image_layers(images, canvas_size)
	print_debug(result_image)
	
func get_images_to_save():
	await  get_tree().create_timer(0.01).timeout
	var images : Array = []
	for layer in layers:
		var id_layer = layer.layer_id
		
		images.append([id_layer, layer.get_frames()])
	Global.frames_to_get.emit(images)

func  update_current_layer(id:int):
	#print('sadasda')
	for i in range(viewports.size()):
		if viewports[i].layer_id == id: 
			viewports[i].mouse_filter = Control.MOUSE_FILTER_PASS
			continue
		viewports[i].mouse_filter = Control.MOUSE_FILTER_IGNORE

func get_z_index_layer(id: int):
	var index = find_index(id)
	GlobalCanvas.get_z_index_layer_finished.emit(viewports[index].z_index)

func find_index(id:int):
	for i in range(viewports.size()):
		if viewports[i].layer_id == id:return i
	return -1
	
