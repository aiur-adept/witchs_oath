extends RefCounted


static func draw_dot_on_canvas(item: CanvasItem, center: Vector2, radius: int, filled: bool, color: Color) -> void:
	var cx := int(round(center.x))
	var cy := int(round(center.y))
	var r2: int = radius * radius
	var inner: int = maxi(0, radius - 1)
	var inner2: int = inner * inner
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var d2 := dx * dx + dy * dy
			if d2 > r2:
				continue
			if not filled and d2 < inner2:
				continue
			item.draw_rect(Rect2(float(cx + dx), float(cy + dy), 1.0, 1.0), color)


static func draw_dot_on_image(image: Image, center: Vector2i, radius: int, filled: bool, color: Color = Color(1, 1, 1, 0.98)) -> void:
	var r2: int = radius * radius
	var inner: int = maxi(0, radius - 1)
	var inner2: int = inner * inner
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var d2 := dx * dx + dy * dy
			if d2 > r2:
				continue
			if not filled and d2 < inner2:
				continue
			var px := center.x + dx
			var py := center.y + dy
			if px < 0 or py < 0 or px >= image.get_width() or py >= image.get_height():
				continue
			image.set_pixel(px, py, color)
