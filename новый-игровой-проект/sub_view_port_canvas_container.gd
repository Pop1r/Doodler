extends SubViewportContainer

class_name  CanvasContainer

signal work_started

var children : Array = []
var draw_canvas : DrawCanvas
var past_frame_texture_rect : TextureRect
var next_frame_texture_rect : TextureRect
var layer_id : int = 0

var onion_skin : Dictionary = {
	'is_past_frame':true,
	'amount_past_frame':5,
	'is_next_frame':true,
	'amount_next_frame':5
}


var costal : int = 0
var is_enebled_next_frame : bool = true
var is_enebled_past_frame : bool = true
var is_hide_onion_skin : bool = false
var is_hide_onion_skin_next : bool = false
var is_hide_onion_skin_all : bool = false
var current_cadr : int  = 0
var is_playing_animation : bool = false
func _ready() -> void:
	GlobalAnimationTimeline.play_button_pressed.connect(play_animation)
	GlobalTools.past_frame_updated.connect(update_past_frame_amount)
	GlobalTools.past_frame_enebled.connect(update_enebled_past_frame)
	GlobalTools.next_frame_updated. connect(update_next_frame_amount)
	GlobalTools.next_frame_enebled.connect(update_enebled_next_frame)
	work_started.connect(start)
	GlobalAnimationTimeline.update_current_frame_onion_skin.connect(update_current_cadr)
	GlobalAnimationTimeline.add_frame_finished.connect(add)
	GlobalCanvas.set_visible_layer.connect(visible_layer)
func visible_layer(l:int, value:bool):
	if l != layer_id:return
	visible = value

func play_animation():
	is_playing_animation = !is_playing_animation
	if not is_playing_animation:
		is_hide_onion_skin_all = false
		update_current_cadr(layer_id,current_cadr)

func update_enebled_past_frame(val:bool):
	is_enebled_past_frame = val
	update_current_cadr(layer_id,current_cadr)
func update_enebled_next_frame(val:bool):
	is_enebled_next_frame = val
	update_current_cadr(layer_id,current_cadr)
func add(l,f):
	if l != layer_id: return
	print(f)
	update_current_cadr(l,f)

func start():
	children = get_children()
	for i in children:
		if i is SubViewport:
			draw_canvas = i.get_child(0)

		elif i.name == 'PastFrame':
			past_frame_texture_rect = i
		elif i.name == 'NextFrame':
			next_frame_texture_rect = i
	for i in range(2):
		add_past_frame()
	for i in range(2):
		add_next_frame()

func set_layer_id(value:int):
	layer_id = value

func hide_onion_skin():
	if not is_enebled_past_frame or is_playing_animation:
		for i in past_frame_texture_rect.get_children():
			i.hide()
		is_hide_onion_skin = true
	if not is_enebled_next_frame or is_playing_animation:
		for i in next_frame_texture_rect.get_children():
			i.hide()
		is_hide_onion_skin_next = true
	if is_playing_animation:
		is_hide_onion_skin_all = true
	

func update_current_cadr(l_id:int, f_index:int):
	if l_id != layer_id:return
	current_cadr = f_index
	if is_playing_animation and not is_hide_onion_skin_all \
	or not is_enebled_past_frame and not is_hide_onion_skin\
	or not is_enebled_next_frame and not is_hide_onion_skin_next:
		hide_onion_skin()
	#elif  GlobalAnimationTimeline.is_plaing_animation \
	#or not is_enebled_past_frame: return
	
	
	if not is_enebled_next_frame and not is_enebled_past_frame \
	or is_hide_onion_skin_all:return
	if costal == 0:
		costal = 1 
		return
	if draw_canvas == null:return
	var images : Array = draw_canvas.get_frames()
	var alpha_values : Array[float]= []
	var delta_aplha : float = 1.0 / images.size()
	var past_alpha : float = 0.0
	for i in range(images.size()):
		past_alpha += delta_aplha
		alpha_values.append(past_alpha)
	if is_enebled_past_frame:
		past_frames_update(images,f_index)
	if is_enebled_next_frame:
		if f_index >= images.size():return
		next_frmes_update(images,f_index)
	#var past_frame = await combine_frame(images, size, alpha_values)
	#past_frame_texture_rect.texture = ImageTexture.create_from_image(past_frame)
	#print('AALLLOOO')
		
