extends Control

#@onready var ffmpeg = $FFmpegPlugin

'''func _ready():
	# Проверяем доступность
	if ffmpeg:
		var info = ffmpeg.get_video_info("res://video183.mp4")
		print("Video info: ", info)
		
		# Декодируем асинхронно
		ffmpeg.decode_video_async("res://video183.mp4", "user://decoded.ogv")
		
		# Подключаем сигналы
		ffmpeg.video_decoded.connect(_on_video_decoded)
		ffmpeg.error_occurred.connect(_on_error)

func _on_video_decoded(path: String):
	print("Video ready: ", path)
	# Воспроизводим видео...

func _on_error(message: String):
	print("Error: ", message)'''
