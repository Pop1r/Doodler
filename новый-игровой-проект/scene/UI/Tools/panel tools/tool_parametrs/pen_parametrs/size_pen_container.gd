extends VBoxContainer


func _on_brush_size_scroll_value_changed(value: float) -> void:
	GlobalAnimationTimeline.brush_size.emit(value)


func _on_check_box_toggled(toggled_on: bool) -> void:
	Global.pressure = toggled_on
