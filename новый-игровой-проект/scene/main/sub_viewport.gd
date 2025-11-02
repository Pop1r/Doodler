extends SubViewport

@onready var parent = get_parent().get_parent().get_parent()
var canvas_image: Image
var canvas_texture: ImageTexture

func _ready():
	size =parent.size
	$TextureRect.size =parent.size

func setup_canvas():

	
	canvas_image = parent.canvas_image
	#canvas_image.fill(Color.WHITE)  # Белый фон!
	
	canvas_texture = ImageTexture.create_from_image(canvas_image)
	
	# Устанавливаем текстуру в TextureRect (это важно!)
	$TextureRect.texture = canvas_texture

func _render():
	await get_tree().process_frame
	
	# Получаем изображение из viewport
	var viewport = get_viewport()
	var viewport_texture = viewport.get_texture()
	var viewport_image = viewport_texture.get_image()
	
	# Вырезаем область нашего TextureRect
	var global_rect = $TextureRect.get_global_rect()
	var region = Rect2i(global_rect.position, global_rect.size)
	
	if region.size.x > 0 and region.size.y > 0:
		var new_image = viewport_image.get_region(region)
		
		# Конвертируем в нужный формат если необходимо
		if new_image.get_format() != canvas_image.get_format():
			new_image.convert(canvas_image.get_format())
		
		# Обновляем нашу текстуру
		canvas_image = new_image
		canvas_texture.update(canvas_image)