func next_frmes_update(images:Array[Image],f_index:int):
	is_hide_onion_skin_next = false
	var frames = GlobalAnimationTimeline.get_frames(layer_id)[-1]
	print(frames, ' : ',f_index,' ', images.size())
	var ps_frames = next_frame_texture_rect.get_children()
	var max_frame = f_index + 1 #неудачное название
	var MAX_frame_id = frames[-1]
	var alpha_delta = 0.5 / float(ps_frames.size())
	var past_alpha = 0.6
	#if ps_frames.size() != frames.size():return
	past_frame_texture_rect.modulate = Color.RED
	if f_index <= ps_frames.size():
		for i in ps_frames:
			i.hide()
	for i : TextureRect in ps_frames:
		
		if max_frame > MAX_frame_id:
			i.hide()
			break
		var index = frames.find(max_frame)
		if index != -1 and index < frames.size():
			past_alpha -= alpha_delta
			i.show()
			i.texture = ImageTexture.create_from_image(images[index])
			i.modulate.a = past_alpha
		else:
			i.hide()
		max_frame += 1
		
		
func past_frames_update(images:Array[Image],f_index:int):

	is_hide_onion_skin = false
	var frames = GlobalAnimationTimeline.get_frames(layer_id)[-1]
	print(frames, ' : ',f_index,' ', images.size())
	var ps_frames = past_frame_texture_rect.get_children()
	var max_frame = f_index - 1

	var alpha_delta = 0.5 / float(ps_frames.size())
	var past_alpha = 0.6
	past_frame_texture_rect.modulate = Color.RED
	if f_index <= ps_frames.size():
		for i in ps_frames:
			i.hide()
	for i : TextureRect in ps_frames:
		
		if max_frame < 0:
			i.hide()
			break
		var index = frames.find(max_frame)
		if index != -1:
			past_alpha -= alpha_delta
			i.show()
			i.texture = ImageTexture.create_from_image(images[index])
			i.modulate.a = past_alpha
		else:
			i.hide()
		max_frame -= 1
		
func add_past_frame():
	var text_rect = TextureRect.new()
	text_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	past_frame_texture_rect.add_child(text_rect)
func remove_past_frame(amount:int):
 
	var children_past_frame = past_frame_texture_rect.get_children()
	for i in range(amount):
		if children_past_frame.size()> 0:
			children_past_frame[-1].queue_free()
			children_past_frame.remove_at(-1)
			
func add_next_frame():
	var text_rect = TextureRect.new()
	text_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	next_frame_texture_rect.add_child(text_rect)
func remove_next_frame(amount:int):
	var children_next_frame = next_frame_texture_rect.get_children()
	for i in range(amount):
		if children_next_frame.size()> 0:
			children_next_frame[-1].queue_free()
			children_next_frame.remove_at(-1)

func update_next_frame_amount(new_amount: int):
	var current_amount = next_frame_texture_rect.get_children().size()
	if current_amount < new_amount:
		for i in range(new_amount-current_amount):
			add_next_frame()
		update_current_cadr(layer_id,current_cadr)
	else:
		remove_next_frame(current_amount - new_amount)
func update_past_frame_amount(new_amount: int):
	var current_amount = past_frame_texture_rect.get_children().size()
	if current_amount < new_amount:
		for i in range(new_amount-current_amount):
			add_past_frame()
		update_current_cadr(layer_id,current_cadr)
	else:
		remove_past_frame(current_amount - new_amount)
