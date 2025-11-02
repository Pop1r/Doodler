extends TextureRect

class_name DrawCanvas

signal setup_canvas_signal



@export var brush_size: float = 0.01
@export var brush_color: Color = Color.BLACK
var layer_id : int = 0

var canvas_image: Image
var canvas_texture: ImageTexture
var is_drawing: bool = false

var past_pos : Vector2 = Vector2.ZERO

var render_target: SubViewport


var color_backround : Color = Color.TRANSPARENT


var is_eraser : bool = false

var frames = []
var frames_id = []:
	set(value):
		if value.size() > 2:
			if value.get(0) == value.get(1):
				value.remove_at(0)
		frames_id = value
var current_frame : int = -1
#[frame_id,image]



var current_pressure: float = 0.0
var target_pressure: float = 0.0
var pressure_smoothing: float = 0.2  # Настройка плавности (0.1 - очень плавно, 0.5 - быстро)

var previous_position = Vector2.ZERO

func _ready():
	GlobalAnimationTimeline.add_frame_started.connect(add_frame)
	GlobalAnimationTimeline.update_current_card_startede.connect(update_current_cadr)
	GlobalAnimationTimeline.frame_removed.connect(remove_frame)
	Global.frames_loaded.connect(load_frames)
	GlobalTools.update_current_tools.connect(_update_current_tools)
	
	GlobalCanvas.set_visible_layer.connect(_set_visible)
	mouse_filter = Control.MOUSE_FILTER_PASS
	#expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	
	setup_canvas_signal.connect(setup_canvas)
	await get_tree().create_timer(0.5).timeout
	if frames.is_empty():
		GlobalAnimationTimeline.add_frame(layer_id, 1)
	
	

func set_backround(color: Color):
	color_backround = color
	
func set_layer(value: int):
	layer_id = value
	

func setup_canvas():
	var width = max(512, int(size.x))
	var height = max(512, int(size.y))
	
	canvas_image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	canvas_image.fill(color_backround) 
	
	canvas_texture = ImageTexture.create_from_image(canvas_image)
	
	texture = canvas_texture
	setup_shader_material()
	
	

func setup_shader_material():
	var materiall = ShaderMaterial.new()
	materiall.shader = load('res://scene/main/brush_shader.gdshader')
	material = materiall
	#material.set_shader_parameter('brush_texture',preload("res://assets/brushs/Sprite-0001.png"))
	# Устанавливаем текстуру в шейдер
	material.set_shader_parameter("canvas_texture", canvas_texture)
	material.set_shader_parameter("brush_color", brush_color)
	material.set_shader_parameter("brush_size", brush_size)
	material.set_shader_parameter("is_drawing", false)
	material.set_shader_parameter('texture_size',size)
	


func _gui_input(event):
	if GlobalCanvas.get_current_layer() != layer_id :return
	if event is InputEventMouseMotion:
		target_pressure = event.pressure
		if is_drawing:
			continue_drawing(event.position)
			#material.set_shader_parameter("brush_size", brush_size * event.pressure)

		elif event.pressure > 0:
			start_drawing(event.position)
			#material.set_shader_parameter("brush_size", brush_size * event.pressure)
			is_drawing = true
			
			current_pressure = event.pressure

		if event.pressure == 0 and is_drawing:
			is_drawing = false
			stop_drawing( event.position) 
			target_pressure = 0.0
		
func _process(delta: float) -> void:
	if GlobalCanvas.current_layer != layer_id:return
	if not material:return
	if not Global.pressure:return
	current_pressure =  max(0.08,lerp(current_pressure, target_pressure, pressure_smoothing))
	if is_drawing:
		material.set_shader_parameter("brush_size", brush_size * current_pressure)
		

	
func start_drawing(pos:Vector2):

	var mouse_pos = pos - global_position
	var uv_pos = mouse_pos / size

	past_pos = uv_pos

	
	if material is ShaderMaterial:
		
		material.set_shader_parameter('allow_blending', true)
		
		material.set_shader_parameter("draw_position", uv_pos)
		material.set_shader_parameter("previous_draw_position", uv_pos)
		material.set_shader_parameter("past_draw_position", uv_pos)
		material.set_shader_parameter("is_drawing", true)

		save_canvas_state()

func continue_drawing(pos:Vector2):

	var mouse_pos = pos- global_position
	var uv_pos = mouse_pos / size
	
	if material is ShaderMaterial:
		material.set_shader_parameter("allow_blending", true)
		material.set_shader_parameter("previous_draw_position", past_pos)
		material.set_shader_parameter("draw_position", uv_pos)
		save_canvas_state()
	
	past_pos = uv_pos

func stop_drawing(pos:Vector2):
	var uv_pos = (pos - global_position) / size
	
	if material is ShaderMaterial:
		material.set_shader_parameter('past_draw_position',uv_pos)
		material.set_shader_parameter("is_drawing", false)
	
	save_canvas_state()


