extends Panel


@onready var color_picker : ColorPicker = %ColorPicker


func _on_resized() -> void:
	if not color_picker:return
	var new_size := size.x - color_picker.get_theme_constant('h_width')
	color_picker.add_theme_constant_override("sv_width", new_size)
	print(size.x)


func _on_color_picker_color_changed(color: Color) -> void:
	GlobalAnimationTimeline.color_change.emit(color)
