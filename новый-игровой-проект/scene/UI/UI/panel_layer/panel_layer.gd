extends PanelContainer

class_name ItemLayer

var icons_eye : Dictionary = {
	'open': preload("res://assets/ui_icons/layers/eye.svg"),
	'close' : preload("res://assets/ui_icons/layers/eye-off.svg")
}

var is_visible_layer : bool = true

var layer_id : int = 0

@onready var eye_button := $HBoxContainer/Panel/eye_button
@onready var current_layer_button := $HBoxContainer/current_layer_button
@onready var name_layer := $HBoxContainer/Label


func _ready() -> void:
	name_layer.text = 'Layer: '+ str(layer_id)
	GlobalCanvas.update_current_layer.connect(_update_current_layer)
	
	if GlobalCanvas.current_layer == layer_id:
		current_layer_button.button_pressed = true
	
func _update_current_layer(id: int):
	if id == layer_id:return
	current_layer_button.button_pressed = false
	
func _on_texture_button_pressed() -> void:
	is_visible_layer = !is_visible_layer
	if is_visible_layer:
		eye_button.texture_normal = icons_eye['open']
		modulate.a = 1
	else:
		eye_button.texture_normal = icons_eye['close']
		modulate.a = 0.5
	GlobalCanvas.set_visible_layer.emit(layer_id, is_visible_layer)
		
func _on_current_layer_button_pressed() -> void:
	if not current_layer_button.button_pressed:
		current_layer_button.button_pressed = true 
		return
	GlobalCanvas.set_current_layer(layer_id)


func _on_eye_button_pressed() -> void:
	_on_texture_button_pressed()