var past_texture : ImageTexture 
func save_canvas_state():	

	#return
	if GlobalCanvas.get_current_layer() != layer_id :return
	await get_tree().process_frame

	var viewport = get_viewport()
	var image = viewport.get_texture().get_image()
	var rect = get_global_rect()

	var cropped_image = image.get_region(rect)

	if cropped_image.get_format() != Image.FORMAT_RGBA8:
		cropped_image.convert(Image.FORMAT_RGBA8)
		
	canvas_image = cropped_image
	canvas_texture.update(canvas_image)


		

	#past_texture = texture.duplicate()
	


func clear_canvas():
	canvas_image.fill(color_backround)
	canvas_texture.update(canvas_image)
	
	if material is ShaderMaterial:
		material.set_shader_parameter("canvas_texture", canvas_texture)

func set_brush_size(sizee: float):
	brush_size = clamp(sizee, 0.001, 0.1)
	if material is ShaderMaterial:
		material.set_shader_parameter("brush_size", brush_size)

func set_brush_color(color: Color):
	brush_color = color
	if material is ShaderMaterial:
		material.set_shader_parameter("brush_color", brush_color)


	
func _set_visible(id: int, is_vis: bool):
	if id != layer_id: return
	visible = is_vis
		
func get_image() -> Image:
	return canvas_image
func _update_current_tools(id:int):
	var keys = GlobalTools.tools_texture.keys()
	var key = keys[id]
	match key:
		'pen':
			set_tool_pen()
		'eraser':
			set_tool_eraser()
		
	
func set_tool_eraser():
	material.set_shader_parameter("is_eraser", true)

func set_tool_pen():
	material.set_shader_parameter("is_eraser", false)

		
func left_cadr():
	if frames.size() == 0:return
	frames[current_frame] = canvas_image.duplicate()
	current_frame -= 1
	if current_frame < 0:
		current_frame = frames.size()-1
	canvas_image = frames[current_frame].duplicate()
	canvas_texture.update(canvas_image)
	
func right_cadr():
	if frames.size() == 0:return
	frames[current_frame] = canvas_image.duplicate()
	current_frame += 1
	if current_frame == frames.size():
		current_frame = 0
	canvas_image = frames[current_frame].duplicate()
	canvas_texture.update(canvas_image)
	
func add_frame(l_id:int , f_id:int):
	if l_id != layer_id:return
	print_debug(f_id)
	if frames.size()> 0:
		if frames.size() > current_frame:
			frames[current_frame] = canvas_image.duplicate()
	frames_id.append(f_id)
	clear_canvas()
	frames.append(canvas_image)
	
	sort_frames(l_id,f_id)
	
	#
	print(frames_id)
	
func sort_frames(l, f):
	if frames_id.size() != frames.size():
		frames_id.pop_at(-1)
	frames_id = frames_id #кудаже без костылей) 
	var fr_id = frames_id
	var fr_image = frames
	
	var par = []
	for i in range(fr_id.size()):
		par.append([fr_id[i],fr_image[i]])
	par.sort_custom(func(a,b):return a[0] < b[0])
	for i in range(par.size()):
		fr_id[i] = par[i][0]
		fr_image[i] = par[i][1]
	
	frames_id = fr_id
	frames = fr_image	
	current_frame = frames_id.find(f)
	GlobalAnimationTimeline.add_frame_finished.emit(l,f)
	
var is_past_remove_frame : bool = false

func update_current_cadr(l_id:int, f_index:int):
	if l_id != layer_id:return
	print('LAYYYER: ', frames_id)
	var index = frames_id.find(f_index)
	if index == -1:return
	if not is_past_remove_frame:
		frames[current_frame] = canvas_image.duplicate()
	else:
		is_past_remove_frame = true
	#if frames_id.size() != frames.size():return
	canvas_image = frames[index]
	canvas_texture.update(canvas_image)
	current_frame = index
	
	GlobalAnimationTimeline.update_current_frame_onion_skin.emit(l_id,f_index)
	
func get_canvas_image(l_id: int, f_index:int):
	if l_id != layer_id:return
	return frames[f_index]
	
func get_frames():
	if frames.is_empty():
		return []
	#var images  = sort_frames()
	var result : Array[Image] = []
	for i : Image in frames:
		result.append(i.duplicate())
	return result
	
func remove_frame(layer: int, frame_id: int, frame_index: int):
	if layer != layer_id:return
	clear_canvas()
	frames.remove_at(frame_index)
	frames_id.remove_at(frame_index)
	is_past_remove_frame = true
	
func load_frames(l_id:int, f:Array):
	if l_id != layer_id:return
	if f.is_empty():return
	var index = GlobalAnimationTimeline.find_layer(layer_id)
	frames_id = GlobalAnimationTimeline.frames_id[index][-1]
	frames = f
	update_fr(frames_id[-1])

func update_fr( f_index:int):
	var index = frames_id.find(f_index)
	canvas_image = frames[index]
	canvas_texture.update(canvas_image)
	current_frame = index
