extends Control


func _ready() -> void:

	Global.new_project_created.connect(func():get_tree().change_scene_to_file('res://scene/menu/menu.tscn'))
	get_window().focus_exited.connect(func ():get_window().grab_focus())

func  _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		if not get_window().has_focus():
			get_window().grab_focus()
