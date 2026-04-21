"""Pilot for the Ritual Reanimator (Aeoiu + Burn + Phaedra) deck.

Self-mill with Burns to stack rituals in crypt; **Aeoiu** and **Revive→Renew**
lines replay the largest rituals. Revive prioritizes **Renew** in crypt when
available; revived Burns follow the same self-mill heuristic as hand Burns."""

from __future__ import annotations

from typing import Optional

from ..ai import GreedyAI
from ..cards import Kind, VERB_BURN, VERB_REVIVE, VERB_RENEW
from ..match import MatchState


class RitualReanimatorPilot(GreedyAI):
    W_AEOIU_ACTIVATION_BASE = 70.0
    W_TEMPLE_BASE = 65.0
    W_NOBLE_BIG_TRIPLET = 25.0
    W_REVIVE_PRIO_RENEW = 30.0
    W_REVIVE_PRIO_BURN = 18.0
    W_REVIVE_PRIO_INSIGHT = 11.0
    W_REVIVE_PRIO_SEEK = 6.0
    W_REVIVE_PRIO_WOE = 2.0
    W_REVIVE_PRIO_WRATH = 0.0

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
        has_action = any(c.kind is Kind.INCANTATION for c in hand)
        if not has_action and len(rituals) >= 3:
            return True
        return False

    def choose_burn_target(self, state: MatchState, pid: int, val: int) -> int:
        me = state.players[pid]
        opp = state.opponent(pid)
        crypt_rituals = sum(1 for c in me.crypt if c.kind is Kind.RITUAL)
        deck_rituals = sum(1 for c in me.deck if c.kind is Kind.RITUAL)
        deck_len = len(me.deck)
        has_aeoiu = state.has_noble(pid, "aeoiu_rituals")
        behind = state.match_power(opp) > state.match_power(pid)

        if deck_len <= 2 * val + 1:
            return opp
        if crypt_rituals < 3 and deck_rituals >= 2:
            return pid
        if has_aeoiu and crypt_rituals < 4 and deck_len > 2 * val + 2:
            return pid
        if behind and crypt_rituals < 3 and deck_rituals >= 1:
            return pid
        return opp

    def amend_revive_ctx(self, state: MatchState, pid: int, crypt_idx: int, ctx: dict) -> dict:
        ctx = super().amend_revive_ctx(state, pid, crypt_idx, ctx)
        me = state.players[pid]
        if crypt_idx < 0 or crypt_idx >= len(me.crypt):
            return ctx
        card = me.crypt[crypt_idx]
        if card.kind is Kind.INCANTATION and card.verb == VERB_BURN:
            if self.choose_burn_target(state, pid, card.value) == pid:
                sub = dict(ctx.get("revive_sub_ctx", {}))
                sub["burn_target"] = pid
                ctx["revive_sub_ctx"] = sub
        return ctx

    def adjust_incantation_score(self, state: MatchState, pid: int, card, sac: list[int], score: float) -> Optional[float]:
        out = super().adjust_incantation_score(state, pid, card, sac, score)
        if out is None:
            return None
        if card.verb == VERB_REVIVE:
            out += 6.0
        elif card.verb == VERB_RENEW:
            out += 10.0
        return out

    def score_noble_play(self, state, card, eff_cost, sac):
        score = super().score_noble_play(state, card, eff_cost, sac)
        if score is None:
            return None
        if card.noble_id == "aeoiu_rituals":
            score += 50.0
        return score

    def score_temple_play(self, state, card, sac, lanes_after_sac):
        score = super().score_temple_play(state, card, sac, lanes_after_sac)
        if score is None:
            return None
        if card.temple_id == "phaedra_illusion":
            p = state.players[self.pid]
            if len(p.hand) >= 4:
                score += 15.0
        return score
