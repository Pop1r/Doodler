extends Panel


class_name ToolsItem


@onready var texture_rect = $TextureRect

var id_tools : int = 0




func set_tool_id(id : int):
	id_tools = id
	texture_rect.texture = GlobalTools.get_tool_texture(id_tools)
	
	


func _on_button_pressed() -> void:
	GlobalTools.change_current_tools(id_tools)
