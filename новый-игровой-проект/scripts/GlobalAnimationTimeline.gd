extends Node


signal leftframe_button_pressed
signal ritghframe_button_pressed
signal addframe_button_pressed
signal play_button_pressed
signal save_button_pressed


#test
signal brush_size(value: float)
signal color_change(color: Color)


#для кнопки play
signal amination_finished

signal get_image_finished(im: Image) 

signal add_frame_started(layer:int, frame_id:int)
signal update_current_card_startede(layer: int, f_id:int)
signal update_current_frame_onion_skin(layer:int, frame_id:int)
signal add_frame_finished(layer:int, frame_id:int)

signal combine_frames_layers_starteded(frames:Array)

signal add_layer
signal layer_removed(layer_id: int)

signal update_scrol_value(value: float)
signal left_frame_updated
signal  frame_added(l:int,f:int)

signal frame_removed(layer: int,frame_id: int, frame_index: int)

var is_lopped_animation : bool = true

var is_plaing_animation : bool = false

var frames_id : Array = []
#[layer_id,[frame_id]]
var max_frame_id : int = 0

var current_cadr : int = 0




func _ready() -> void:
	play_button_pressed.connect(func():is_plaing_animation = !is_plaing_animation)
	combine_frames_layers_starteded.connect(combine_frames)

func add_frame(new_layer_id:int, new_frame_id:int, index_layer : int = -1):
	var index : int = 0
	if index_layer == -1:
		index = find_layer(new_layer_id)
		
	else:
		index = index_layer
	if index != -1:
		if frames_id[index][-1].find(new_frame_id) != -1:return
		frames_id[index][-1].append(new_frame_id)
		frames_id[index][-1].sort()
	else:
		frames_id.append([new_layer_id,[new_frame_id]])
	add_frame_started.emit(new_layer_id, new_frame_id)
	current_cadr = new_frame_id
	update_c_frame(0,current_cadr)
	print('CURRENT ', current_cadr)
		
func add_frame_button():
	var layer = GlobalCanvas.current_layer
	var result = max_id_frame_in_layers(layer)
	add_frame(layer,result[0]+1,result[1])
	frame_added.emit(layer, result[0]+1)
	
	
	
func find_layer(layer: int):
	for i in range(frames_id.size()):
		if frames_id[i][0] == layer:
			return i
	return -1

func left_frame():
	if current_cadr - 1 < 0: return
	current_cadr -= 1
	change_amin_slider(current_cadr)
func right_frame():
	if current_cadr + 1 > max_id_frame_in_layers():return
	current_cadr += 1
	change_amin_slider(current_cadr)
func min_frame():
	current_cadr = min_id_frame_in_layers()
	change_amin_slider(current_cadr)
func max_frame():
	current_cadr = max_id_frame_in_layers()
	change_amin_slider(current_cadr)

func update_current_cadr(layer_id:int, fr_id:int):
	var index = find_layer(layer_id)
	if index == -1:return
	var fr = frames_id[index][-1]
	var index_frame = fr.find(fr_id)
	if index_frame < 0:
		return
		for i in range(fr.size()-1,-1,-1):
			if fr[i] <fr_id:
				index_frame = i
				break
		if index_frame < 0: return
	update_current_card_startede.emit(layer_id,fr_id)
	current_cadr = fr_id
	print('CURRENT ', current_cadr)
func update_frame():
	pass
	
func update_c_frame(l,f):
	change_amin_slider(f)
func change_amin_slider(frame_id: int):
	print(frames_id)
	for i in range(frames_id.size()):
		update_current_cadr(frames_id[i][0],frame_id)
		


func combine_frames(frames_layers:Array):
	var minn : int = min_id_frame_in_layers()
	var maxx : int = max_id_frame_in_layers()
	var past_frames : Array = []
	
	
	
	var result : Array[Image] = []
	for i in range(frames_id.size()):
		past_frames.append([GlobalCanvas.layers_pos[i],Image.new()])
	
	for i in range(minn, maxx+1):
		for l in range(frames_id.size()):
			var id = GlobalCanvas.layers_pos[l]
			var index = find_layer(id)
			#if index == -1:continue
			var ind = frames_id[index][-1].find(i)
			#if ind >= 0:
			past_frames[l][-1] = frames_layers[l][ind]
		var images_layers : Array[Image] = []
		for l in past_frames:
			images_layers.append(l[-1])
		var result_image = GlobalCanvas.combine_image_layers(images_layers)
		result.append(result_image)
	print_debug(result)
	save_frames_on_png(result)

func min_id_frame_in_layers():
	var minn = 10 * 1000
	for i in frames_id:
		var value : int = i[-1][0]
		if value < minn:
			minn = value
	return minn
	
func max_id_frame_in_layers(layer_id : int = -1):
	
	if layer_id == -1:
		var maxx = -10 * 1000
		for i in frames_id:
			if i[-1].is_empty():continue
			var value : int = i[-1][-1]
			if value > maxx:
				maxx = value
		return maxx
	else:
		var index = find_layer(layer_id)
		var frame = frames_id[index][-1].max()
		return [frame, index]
	

func save_frames_on_png(frames: Array[Image]):
	GlobalCanvas.temporary_folder_clear_started.emit()
	await GlobalCanvas.temporary_folder_clear_finished
	var folder_path : String = ''
	if Global.state_export_to != Global.EXPORT_TO.IMAGES:
		folder_path = 'user://saves'
	else:
		folder_path = Global.folder_save
	if not DirAccess.dir_exists_absolute(folder_path):
		DirAccess.make_dir_absolute(folder_path)
		
	for i in range(frames.size()):
		var image = frames[i]
		
		var frame_number = '%04d' % (i + 1)
		var file_path = folder_path.path_join('frame_'+frame_number+'.png')
		
		var error = image.save_png(file_path)
		if error != OK:
			push_error('Ошибка')
	if  Global.state_export_to == Global.EXPORT_TO.IMAGES:return
	Global.save_to_mp4_started.emit()
		#.save_png('user://saves')
		
func get_frames(l_id:int):
	var index = find_layer(l_id)
	return frames_id[index]
func update_pos_layer(layer_id_1 : int, layer_id_2):
	pass
	
func remove_layer():
	var current_layer : int = GlobalCanvas.current_layer
	var index_layer = find_layer(current_layer)
	print(index_layer, frames_id)
	frames_id.remove_at(index_layer)
	for i in frames_id:
		if i[0] > current_layer:
			i[0] -= 1
	print_debug(frames_id)
	layer_removed.emit(index_layer)
	
func find_frame(index_layer: int, frame_id: int):
	
	var frames = frames_id[index_layer][-1]
	for i in range(frames.size()):
		if frames[i] == frame_id:
			return i
	return -1
	
func remove_frame():
	if current_cadr == 1:return
	var index_layer =  find_layer(GlobalCanvas.current_layer)
	print('Frame : ', current_cadr)
	var index = find_frame(index_layer, current_cadr)
	if index == -1:return
	frames_id[index_layer][-1].remove_at(index)
	frame_removed.emit(GlobalCanvas.current_layer, current_cadr, index)
