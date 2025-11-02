extends Panel

var is_play_anim : bool =false

@onready var slider := $HSlider

var max_cadr_id : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.fps_updated.connect(func():$Timer.wait_time = 1.0 / float(Global.FPS))
	GlobalAnimationTimeline.play_button_pressed.connect(play_anim)
	GlobalAnimationTimeline.left_frame_updated.connect(func():slider.value = max(0,slider.value - 1))




func set_size_x(value: float):
	size.x = value

func _on_h_slider_value_changed(value: float) -> void:
	GlobalAnimationTimeline.change_amin_slider(int(value))
	GlobalAnimationTimeline.update_scrol_value.emit(slider.value / (slider.max_value + slider.min_value))# -slider.min_value))
func play_anim():
	is_play_anim = !is_play_anim
	if is_play_anim:
		max_cadr_id = GlobalAnimationTimeline.max_id_frame_in_layers()
		$Timer.start()
	else:
		$Timer.stop()

func _on_timer_timeout() -> void:
	if slider.value + 1 > slider.max_value or slider.value + 1 > max_cadr_id:
		if GlobalAnimationTimeline.is_lopped_animation:
			slider.value = slider.min_value
		else:
			GlobalAnimationTimeline.amination_finished.emit()
			$Timer.stop()
			slider.value = slider.min_value
	else:
		slider.value += 1
