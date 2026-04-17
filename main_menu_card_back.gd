extends Control

const CornerPipDraw = preload("res://corner_pip_draw.gd")

const COLOR_GOLD := Color("#e8c547")
const COLOR_TEAL := Color("#3ec4b0")
const COLOR_PURPLE := Color("#b565d8")
const CARD_WH := Vector2(2.5, 3.5)
const CARD_MIN_W := 110.0

var _panel: StyleBoxFlat


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	custom_minimum_size = Vector2(CARD_MIN_W, CARD_MIN_W * CARD_WH.y / CARD_WH.x)
	_panel = StyleBoxFlat.new()
	_panel.bg_color = Color(0.04, 0.04, 0.062)
	_panel.set_corner_radius_all(5)
	_panel.set_border_width_all(2)
	_panel.border_color = Color(0.22, 0.22, 0.3)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_style_box(_panel, r)
	var w := size.x
	var h := size.y
	if w < 8.0 or h < 8.0:
		return
	var cx := w * 0.5
	var cy := h * 0.5
	var tri_r := minf(w, h) * 0.28
	var dot_r := clampi(int(round(minf(w, h) * 0.135)), 10, 26)
	var cols: Array[Color] = [
		Color(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b, 0.98),
		Color(COLOR_TEAL.r, COLOR_TEAL.g, COLOR_TEAL.b, 0.98),
		Color(COLOR_PURPLE.r, COLOR_PURPLE.g, COLOR_PURPLE.b, 0.98),
	]
	for i in 3:
		var ang := -PI / 2.0 + float(i) * TAU / 3.0
		var pc := Vector2(cx + cos(ang) * tri_r, cy + sin(ang) * tri_r)
		CornerPipDraw.draw_dot_on_canvas(self, pc, dot_r, false, cols[i])
