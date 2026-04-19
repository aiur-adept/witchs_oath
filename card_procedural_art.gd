extends RefCounted
class_name CardProceduralArt

static var _generators: Dictionary = {}
static var _bootstrapped: bool = false
static var _noble_art: Dictionary = {}
static var _noble_art_loaded: bool = false
static var _temple_art: Dictionary = {}
static var _temple_art_loaded: bool = false
static var _ring_art: Dictionary = {}
static var _ring_art_loaded: bool = false


static func register_generator(key: String, fn: Callable) -> void:
	_generators[key] = fn


static func art_seed(card: Dictionary) -> int:
	if card.has("art_seed"):
		return int(card.art_seed)
	if card.has("mid"):
		return int(card.mid)
	var verb := str(card.get("verb", ""))
	var noble_id := str(card.get("noble_id", ""))
	return hash(verb + ":" + str(int(card.get("value", 0))) + ":" + noble_id)


static func resolve_key(card: Dictionary) -> String:
	var ak := str(card.get("art_key", "")).strip_edges()
	if not ak.is_empty():
		return ak
	var kind := CardTraits.effective_kind(card)
	match kind:
		"incantation":
			return "incantation:" + str(card.get("verb", "")).to_lower().strip_edges()
		"noble":
			return "noble:" + str(card.get("noble_id", "")).strip_edges()
		"temple":
			return "temple:" + str(card.get("temple_id", "")).strip_edges()
		"bird":
			return "bird:" + str(card.get("bird_id", "")).strip_edges()
		"ring":
			return "ring:" + str(card.get("ring_id", "")).strip_edges()
		_:
			return ""


static func generate_text(card: Dictionary, ctx: Dictionary = {}) -> String:
	var key := resolve_key(card)
	if key.is_empty():
		return ""
	if key.begins_with("noble:"):
		_load_noble_art()
		var nid := key.substr(6)
		if _noble_art.has(nid):
			return str(_noble_art[nid])
	if key.begins_with("temple:"):
		_load_temple_art()
		var tid := key.substr(7)
		if _temple_art.has(tid):
			return str(_temple_art[tid])
	if key.begins_with("bird:"):
		return BirdCardArt.art_for(card)
	_bootstrap()
	var fn: Variant = _generators.get(key, null)
	if fn == null or not (fn is Callable):
		return ""
	var c := fn as Callable
	if not c.is_valid():
		return ""
	var ui := float(ctx.get("ui_scale", 1.0))
	var sd := art_seed(card)
	return c.call(card, {"ui_scale": ui, "seed": sd})


static func ring_glyphs_for(card: Dictionary) -> Array:
	_load_ring_art()
	var rid := str(card.get("ring_id", "")).strip_edges()
	if rid.is_empty() or not _ring_art.has(rid):
		return []
	var v: Variant = _ring_art[rid]
	if v is Array:
		var out: Array = []
		for x in v:
			out.append(str(x))
		return out
	if v is String:
		var s := str(v)
		var a: Array = []
		for ch in s:
			a.append(ch)
		return a
	return []


static func _load_noble_art() -> void:
	if _noble_art_loaded:
		return
	_noble_art_loaded = true
	var path := "res://data/noble_card_art.json"
	if not FileAccess.file_exists(path):
		return
	var raw := FileAccess.get_file_as_string(path)
	var json := JSON.new()
	if json.parse(raw) != OK:
		push_warning("CardProceduralArt: failed to parse noble_card_art.json")
		return
	var d: Variant = json.data
	if typeof(d) != TYPE_DICTIONARY:
		return
	_noble_art = d


static func _load_temple_art() -> void:
	if _temple_art_loaded:
		return
	_temple_art_loaded = true
	var path := "res://data/temple_card_art.json"
	if not FileAccess.file_exists(path):
		return
	var raw := FileAccess.get_file_as_string(path)
	var json := JSON.new()
	if json.parse(raw) != OK:
		push_warning("CardProceduralArt: failed to parse temple_card_art.json")
		return
	var d: Variant = json.data
	if typeof(d) != TYPE_DICTIONARY:
		return
	_temple_art = d


static func _load_ring_art() -> void:
	if _ring_art_loaded:
		return
	_ring_art_loaded = true
	var path := "res://data/ring_card_art.json"
	if not FileAccess.file_exists(path):
		return
	var raw := FileAccess.get_file_as_string(path)
	var json := JSON.new()
	if json.parse(raw) != OK:
		push_warning("CardProceduralArt: failed to parse ring_card_art.json")
		return
	var d: Variant = json.data
	if typeof(d) != TYPE_DICTIONARY:
		return
	_ring_art = d


static func _bootstrap() -> void:
	if _bootstrapped:
		return
	_bootstrapped = true
	load("res://incantation_procedural_art.gd")
	IncantationProceduralArt.register_generators()
