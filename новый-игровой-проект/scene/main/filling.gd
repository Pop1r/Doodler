extends Node

func flood_fill(image: Image, start_pos: Vector2i, new_color:Color):
	var width = image.get_width()
	var height = image.get_height()
	
	var target_color = image.get_pixelv(start_pos)
	
	if target_color == new_color: return
	
	var queue: Array[Vector2i] = []
	queue.append(start_pos)
	
	while queue.size() > 0:
		var pos = queue.pop_back()
		
		if (pos.x < 0 or pos.x>= width or
			pos.y < 0 or pos.y >= height):continue
		
		if image.get_pixelv(pos) != target_color:continue
		
		image.set_pixelv(pos,new_color)
		queue.append(Vector2i(pos.x + 1, pos.y))
		queue.append(Vector2i(pos.x - 1, pos.y))
		queue.append(Vector2i(pos.x, pos.y + 1))
		queue.append(Vector2i(pos.x, pos.y - 1))
