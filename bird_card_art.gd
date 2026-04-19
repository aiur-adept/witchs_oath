extends RefCounted
class_name BirdCardArt


static func art_for(card: Dictionary) -> String:
	var cost := clampi(int(card.get("cost", 2)), 2, 4)
	var bid := str(card.get("bird_id", "")).to_lower()
	var b := _body_glyph(bid)
	var h := _head_glyph(bid)
	match cost:
		2:
			return _tier2(b, h)
		3:
			return _tier3(b, h)
		_:
			return _tier4(b, h)


static func bird_width_for_cost(cost: int) -> int:
	match clampi(cost, 2, 4):
		2:
			return 5
		3:
			return 11
		_:
			return 17


static func _body_glyph(bid: String) -> String:
	match bid:
		"eagle", "hawk":
			return "◉"
		"raven":
			return "●"
		"gull", "kestrel":
			return "○"
		"shrike":
			return "◆"
		"wren", "finch":
			return "·"
		_:
			return "●"


static func _head_glyph(bid: String) -> String:
	match bid:
		"eagle":
			return "▼"
		"gull":
			return "△"
		_:
			return "▲"


static func _pad_center(s: String, width: int) -> String:
	if s.length() >= width:
		return s.substr(0, width)
	var pad := width - s.length()
	var left: int = pad >> 1
	return " ".repeat(left) + s + " ".repeat(pad - left)


static func _row_body_open(w: int, g: String) -> String:
	var ch := g.substr(0, 1)
	var mid: int = w - 2
	var ls: int = (mid - 1) >> 1
	var rs: int = mid - 1 - ls
	return "╱" + " ".repeat(ls) + ch + " ".repeat(rs) + "╲"


static func _row_spine_open(w: int) -> String:
	return _row_body_open(w, "│")


static func _row_wing_closed(w: int) -> String:
	var mid: int = w - 2
	return "╱" + "─".repeat(mid) + "╲"


static func _row_tail(w: int) -> String:
	var inner := w - 2
	return _pad_center("╲" + "═".repeat(maxi(1, inner - 2)) + "╱", w)


static func _tier2(body: String, head: String) -> String:
	var g := body.substr(0, 1)
	var hd := head.substr(0, 1)
	const W := 5
	var lines: PackedStringArray = []
	lines.append(_pad_center(hd, W))
	lines.append(_pad_center("╱·╲", W))
	lines.append(_pad_center("│" + g + "│", W))
	lines.append(_row_wing_closed(W))
	return "\n".join(lines)


static func _tier3(body: String, head: String) -> String:
	var g := body.substr(0, 1)
	var hd := head.substr(0, 1)
	const W := 11
	var lines: PackedStringArray = []
	lines.append(_pad_center(hd, W))
	lines.append(_pad_center("╱ · · ╲", W))
	lines.append(_pad_center("╱  · ·  ╲", W))
	lines.append(_row_body_open(W, g))
	lines.append(_row_spine_open(W))
	lines.append(_row_wing_closed(W))
	lines.append(_row_tail(W))
	return "\n".join(lines)


static func _tier4(body: String, head: String) -> String:
	var g := body.substr(0, 1)
	var hd := head.substr(0, 1)
	const W := 17
	var lines: PackedStringArray = []
	lines.append(_pad_center(hd, W))
	lines.append(_pad_center("╱ · · · ╲", W))
	lines.append(_pad_center("╱  · · ·  ╲", W))
	lines.append(_row_body_open(W, g))
	lines.append(_row_spine_open(W))
	lines.append(_row_spine_open(W))
	lines.append(_row_wing_closed(W))
	lines.append(_row_tail(W))
	return "\n".join(lines)
