; ----------------------------------------------------------------------------
; attempt_kill.hs - the kill goal's execution routing (pure .hs).
;
; A standing {@self goal {@self kill V}} resolves through the EMERGENT FIGHT:
; this think mints the combat goal {@self goal {@self fight V}} (idempotent
; per victim), and fight.hs plays it out blow by blow wherever killer and
; victim meet - kill_seek stalks to V's home; an occasion that puts them
; co-present (a crashed wedding) works identically, since kill_strike keys on
; co-presence alone. (strike-blow) lands the wounds, the ledger row and
; propagate-death; the goal alive-gate prunes both goals once V is dead.
;
; Replaces the C++ generative loop's melee branch (run_generative_perpetration
; minted this same fight goal after a method sample whose winner it then
; DISCARDED - the fight strikes with whatever is in hand, so the sample only
; gated the mint month). The loop now skips kill goals entirely.
;
; The killer arms BEFOREHAND or not at all: possession is their own state
; ((controls @self ...)), acquisition is the means_cascade errand - never a
; world scan. An unarmed killer fights bare-handed (strangle / beat), exactly
; what (strike-blow)'s weapon-class resolution models.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour attempt_kill
  (long-term-think)
  (goal {@self kill})

  (role @self (any_human @self))

  ; The victim of the (first) standing kill goal. A kind-valued target (a
  ; profile goal not yet bound to a person) or a dead victim gates out; the
  ; per-victim fight-goal test keeps the mint idempotent across months.
  (bind (goal-focus kill) ?victim)
  (when (and (is-entity ?victim)
             (alive ?victim)
             (no-goal {@self fight ?victim})))

  (effects
    (begin-goal {@self fight ?victim})))
