extends RefCounted
class_name CardTraits


static func effective_kind(card: Dictionary) -> String:
	var raw := str(card.get("type", card.get("kind", ""))).strip_edges().to_lower()
	if not raw.is_empty():
		if raw == "bird":
			return "bird"
		if raw == "incantation" or raw == "dethrone":
			return "incantation"
		if raw == "ritual":
			return "ritual"
		if raw == "noble":
			return "noble"
		if raw == "temple":
			return "temple"
		if raw == "ring":
			return "ring"
		return raw
	if card.has("temple_id"):
		return "temple"
	if card.has("noble_id"):
		return "noble"
	if card.has("bird_id"):
		return "bird"
	if card.has("ring_id"):
		return "ring"
	if not str(card.get("verb", "")).strip_edges().is_empty():
		return "incantation"
	if card.has("mid") and card.has("value"):
		return "ritual"
	return ""


static func is_dethrone(card: Dictionary) -> bool:
	if effective_kind(card) != "incantation":
		return false
	if str(card.get("verb", "")).strip_edges().to_lower() == "dethrone":
		return true
	return str(card.get("type", card.get("kind", ""))).strip_edges().to_lower() == "dethrone"
