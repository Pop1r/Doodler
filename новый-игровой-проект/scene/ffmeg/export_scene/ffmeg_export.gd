extends Node


func _ready() -> void:

	GlobalCanvas.temporary_folder_clear_started.connect(func():cleanup_temp_files('user://saves'))
	Global.save_to_mp4_started.connect(save_to_start)
func save_to_start():
	var format : String = ''
	match Global.state_export_to:
		Global.EXPORT_TO.MP4:
			format = '.mp4'
		Global.EXPORT_TO.GIF:
			format = '.gif'
		Global.EXPORT_TO.WebM:
			format = '.webm'
		Global.EXPORT_TO.AVI:
			format = '.avi'
		Global.EXPORT_TO.MOV:
			format = '.mov'
	var name_animation : String = Global.config_project['Name']
	if name_animation == '':
		name_animation = 'MyAnimation'
	export_video('user://saves',Global.folder_save + '/'+name_animation+format,Global.FPS)

func export_video(file_path:String, output_path: String, fps: int = 30) -> bool:
	# Ждем инициализации FFmpeg
	#if not ffmpeg_setup.is_setup_complete():
		#print("FFmpeg не настроен")
		#return false
	
	# Сохраняем кадры временно
	#var temp_dir = "user://temp_frames_%s" % Time.get_unix_time_from_system()
	#if not save_frames(frames, temp_dir):
		#return false
	
	# Создаем видео
	var success = create_video_from_frames(file_path, output_path, fps)
	
	# Очищаем временные файлы
	#cleanup_temp_files('user://saves')
	
	return success



func create_video_from_frames(temp_dir: String, output_path: String, fps: int) -> bool:
	var ffmpeg_path : String = 'ffmpeg.exe'
		#ffmpeg_path = 'ffmpeg.exe'
	
	# Абсолютные пути для Android
	var input_pattern = ProjectSettings.globalize_path(temp_dir) + "/frame_%04d.png"
	var output_abs = ProjectSettings.globalize_path(output_path)
	var args : Array = []
	
	match Global.state_export_to:
		Global.EXPORT_TO.MP4:
			args = [
			"-y",
			"-framerate", str(fps),
			"-i", input_pattern,
			"-c:v", "libx264",
			"-pix_fmt", "yuv420p",
			"-crf", "23",
			output_abs
			]
		Global.EXPORT_TO.GIF:
			var palette_args = [
			"-y",
			"-i", input_pattern,
			"-vf", "fps=" + str(fps) + ",scale=640:-1:flags=lanczos,palettegen",
			"palette.png"
			]
			args = [
			"-y",
			"-i", input_pattern,
			"-i", "palette.png",
			"-filter_complex", "fps=" + str(fps) + ",scale=640:-1:flags=lanczos[x];[x][1:v]paletteuse",
			output_abs
			]
			var exit_code_palitre = OS.execute(ffmpeg_path, palette_args)
			if exit_code_palitre == OK:
				print('ПАЛИТРА ВСЕ ХОРОШО')
			else:
				print('ОШБКА С ПАЛИТРОЙ: ', exit_code_palitre)
		Global.EXPORT_TO.WebM:
			args = [
				'-y',
				'-framerate',str(fps),
				'-i',input_pattern,
				'-c:v','libvpx-vp9',
				'-crf','30',
				'-b:v','0',
				'-row-mt','1',
				output_abs
			]
		Global.EXPORT_TO.MOV:
			args = [
				'-y',
				'-framerate',str(fps),
				'-i',input_pattern,
				'-c:v','prores_ks',
				'-profile:v','3',
				'-c:a','pcm_s16le',
				output_abs
			]
		Global.EXPORT_TO.AVI:
			args = [
				'-y',
				'-framerate',str(fps),
				'-i',input_pattern,
				'-c:v','mpeg4',
				'-q:v','5',
				'-c:a','mp3',
				output_abs
			]
	
	
	
	var exit_code = OS.execute(ffmpeg_path, args)
	
	if exit_code == 0:
		print("Видео создано: ", output_path)
		return true
	else:
		print("Ошибка создания видео: ", exit_code)
		return false

func cleanup_temp_files(temp_dir: String):
	await get_tree().create_timer(0.1).timeout #задержка чтоб метод сборки кадров в гл успел начать ждать сигнал
	# а иначе фигня будет
	var dir = DirAccess.open(temp_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				dir.remove(file_name)
			file_name = dir.get_next()
		DirAccess.remove_absolute(temp_dir)
		GlobalCanvas.temporary_folder_clear_finished.emit()
	else:
		
		GlobalCanvas.temporary_folder_clear_finished.emit()
	
func get_current_directory():
	var dialog = FileDialog.new()
	var current_dir = dialog.current_dir
	dialog.free()
	print(current_dir)
	return current_dir
