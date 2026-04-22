extends RefCounted
class_name IncantationProceduralArt


static func register_generators() -> void:
	CardProceduralArt.register_generator("incantation:dethrone", _gen_dethrone)
	CardProceduralArt.register_generator("incantation:seek", _gen_seek)
	CardProceduralArt.register_generator("incantation:insight", _gen_insight)
	CardProceduralArt.register_generator("incantation:burn", _gen_burn)
	CardProceduralArt.register_generator("incantation:woe", _gen_woe)
	CardProceduralArt.register_generator("incantation:revive", _gen_revive)
	CardProceduralArt.register_generator("incantation:renew", _gen_renew)
	CardProceduralArt.register_generator("incantation:wrath", _gen_wrath)
	CardProceduralArt.register_generator("incantation:deluge", _gen_deluge)
	CardProceduralArt.register_generator("incantation:tears", _gen_tears)
	CardProceduralArt.register_generator("incantation:flight", _gen_flight)
	CardProceduralArt.register_generator("incantation:void", _gen_void)


static func _n(card: Dictionary, lo: int, hi: int, fallback: int) -> int:
	return clampi(int(card.get("value", fallback)), lo, hi)


static func _rep_unit(s: String, count: int, sep: String) -> String:
	if count <= 0:
		return ""
	var out := s
	for i in range(1, count):
		out += sep + s
	return out


static func _gen_dethrone(card: Dictionary, _ctx: Dictionary) -> String:
	var k := _n(card, 1, 4, 4)
	var crown := "♕" if (k % 2) == 0 else "♔"
	var tier := _rep_unit("─", k + 2, "┬")
	var base := _rep_unit("╧", k + 3, "═")
	return "   %s   \n ╭%s╮ \n │ ▲ │ \n╭┴───┴╮\n│░ ▼ ░│\n╰%s╯" % [crown, tier, base]


static func _gen_seek(card: Dictionary, _ctx: Dictionary) -> String:
	var n := _n(card, 1, 4, 1)
	var a := "↓"
	var deck := ""
	for _i in n:
		deck += "▣"
	var scouts := _rep_unit("◎", n, " ")
	var flow := _rep_unit(a, n, " ")
	var drops := _rep_unit("▼", n, " ")
	return " %s \n  ╱ ╲  \n ╱   ╲ \n╭─────╮\n│%s│\n╰──┬──╯\n %s\n %s" % [scouts, deck, flow, drops]


static func _gen_insight(card: Dictionary, _ctx: Dictionary) -> String:
	var n := _n(card, 1, 4, 1)
	var e := "◉"
	var bar := _rep_unit(e, n, "┊")
	var w := bar.length()
	var top := " ╭" + "─".repeat(w) + "╮ "
	var eyes := " ╭┤" + bar + "├╮ "
	var neck := " │╰┬╯│ "
	var span := maxi(w, n * n)
	var strata := ""
	for i in n:
		strata += "│" + "⋯".repeat((i + 1) * n) + "│\n"
	var box_top := "╭" + "─".repeat(span) + "╮"
	var box_bot := "╰" + "═".repeat(span) + "╯"
	return top + "\n" + eyes + "\n" + neck + "\n" + box_top + "\n" + strata + box_bot


static func _gen_burn(card: Dictionary, _ctx: Dictionary) -> String:
	var n := _n(card, 1, 4, 1)
	var m := 2 * n
	var w := lattice_width(m)
	var crown := _rep_unit("▲", m, "").rpad(w, " ")
	var lattice := "╱╲".repeat(m).rpad(w, " ")
	var fire := _rep_unit("※", m, "").rpad(w - 2, " ")
	var grate := _rep_unit("┬", m, "").rpad(w - 2, "─")
	var fall := _rep_unit("▼", m, "").rpad(w, " ")
	var rule := "─".repeat(w - 2)
	return "  %s  \n%s\n╭%s╮\n│%s│\n╰%s╯\n%s" % [crown, lattice, rule, fire, grate, fall]


