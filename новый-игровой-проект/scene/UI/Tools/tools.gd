extends  Panel



@onready var tools_container := %HFlowContainerTools
var tool_item_scene := preload("res://scene/UI/Tools/panel tools/tools_items/panel.tscn")

var tools_items : Array = []

func _ready() -> void:
	for i in range(GlobalTools.tools_texture.size()-1):
		spawn_tools_items()
	
	
func spawn_tools_items():
	var new_tool_item : ToolsItem = tool_item_scene.instantiate()
	
	tools_container.add_child(new_tool_item)
	new_tool_item.set_tool_id(tools_items.size())
	tools_items.append(new_tool_item)


func _on_past_frame_amount_value_changed(value: float) -> void:
	GlobalTools.past_frame_updated.emit(int(value))


func _on_past_frame_enebled_toggled(toggled_on: bool) -> void:
	GlobalTools.past_frame_enebled.emit(toggled_on)


func _on_next_frame_enebled_toggled(toggled_on: bool) -> void:
	GlobalTools.next_frame_enebled.emit(toggled_on)


func _on_next_frame_amount_value_changed(value: float) -> void:
	GlobalTools.next_frame_updated.emit(int(value))
