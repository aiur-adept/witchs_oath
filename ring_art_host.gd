extends Control
class_name RingArtHost


var _glyphs: Array = []
var _art_font: Font
var _font_size: int
var _font_color: Color = Color.WHITE


func set_ring(glyphs: Array, font: Font, font_size: int, color: Color) -> void:
	_glyphs = glyphs.duplicate()
	_art_font = font
	_font_size = font_size
	_font_color = color
	for c in get_children():
		c.queue_free()
	if _glyphs.is_empty():
		return
	call_deferred("_rebuild_after_layout")


func _rebuild_after_layout() -> void:
	await get_tree().process_frame
	_rebuild()


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	if _glyphs.is_empty() or _art_font == null:
		return
	var w := size.x
	var h := size.y
	if w < 2.0 or h < 2.0:
		return
	var n: int = _glyphs.size()
	var cx := w * 0.5
	var cy := h * 0.5
	var rr: float = float(mini(w, h)) * 0.36
	var n_f := float(n)
	var i := 0
	while i < n:
		var ang := TAU * (float(i) / n_f) - PI * 0.5
		var lbl := Label.new()
		lbl.text = str(_glyphs[i])
		lbl.add_theme_font_override("font", _art_font)
		lbl.add_theme_font_size_override("font_size", _font_size)
		lbl.add_theme_color_override("font_color", _font_color)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(lbl)
		lbl.reset_size()
		var lw := lbl.size.x
		var lh := lbl.size.y
		lbl.position = Vector2(cx + cos(ang) * rr - lw * 0.5, cy + sin(ang) * rr - lh * 0.5)
		i += 1
