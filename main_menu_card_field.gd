extends Control

const GalleryCatalog = preload("res://gallery_catalog.gd")

const _FIELD_SCALE := CardPreviewPresenter.PREVIEW_SCALE * 0.618
const _SPEED := 30.0
const _MARGIN := 96.0

var _catalog: Array[Dictionary] = []
var _cells: Dictionary = {}
var _anchor: Vector2 = Vector2.ZERO
var _vel: Vector2 = Vector2.ZERO
var _cell_px: Vector2
var _bg: ColorRect
var _card_layer: Control
var _dim: ColorRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vel = Vector2(1.0, 0.62).normalized() * _SPEED
	_cell_px = CardPreviewPresenter.preview_pixel_size({"card_scale": _FIELD_SCALE})
	_bg = ColorRect.new()
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.color = Color(0.06, 0.045, 0.09, 1.0)
	add_child(_bg)
	move_child(_bg, 0)
	_card_layer = Control.new()
	_card_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_card_layer)
	_dim = ColorRect.new()
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.color = Color(0, 0, 0, 0.618)
	add_child(_dim)
	_build_catalog()
	if _catalog.is_empty():
		return
	set_process(true)


func _build_catalog() -> void:
	_catalog = GalleryCatalog.non_ritual_gallery_entries()


func _preview_card_from_entry(entry: Dictionary) -> Dictionary:
	var cd := GalleryCatalog.entry_to_preview_card(entry)
	if CardTraits.effective_kind(cd) == "incantation" and str(cd.get("verb", "")).to_lower() == "wrath":
		cd["value"] = 4
	return cd


func _pick_entry_excluding(banned: Dictionary) -> Dictionary:
	var cands: Array[Dictionary] = []
	for e in _catalog:
		var k: String = GalleryCatalog.entry_key(e)
		if not banned.has(k):
			cands.append(e)
	if cands.is_empty():
		return _catalog[randi() % _catalog.size()]
	return cands[randi() % cands.size()]


func _sync_grid() -> void:
	var vp := size
	if vp.x < 8.0 or vp.y < 8.0:
		return
	var cw := _cell_px.x
	var ch := _cell_px.y
	if cw < 1.0 or ch < 1.0:
		return
	var bounds := Rect2(-_MARGIN, -_MARGIN, vp.x + 2.0 * _MARGIN, vp.y + 2.0 * _MARGIN)
	var ax := _anchor.x
	var ay := _anchor.y
	var i0 := int(floor((bounds.position.x - ax) / cw)) - 1
	var i1 := int(ceil((bounds.end.x - ax) / cw)) + 1
	var j0 := int(floor((bounds.position.y - ay) / ch)) - 1
	var j1 := int(ceil((bounds.end.y - ay) / ch)) + 1
	var desired: Dictionary = {}
	for i in range(i0, i1 + 1):
		for j in range(j0, j1 + 1):
			var cell_rect := Rect2(ax + float(i) * cw, ay + float(j) * ch, cw, ch)
			if cell_rect.intersects(bounds):
				desired[Vector2i(i, j)] = true
	for ij in _cells.keys():
		if not desired.has(ij):
			var h: Control = _cells[ij].host
			h.queue_free()
			_cells.erase(ij)
	for ij in desired.keys():
		if not _cells.has(ij):
			_spawn_cell(ij)


func _spawn_cell(ij: Vector2i) -> void:
	var banned: Dictionary = {}
	for k in _cells.keys():
		var rec: Dictionary = _cells[k]
		banned[rec.key] = true
	var entry: Dictionary = _pick_entry_excluding(banned)
	var key: String = GalleryCatalog.entry_key(entry)
	var card: Dictionary = _preview_card_from_entry(entry)
	var host := Control.new()
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.custom_minimum_size = _cell_px
	host.size = _cell_px
	host.rotation = 0.0
	_card_layer.add_child(host)
	var prev: Dictionary = CardPreviewPresenter.build_preview_panel(self, {
		"parent_slot": host,
		"mode": "slot",
		"ui_scale": _FIELD_SCALE,
		"card_scale": _FIELD_SCALE,
		"name": "MenuBgCard",
		"z_index": 0,
	})
	CardPreviewPresenter.show_preview(prev, card)
	var root: Control = prev.get("root") as Control
	if root != null:
		root.modulate = Color(1, 1, 1, 0.86)
	_cells[ij] = {"host": host, "key": key}


func _process(delta: float) -> void:
	if _catalog.is_empty():
		return
	if size.x < 8.0 or size.y < 8.0:
		return
	_anchor += _vel * delta
	_sync_grid()
	var cw := _cell_px.x
	var ch := _cell_px.y
	var ax := _anchor.x
	var ay := _anchor.y
	for ij in _cells.keys():
		var host: Control = _cells[ij].host
		host.position = Vector2(ax + float(ij.x) * cw, ay + float(ij.y) * ch)
