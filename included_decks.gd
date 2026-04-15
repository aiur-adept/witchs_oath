extends Object

const BUNDLE_PATH := "res://included_decks.json"
const TOKEN_PREFIX := "included:"


static func _normalize_slug(file_name: String) -> String:
	var fn := file_name.strip_edges()
	if fn.to_lower().ends_with(".json"):
		return fn.substr(0, fn.length() - 5)
	return fn


static func is_token(path: String) -> bool:
	return path.begins_with(TOKEN_PREFIX)


static func token(slug: String) -> String:
	return TOKEN_PREFIX + slug


static func slug_from_token(path: String) -> String:
	if not is_token(path):
		return ""
	return path.substr(TOKEN_PREFIX.length())


static func load_bundle() -> Dictionary:
	if not FileAccess.file_exists(BUNDLE_PATH):
		return {}
	var f := FileAccess.open(BUNDLE_PATH, FileAccess.READ)
	if f == null:
		return {}
	var p: Variant = JSON.parse_string(f.get_as_text())
	if typeof(p) != TYPE_DICTIONARY:
		return {}
	return p as Dictionary


static func slug_list() -> Array[String]:
	var out: Array[String] = []
	for e in load_bundle().get("decks", []):
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var slug := _normalize_slug(str(e.get("file_name", "")))
		if not slug.is_empty():
			out.append(slug)
	return out


static func payload_for_slug(slug: String) -> Dictionary:
	for e in load_bundle().get("decks", []):
		if typeof(e) != TYPE_DICTIONARY:
			continue
		if _normalize_slug(str(e.get("file_name", ""))) != slug:
			continue
		var payload: Variant = e.get("payload", {})
		return (payload as Dictionary) if typeof(payload) == TYPE_DICTIONARY else {}
	return {}


static func list_row_text(path: String) -> String:
	if is_token(path):
		return "[Included] %s" % slug_from_token(path)
	return path.get_file().get_basename()


static func default_play_path() -> String:
	if not payload_for_slug("default_deck").is_empty():
		return token("default_deck")
	return "user://decks/default_deck.json"
