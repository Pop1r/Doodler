extends Node



signal save_to_mp4_started
signal new_project_created
signal fps_updated
signal frames_to_get(images: Array)
signal get_image_to_save
signal save_frames_to_png
signal open_project(dir: String)
signal load_items(layer_id: int, fr_id: Array)
signal frames_loaded(l_id:int, fr_id:Array)

enum EXPORT_TO {MP4,GIF, WebM, MOV, AVI , IMAGES}

var state_export_to : EXPORT_TO = EXPORT_TO.MP4
var file_path : String = ''


const VERSION = 'ALPHA 0.0.1'
var config_project : Dictionary = {
	'Width':1920,
	'Height':1080,
	'Name':'MyAnimation',
	'BackgoundColor':Color.WHITE,
	'Data':{}
}

var folder_save : String = 'user://'
var FPS : int = 12
var name_project : String = ''
var pressure : bool = true
func _ready() -> void:
	open_project.connect(load_project)
func set_fps(value:int):
	FPS = value
	fps_updated.emit()

func get_canvas_size():
	return Vector2(config_project['Width'],config_project['Height'])
func get_background_color():
	return config_project['BackgoundColor']

func create_new_project():
	var size = get_canvas_size()
	GlobalCanvas.layer_counter  = 0 
	GlobalCanvas.layers = 0 
	GlobalCanvas.current_layer = 1
	GlobalCanvas.canvas_size = size
	GlobalTools.current_tools = 0
	GlobalAnimationTimeline.frames_id = []
	GlobalAnimationTimeline.max_frame_id  = 0
	GlobalCanvas.layers_pos = []
	config_project['Data'] = {}
	#GlobalAnimationTimeline.current_cadr  = [0,0]
	new_project_created.emit()


func save_project(dir:String = 'user:/'):
	if config_project["Name"] =='':
		config_project['Name'] = 'MyAnimation'
	var temp_dir = 'user://'+config_project['Name']+'/'
	DirAccess.make_dir_absolute(temp_dir)
	var project_data : Dictionary = {
		'name':config_project['Name'],
		'canvasSize': get_canvas_size(),
		'fps':FPS,
		'currentFrame': GlobalAnimationTimeline.current_cadr,
		'currentLayer': GlobalCanvas.current_layer,
		'isLoop': GlobalAnimationTimeline.is_lopped_animation,
		'layerPos':GlobalCanvas.layers_pos,
		'framesId':GlobalAnimationTimeline.frames_id,
		'layers': GlobalCanvas.layers,
		'layerCounter':GlobalCanvas.layer_counter,
		'currentTools':GlobalTools.current_tools,
		'max_frame_id' : GlobalAnimationTimeline.max_frame_id,
		'BackgoundColor':config_project['BackgoundColor'],
		'version': VERSION
	}

	get_image_to_save.emit()
	var images = await frames_to_get
	save_framse(images,temp_dir)
	var file = FileAccess.open(temp_dir+'data.json',FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(project_data,"\t"))
		file.close()
		
	if zip_folder(temp_dir,dir+'/'+config_project['Name']+'.doodler' ):
		print('ЗИПЧИК СПРАВИЛСЯ')
		file.close()
		if cleanup_temp_files(temp_dir):
			print("УСПЕШНО")
			cleanup_temp_files(temp_dir+'/data')
			cleanup_temp_files(temp_dir)
	else:
		print('Ошибка в зипе')
		
	
func save_framse(images : Array,temp_dir:String):
	var dir = DirAccess.open(temp_dir)
	if dir:
		dir.make_dir(temp_dir+'data')
	for i in images:
		for j  in range(i[-1].size()):
			i[-1][j].save_png(temp_dir+'/data/'+str(i[0])+'.'+str(j)+'.png')
	print('FINISH')

