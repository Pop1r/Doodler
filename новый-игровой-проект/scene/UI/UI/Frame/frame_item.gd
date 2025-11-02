extends Panel


const COLORS := {
	'not_vis' : Color('1c1c1c'),
	'vis': Color('82d2ac')
}

var is_cadr : bool = false
var frame_id : int = 0
var layer_id : int = 0
@onready var parrent : AnimPanel 
@onready var color_rect = $ColorRect


var image : Image 
func _ready() -> void:
	parrent = get_parent().get_parent()
func set_frame_info(f_id,l_id):
	frame_id = f_id
	layer_id = l_id
	$Label.text = str(frame_id)


func _on_button_pressed() -> void:
	if is_cadr:
		parrent.update_current_frame.emit(frame_id)
		print('CUUUUUUUUUUREREEENT')
		#GlobalAnimationTimeline.update_current_cadr(layer_id,frame_id)
		return
	set_vis()

func remove():
	is_cadr = !is_cadr
	color_rect.color = COLORS['not_vis']
	

func vis():
	is_cadr = true
	
	color_rect.color  = COLORS['vis']

func set_vis():
	is_cadr = !is_cadr
	
	color_rect.color  = COLORS['vis']
	parrent.add_frame.emit(frame_id)
	
	#GlobalAnimationTimeline.add_frame(layer_id,frame_id)
func set_load():
	is_cadr = !is_cadr
	
	color_rect.color  = COLORS['vis']