static func lattice_width(m: int) -> int:
	return "╱╲".repeat(m).length()


static func _gen_woe(card: Dictionary, _ctx: Dictionary) -> String:
	var n := _n(card, 1, 4, 1)
	var grit := _rep_unit("▒", n + 5, "")
	var drip := _rep_unit("▼", n-2, " ")
	return " ╭─────╮ \n╭┤ ├╮\n│╰─╥─╯│\n│  ╨    │\n╰══╧════╯\n%s\n%s" % [grit, drip]


static func _gen_revive(card: Dictionary, _ctx: Dictionary) -> String:
	var n := _n(card, 1, 4, 1)
	var sp := "↺"
	var orbit := _rep_unit(sp, n, "")
	var climb := _rep_unit("↑", n, "·")
	var seeds := _rep_unit("◇", n, " ")
	return "  %s  \n  ╭───╮  \n ╭┤ ↑ ├╮ \n │%s│ \n╭┴──┴──┴╮\n│░░ ◇ ░░│\n╰═══════╯\n %s" % [orbit, climb, seeds]


static func _gen_renew(card: Dictionary, _ctx: Dictionary) -> String:
	var n := _n(card, 1, 4, 2)
	var pillars := _rep_unit("█", n, " ")
	return "  ╭─────╮ \n ╭┤ ▲ ├╮\n │%s│\n╭┴──┴──┴╮\n│ ▣→◇ │\n╰═══════╯" % pillars


static func _gen_wrath(card: Dictionary, _ctx: Dictionary) -> String:
	var raw := int(card.get("value", 0))
	var n := clampi(raw, 0, 4)
	if n <= 0:
		n = 1
	var strike := _rep_unit("/|", n, "")
	var veins := _rep_unit("╱╲", mini(n + 1, 6), "")
	var shards := _rep_unit("▼", n + 3, "")
	return "   %s   \n  %s  \n ╱══════╲ \n╭────────╮\n│▓▓▓▓▓▓▓▓│\n╰╥╥╥╥╥╥╥╥╯\n %s" % [strike, veins, shards]


static func _gen_deluge(card: Dictionary, _ctx: Dictionary) -> String:
	var n := _n(card, 2, 4, 2)
	var slant := "╱" if (n % 2) == 0 else "╲"
	var curtain := ""
	for _i in n:
		curtain += slant + "│"
	var rain := _rep_unit("▼", n * 2, "")
	var puddle := _rep_unit("▽", n, " ")
	var surf := "∼".repeat(n * 2)
	return "%s\n %s \n─────────\n %s \n%s\n %s" % [curtain, rain, _rep_unit("▼", n, " "), surf, puddle]


static func _gen_tears(card: Dictionary, _ctx: Dictionary) -> String:
	var n := _n(card, 1, 4, 3)
	var path := _rep_unit("◇", n, " ")
	var pool := _rep_unit("∿", n, "")
	var fall := _rep_unit("▽", n, " ")
	return "   ∴   \n  ╱ ♦ ╲  \n ╱%s╲ \n╭───────╮\n│░%s░│\n╰───┬───╯\n %s" % [path, pool, fall]


static func _gen_flight(card: Dictionary, _ctx: Dictionary) -> String:
	var n := _n(card, 1, 4, 3)
	var top := _rep_unit("∿", n + 1, "")
	var mid := _rep_unit("∿", n + 3, "")
	var bot := _rep_unit("∿", n + 1, "")
	return "    ◇    \n   ╱ ∿ ╲   \n  ╱%s╲  \n │░%s░│ \n  ╲%s╱  \n   ╲┬╱   \n    │    " % [top, mid, bot]


static func _gen_void(_card: Dictionary, _ctx: Dictionary) -> String:
	return " ╭───────╮ \n │       │ \n │   ○   │ \n │       │ \n │  · ·  │ \n ╰───────╯ \n  ░ ░ ░ ░  "