var frames_load : Array
func load_project(f_path : String):
	var file = FileAccess.open(f_path+'/data.json', FileAccess.READ)
	if not file:return
	var json_data = JSON.new()
	var error = json_data.parse(file.get_as_text())
	if error != OK:return
	var data = json_data.get_data()
	print(data)
	var canvas_size : String = data.get('canvasSize')
	canvas_size = canvas_size.replace('(','')
	canvas_size = canvas_size.replace(')','')
	canvas_size = canvas_size.replace(' ','')
	var spl = canvas_size.split(',',true,0)
	config_project['Data']= data.duplicate()
	config_project['Widht'] = int(spl[0])
	config_project['Height'] = int(spl[1])
	GlobalCanvas.canvas_size = Vector2(int(spl[0]),int(spl[1]))
	config_project['Name'] = data.get('name')
	if data.get('BackgoundColor'):
		var c : String = data.get('BackgoundColor')
		c = c.replace('(','')
		c = c.replace(')','')
		var a = c.split(',')
		var color = Color(float(a[0]),float(a[1]),float(a[2]),float(a[3]))
		config_project['BackgoundColor'] = color
	GlobalAnimationTimeline.current_cadr = int(data.get('currentFrame'))
	GlobalCanvas.current_layer = int(data.get('currentLayer'))
	GlobalTools.current_tools = int(data.get('currentTools'))
	FPS = int(data.get('fps'))
	var frames_id = data.get('framesId')
	var result = conver(frames_id)
	GlobalAnimationTimeline.frames_id = result
	GlobalAnimationTimeline.is_lopped_animation = data.get('isLoop')
	GlobalCanvas.layer_counter = int(data.get('layerCounter'))
	var l_pos = data.get('layerPos')
	var result2 = conver(l_pos)
	GlobalCanvas.layers_pos = result2
	GlobalCanvas.layers = int(data.get('layers'))
	GlobalAnimationTimeline.max_frame_id = int(data.get('max_frame_id'))
	var frames : Array = load_frame(f_path,GlobalCanvas.layers_pos)
	frames_load = frames
	#print(frames)
	file.close()
	if cleanup_temp_files(f_path):
		print(f_path)
		print("УСПЕШНО")
		cleanup_temp_files(f_path+'/data')
		cleanup_temp_files(f_path)
	new_project_created.emit()
	
	
func conver(value):
	var value_type = typeof(value)
	match value_type:
		TYPE_ARRAY:
			var new_array = []
			for item in value:
				new_array.append(conver(item))
			return new_array
		TYPE_FLOAT, TYPE_INT:
			return int(value)
		_:
			return value

func start_load_items():
	var frames_id = GlobalAnimationTimeline.frames_id
	for i in frames_id:
		load_items.emit(i[0],i[-1])
		
		
func load_frame(f_path:String,layers_pos:Array):
	var dir = DirAccess.open(f_path+'/data')
	var folder_path = f_path+'/data'
	if not dir:return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var images = []
	var id = []
	for i in range(layers_pos.size()):
		images.append([i,[]])
		id.append([i,[]])
	
	while file_name != '':
		if not dir.current_is_dir() and file_name.get_extension().to_lower() == 'png':
			print(file_name)
			var f_name = file_name.replace('.png','')
			var arg = f_name.split('.')
			
			var full_path = folder_path.path_join(file_name)
			var image = load_png_image(full_path)
			if image:
				if image.get_format() != Image.FORMAT_RGBA8:
					image.convert(Image.FORMAT_RGBA8)
				images[int(arg[0])][-1].append(image)
				id[int(arg[0])][-1].append(int(arg[-1]))
		file_name = dir.get_next()
	dir.list_dir_end()
	for i in range(images.size()):
		images[i][-1] = sort_frames(images[i][-1],id[i][-1] )
	print(images)
	return images

func load_png_image(f_path:String):
	var image = Image.new()
	var error = image.load(f_path)
	if error != OK:
		return null
	return image

func load_frame_in_canvas():
	for i in frames_load:
		frames_loaded.emit(i[0],i[-1])
	start_load_items()

func sort_frames(images, frame_id):
	var fr_id = frame_id
	var fr_image = images
	
	var par = []
	#if frames_id.find(f) == -1:return
	for i in range(fr_id.size()):
		par.append([fr_id[i],fr_image[i]])
	
	par.sort_custom(func(a,b):return a[0] < b[0])
	
	for i in range(par.size()):
		fr_id[i] = par[i][0]
		fr_image[i] = par[i][1]
	return fr_image


