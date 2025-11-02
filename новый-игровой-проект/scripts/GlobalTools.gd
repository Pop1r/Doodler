extends Node

signal update_current_tools(new_tools : TOOLS)
signal past_frame_updated(value: int)
signal past_frame_enebled(value:bool)
signal next_frame_updated(value: int)
signal next_frame_enebled(value:bool)


enum TOOLS {PEN, ERASER }

var current_tools : TOOLS = TOOLS.PEN


var tools_texture : Dictionary = {
	'pen': preload("res://assets/tools_items/free-icon-pen-1659682.png"),
	'eraser':preload("res://assets/tools_items/free-icon-eraser-637291.png"),
	'arm':preload("res://assets/tools_items/free-icon-stop-658022.png")
}

var onion_skin : Dictionary = {
	'is_past_frame':true,
	'amount_past_frame':5,
	'is_next_frame':true,
	'amount_next_frame':5
}


func change_current_tools(new_tools: TOOLS):
	current_tools = new_tools
	update_current_tools.emit(current_tools)
	print(current_tools)

func get_tool_texture(id:int):
	var keys : Array = tools_texture.keys()
	return tools_texture[keys[id]]
