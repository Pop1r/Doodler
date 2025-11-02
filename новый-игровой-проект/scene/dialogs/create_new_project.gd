extends ConfirmationDialog


@onready var widht_value := %WidthValue
@onready var height_value := %HeightValue
@onready var warning_label := %Warning
# Called when the node enters the scene tree for the first time.
var config_project : Dictionary = {
	'Width':0.0,
	'Height':0.0,
	'Name':'MyAnimation',
	'BackgoundColor':Color.WHITE
}


func _on_confirmed() -> void:
	config_project['Width'] = widht_value.value
	config_project['Height'] = height_value.value
	if %NameLabel.text != '':
		config_project['Name'] = %NameLabel.text
	Global.config_project = config_project
	print(Global.config_project)
	Global.create_new_project()


func _on_canceled() -> void:
	print('Cancel')


func _on_color_picker_button_color_changed(color: Color) -> void:
	config_project['BackgoundColor'] = color


func _on_width_value_value_changed(value: float) -> void:
	config_project['Width'] = value
	proverka()
	


func _on_height_value_value_changed(value: float) -> void:
	config_project['Height'] = value
	proverka()

func proverka():
	var widht = int(config_project['Width'])
	var height = int(config_project['Height'])
	if widht % 2 != 0 or height % 2 != 0:
		warning_label.show()
	elif widht % 2 == 0 and height % 2 == 0:
		warning_label.hide()
	

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			widht_value.value = 1920
			height_value.value = 1080
		1:
			widht_value.value = 1280
			height_value.value = 720
		2:
			widht_value.value = 1080
			height_value.value = 1920
	
