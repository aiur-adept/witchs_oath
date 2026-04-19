"""Pilot for the Wrathseek-Sac control deck.

The deck runs **no 4-rituals**, so every Wrath 4 must be paid by ritual
sacrifice. The base ``_score_incantation`` already constructs a minimal
sac combination for the needed value, and since the deck is a 3R glut
this naturally biases toward using a single 3-ritual per Wrath. We
additionally bias revive targeting toward Wrath so the removal loop
recurs, and require an early 3R in the mulligan."""

from __future__ import annotations

from typing import Optional

from ..ai import GreedyAI
from ..cards import Kind, VERB_WRATH
from ..match import MatchState


class WrathseekSacPilot(GreedyAI):
    W_REVIVE_PRIO_WRATH: float = 10.0
    W_REVIVE_PRIO_WOE: float = 5.0
    W_REVIVE_PRIO_SEEK: float = 3.0
    W_REVIVE_PRIO_INSIGHT: float = 2.0
    W_REVIVE_PRIO_BURN: float = 1.0
    SAC_PENALTY_PER_RITUAL = 1.0  # sacing is the plan; don't over-penalize

    def mulligan(self, state: MatchState, pid: int) -> bool:
        hand = state.players[pid].hand
        if not hand:
            return False
        rituals = [c for c in hand if c.kind is Kind.RITUAL]
        if len(rituals) == 0 or len(rituals) == len(hand):
            return True
        vals = {c.value for c in rituals}
        if 1 not in vals:
            return True
        if 3 not in vals and len(hand) <= 5:
            return True
        return False

    def adjust_incantation_score(self, state: MatchState, pid: int, card, sac, score: float) -> Optional[float]:
        if card.verb == VERB_WRATH:
            return score + 12.0
        return score

    def wrath_score_adjust(self, state: MatchState, pid: int, base: float) -> float:
        return base + 6.0
