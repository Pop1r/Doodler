extends GridContainer

@export var min_item_width: float = 100.0
@export var max_columns: int = 8

func _ready():
	# Настройки для корректного сжатия
	mouse_filter = Control.MOUSE_FILTER_PASS
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Настройка дочерних элементов
	for child in get_children():
		if child is Control:
			child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			child.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			child.custom_minimum_size = Vector2(min_item_width, 0)
	
	resized.connect(_on_resized)
	_update_columns()

func _on_resized():
	_update_columns()
	# Принудительное обновление layout
	get_parent().queue_sort()
	queue_sort()

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		_update_columns()

func _update_columns():
	var available_width = size.x
	if available_width <= 0:
		return
	
	var calculated_columns = max(1, floor(available_width / min_item_width))
	calculated_columns = min(calculated_columns, max_columns)
	
	if columns != calculated_columns:
		columns = calculated_columns
		# Принудительное обновление
		queue_redraw()
