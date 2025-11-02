extends Control


# Called when the node enters the scene tree for the first time.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_accept'):
		swap_children_by_index(0,1)

func swap_children_by_index(index1: int, index2: int):
	var children = $VBoxContainer.get_children()
	if index1 > children.size() and index2 > children.size():return
	var child1 = children[index1]
	var child2 = children[index2]
	
	var pos1 = child1.position
	var pos2 = child2.position
	$VBoxContainer.move_child(child1,index2)
	$VBoxContainer.move_child(child2,index1)
