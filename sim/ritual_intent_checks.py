from __future__ import annotations

import random
from pathlib import Path

from sim.ai import GreedyAI
from sim.cards import make_dethrone, make_ritual
from sim.match import MatchState, Noble


def _fresh_state() -> MatchState:
    return MatchState(([], []), random.Random(0))


def _check_sim_progression_prefers_low_lane() -> None:
    state = _fresh_state()
    ai = GreedyAI(0)
    me = state.players[0]
    me.hand = [make_ritual(1), make_ritual(2), make_ritual(4)]
    s1 = ai.score_ritual_play(state, me.hand[0])
    s2 = ai.score_ritual_play(state, me.hand[1])
    s4 = ai.score_ritual_play(state, me.hand[2])
    assert s1 > s2 > s4, (s1, s2, s4)


def _check_sim_can_value_offcurve_for_live_dethrone() -> None:
    state = _fresh_state()
    ai = GreedyAI(0)
    me = state.players[0]
    me.hand = [make_ritual(1), make_ritual(4), make_dethrone()]
    no_target_score = ai.score_ritual_play(state, me.hand[1])
    state.players[1].noble_field = [Noble(mid=99, noble_id="xytzr_emanation", cost=6)]
    live_target_score = ai.score_ritual_play(state, me.hand[1])
    assert live_target_score > no_target_score, (no_target_score, live_target_score)


def _check_cpu_mirror_hooks_present() -> None:
    cpu_path = Path(__file__).resolve().parents[1] / "cpu" / "cpu_base.gd"
    text = cpu_path.read_text(encoding="utf-8")
    required = [
        "RITUAL_PLAY_NEXT_LANE_BONUS",
        "RITUAL_PLAY_OFFCURVE_PENALTY",
        "RITUAL_PLAY_SAC_SETUP_ENABLE",
        "func _ritual_progression_bonus",
        "func _ritual_offcurve_penalty",
        "func _ritual_sacrifice_setup_bonus",
    ]
    missing = [name for name in required if name not in text]
    assert not missing, missing


def main() -> None:
    _check_sim_progression_prefers_low_lane()
    _check_sim_can_value_offcurve_for_live_dethrone()
    _check_cpu_mirror_hooks_present()
    print("ritual_intent_checks: ok")


if __name__ == "__main__":
    main()