func zip_folder(source_folder_path: String, output_zip_path: String) -> bool:
	
	# Проверяем исходную папку
	if not DirAccess.dir_exists_absolute(source_folder_path):
		return false
	
	# Проверяем, есть ли файлы в папке
	var dir = DirAccess.open(source_folder_path)
	if not dir:
		return false
	
	# Создаем родительскую папку для ZIP файла
	var output_dir = output_zip_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(output_dir):
		var make_dir_result = DirAccess.make_dir_recursive_absolute(output_dir)
		if make_dir_result != OK:
			return false
	
	# СОЗДАЕМ ZIP PACKER - ВАЖНО: передаем output_zip_path, а не source_folder_path!
	var zip_packer = ZIPPacker.new()
	var err = zip_packer.open(output_zip_path)
	
	if err != OK:
		return false
	
	
	# Добавляем файлы рекурсивно
	var add_files_success = _add_files_to_zip_recursive(dir, "", source_folder_path, zip_packer)
	
	# Закрываем архив
	zip_packer.close()
	
	if add_files_success:
		# Проверяем, что архив создан
		if FileAccess.file_exists(output_zip_path):
			var file = FileAccess.open(output_zip_path, FileAccess.READ)
			var size = file.get_length()
			file.close()
			return true
		else:
			return false
	else:
		if FileAccess.file_exists(output_zip_path):
			DirAccess.remove_absolute(output_zip_path)
		return false

func _add_files_to_zip_recursive(dir: DirAccess, current_path: String, base_path: String, zip_packer: ZIPPacker) -> bool:
	var success = true
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var relative_path = current_path.path_join(file_name) if current_path != "" else file_name
			var absolute_path = base_path.path_join(relative_path)
			
			if dir.current_is_dir():
				var sub_dir = DirAccess.open(absolute_path)
				if sub_dir:
					if not _add_files_to_zip_recursive(sub_dir, relative_path, base_path, zip_packer):
						success = false
				else:
					success = false
			else:
				if not _add_single_file_to_zip(absolute_path, relative_path, zip_packer):
					success = false
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return success

func _add_single_file_to_zip(file_path: String, zip_path: String, zip_packer: ZIPPacker) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var file_size = file.get_length()
	var file_data = file.get_buffer(file_size)
	file.close()
	
	# Начинаем запись файла в ZIP
	var start_result = zip_packer.start_file(zip_path)
	if start_result != OK:
		return false
	
	# Записываем данные
	var write_result = zip_packer.write_file(file_data)
	if write_result != OK:
		return false
	
	return true



# Функция для распаковки архива
func unzip_file(zip_file_path: String, target_folder_path: String) -> bool:
	# Создаем ZipReader
	var zip_reader = ZIPReader.new()
	
	# Открываем zip файл для чтения
	var err = zip_reader.open(zip_file_path)
	if err != OK:
		push_error("Не удалось открыть ZIP файл для чтения. Код: " + str(err))
		return false
	
	# Создаем целевую папку, если её нет
	DirAccess.make_dir_recursive_absolute(target_folder_path)
	
	# Получаем список всех файлов в архиве
	var files = zip_reader.get_files()
	print("Найдено файлов в архиве: ", files.size())
	
	for file_path in files:
		# Читаем данные файла из архива
		var file_data = zip_reader.read_file(file_path)
		
		# Создаем полный путь для выходного файла
		var output_file_path = target_folder_path.path_join(file_path)
		
		# Создаем необходимые подпапки для файла
		var output_dir = output_file_path.get_base_dir()
		DirAccess.make_dir_recursive_absolute(output_dir)
		
		# Записываем данные в файл
		var file = FileAccess.open(output_file_path, FileAccess.WRITE)
		if file:
			file.store_buffer(file_data)
			file.close()
			print("✓ Распакован: ", file_path)
		else:
			push_error("Не удалось записать файл: " + output_file_path)
			zip_reader.close()
			return false
	
	# Закрываем архив
	zip_reader.close()
	
	return true


func cleanup_temp_files(temp_dir: String):
	var dir = DirAccess.open(temp_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				dir.remove(file_name)
			file_name = dir.get_next()
		DirAccess.remove_absolute(temp_dir)
		return true
	else:
		return false
	
