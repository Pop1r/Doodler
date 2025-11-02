extends ScrollContainer

var is_scrol : bool = false
var max_value : int = 0
# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	GlobalAnimationTimeline.update_scrol_value.connect(update)
	await get_tree().create_timer(4).timeout
	print(get_max_horizontal_scroll())
	is_scrol = true

func update(value: float):
	scroll_horizontal = max_value * value

func get_max_horizontal_scroll() -> float:
	var h_scrollbar = get_h_scroll_bar()
	if h_scrollbar:
		max_value = h_scrollbar.max_value
		return h_scrollbar.max_value
	return 0.0
