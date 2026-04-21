extends RefCounted

const RITUAL_VALUES: Array[int] = [1, 2, 3, 4]
const INCANTATION_VERBS: Array[String] = ["seek", "insight", "burn", "woe", "revive", "renew", "wrath", "deluge", "tears", "flight", "dethrone", "void"]
const INCANTATION_VALUES: Array[int] = [1, 2, 3, 4]
const NOBLE_DEFS := [
	{"id": "krss_power", "name": "Krss, Noble of Power"},
	{"id": "rmrsk_emanation", "name": "Rmrsk, Scion of Emanation"},
	{"id": "smrsk_occultation", "name": "Smrsk, Scion of Occultation"},
	{"id": "tmrsk_annihilation", "name": "Tmrsk, Scion of Annihilation"},
	{"id": "trss_power", "name": "Trss, Noble of Power"},
	{"id": "yrss_power", "name": "Yrss, Noble of Power"},
	{"id": "xytzr_emanation", "name": "Xytzr, Avatar of Emanation"},
	{"id": "yytzr_occultation", "name": "Yytzr, Revenant of Occultation"},
	{"id": "zytzr_annihilation", "name": "Zytzr, Cthonarch of Annihilation"},
	{"id": "aeoiu_rituals", "name": "Aeoiu, Scion of Rituals"},
	{"id": "sndrr_incantation", "name": "Sndrr, Noble of Incantation"},
	{"id": "indrr_incantation", "name": "Indrr, Noble of Incantation"},
	{"id": "bndrr_incantation", "name": "Bndrr, Noble of Incantation"},
	{"id": "wndrr_incantation", "name": "Wndrr, Noble of Incantation"},
	{"id": "rndrr_incantation", "name": "Rndrr, Noble of Incantation"}
]
const TEMPLE_DEFS := [
	{"id": "phaedra_illusion", "name": "Phaedra, Temple of Illusion", "cost": 7},
	{"id": "delpha_oracles", "name": "Delpha, Temple of Oracles", "cost": 7},
	{"id": "gotha_illness", "name": "Gotha, Temple of Illness", "cost": 7},
	{"id": "eyrie_feathers", "name": "Eyrie, Temple of Feathers", "cost": 6},
	{"id": "ytria_cycles", "name": "Ytria, Temple of Cycles", "cost": 9}
]
const BIRD_DEFS := [
	{"id": "wren", "name": "Wren", "cost": 2, "power": 1},
	{"id": "sparrow", "name": "Sparrow", "cost": 2, "power": 1},
	{"id": "finch", "name": "Finch", "cost": 2, "power": 1},
	{"id": "kestrel", "name": "Kestrel", "cost": 3, "power": 2},
	{"id": "shrike", "name": "Shrike", "cost": 3, "power": 2},
	{"id": "gull", "name": "Gull", "cost": 3, "power": 2},
	{"id": "hawk", "name": "Hawk", "cost": 4, "power": 3},
	{"id": "eagle", "name": "Eagle", "cost": 4, "power": 3},
	{"id": "raven", "name": "Raven", "cost": 4, "power": 3}
]
const RING_DEFS := [
	{"id": "sybiline_emanation", "name": "Sybiline, Ring of Emanation"},
	{"id": "cymbil_occultation", "name": "Cymbil, Ring of Occultation"},
	{"id": "celadon_annihilation", "name": "Celadon, Ring of Annihilation"},
	{"id": "serraf_nobles", "name": "Serraf, Ring of Nobles"},
	{"id": "sinofia_feathers", "name": "Sinofia, Ring of Feathers"}
]
const RING_COST := 2


static func incantation_values_for_verb(verb: String) -> Array[int]:
	if verb == "revive":
		return [2]
	if verb == "renew":
		return [3]
	if verb == "wrath":
		return [0]
	if verb == "deluge":
		return [2, 3, 4]
	if verb == "tears":
		return [3]
	if verb == "flight":
		return [3]
	if verb == "dethrone":
		return [4]
	if verb == "woe":
		return [3, 4]
	if verb == "seek":
		return [1, 2]
	if verb == "void":
		return [0]
	return INCANTATION_VALUES


static func build_gallery_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for value in RITUAL_VALUES:
		out.append({"kind": "ritual", "value": value})
	for verb in INCANTATION_VERBS:
		for value in incantation_values_for_verb(verb):
			out.append({"kind": "incantation", "verb": verb, "value": value})
	for noble in NOBLE_DEFS:
		out.append({"kind": "noble", "noble_id": str(noble.get("id", "")), "name": str(noble.get("name", ""))})
	for tm in TEMPLE_DEFS:
		out.append({"kind": "temple", "temple_id": str(tm.get("id", "")), "name": str(tm.get("name", "")), "cost": int(tm.get("cost", 7))})
	for bird in BIRD_DEFS:
		out.append({
			"kind": "bird",
			"bird_id": str(bird.get("id", "")),
			"name": str(bird.get("name", "")),
			"cost": int(bird.get("cost", 0)),
			"power": int(bird.get("power", 0))
		})
	for ring in RING_DEFS:
		out.append({
			"kind": "ring",
			"ring_id": str(ring.get("id", "")),
			"name": str(ring.get("name", "")),
			"cost": RING_COST
		})
	return out


static func entry_key_ritual(value: int) -> String:
	return "r_%d" % value


static func entry_key_incantation(verb: String, value: int) -> String:
	return "i_%s_%d" % [verb, value]


static func entry_key_noble(noble_id: String) -> String:
	return "n_%s" % noble_id


static func entry_key_temple(temple_id: String) -> String:
	return "tm_%s" % temple_id


static func entry_key_bird(bird_id: String) -> String:
	return "b_%s" % bird_id


static func entry_key_ring(ring_id: String) -> String:
	return "rg_%s" % ring_id


static func entry_key(entry: Dictionary) -> String:
	var kind := str(entry.get("kind", ""))
	if kind == "ritual":
		return entry_key_ritual(int(entry.get("value", 0)))
	if kind == "noble":
		return entry_key_noble(str(entry.get("noble_id", "")))
	if kind == "temple":
		return entry_key_temple(str(entry.get("temple_id", "")))
	if kind == "bird":
		return entry_key_bird(str(entry.get("bird_id", "")))
	if kind == "ring":
		return entry_key_ring(str(entry.get("ring_id", "")))
	return entry_key_incantation(str(entry.get("verb", "")), int(entry.get("value", 0)))


static func entry_to_preview_card(entry: Dictionary) -> Dictionary:
	var out := entry.duplicate(true)
	out["type"] = str(entry.get("kind", ""))
	return out


static func non_ritual_gallery_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for e in build_gallery_entries():
		if str(e.get("kind", "")) == "ritual":
			continue
		out.append(e)
	return out
