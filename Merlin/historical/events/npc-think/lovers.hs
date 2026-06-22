; ----------------------------------------------------------------------------
; lovers (npc-think). The romance that bridges the one-sided crush and the formal
; betrothal. Two unmarried, un-betrothed adults pair off when one is attracted
; (`fancy`) and the other reciprocates (warmth or attraction of its own) - a
; reciprocal `lover` bond, the courting-couple state. Distinct from:
;   - crush_forms: one-sided attraction (the `fancy` scalar/verb on one side);
;   - love_match / betrothal: the formal `fiancee` commitment.
; A lover pair may go on to betroth (love_match reads the same `fancy` supply) or
; may not - the bond persists underneath either outcome. `lover` is an
; inclusive_bond (Concepts.mon), so this never trips the exclusive-bond betray
; cascade and never collides with an @excl placeholder.
;
; The driver is "fancy + warmth": ?a is attracted to ?b (the cross-pair `fancy`
; bitset), and ?b reciprocates - with warmth (like/adore) OR attraction
; (fancy/desire) of its own (an (or ...) of believes residues on the reverse
; direction so the pairing is never unrequited).
;
; A mental change (a new bond), so npc-think. RELATIONAL: courtship is a TARGETED
; arc (a SPECIFIC attracted pair), and such a pair never coincides physically by
; chance - the co-present gate the place-lane draft tried made lovers fire NEVER,
; so FORMATION is keyed on the standing attraction, not co-presence (the settled
; reversion). Fired by the per-NPC emergent pass MONTHLY; the per-?a (chance)
; paces how quickly a reciprocated, available pair becomes a couple (a tuning
; knob - higher pairs the smitten faster).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event lovers
  (sim-window-start)
  (nl         "@self and ?b become lovers")
  (rng-stream marriages)

  (roles
    ; @self is the BELIEVER - the outer role for the cross-pair fancy gate on ?b
    ; to resolve. An available adult who fancies someone and is not already
    ; attached; the chance is rolled once per NPC per window.
    (role @self (template any_human)
                (>= (years-old @self) 18)
                (not (believes {@self spouse ?}))
                (not (believes {@self fiancee ?}))
                (not (believes {@self lover ?}))
                (chance 0.2))
    (role ?b (template any_human)
             (not (= ?b @self))
             (>= (years-old ?b) 18)
             (not (believes ?b {@self spouse ?}))
             (not (believes ?b {@self fiancee ?}))
             (not (believes ?b {@self lover ?}))
             ; @self is attracted to ?b (cross-pair bitset, @self the outer
             ; believer) ...
             (stance-at-least @self ?b fancy)
             ; ... and ?b reciprocates - at least fond of, or drawn to, @self (the
             ; reverse direction: an (or ...) of believes residues so the pairing is
             ; never unrequited; @self is the target = the deliberating actor).
             (or (believes ?b {?b like  @self})
                 (believes ?b {?b adore @self})
                 (believes ?b {?b fancy @self})
                 (believes ?b {?b desire @self}))
             ; opposite-sex (fancy is opposite-sex via crush_forms; belt-and-
             ; braces, and drops any same-sex standing-pass fancy) and not kin.
             (not (= (attr ?b gender) (attr @self gender)))
             (not (kin @self ?b))))

  ;; Live re-check: within the window the un-attached role filters go stale as
  ;; earlier firings mint lover bonds; re-confirm both are still free.
  (when (and (not (believes {@self lover ?}))
             (not (believes ?b   {@self lover ?}))))

  (effects
    ; Reciprocal lover bond + mutual profile sync (mirrors betrothal's shape so
    ; downstream consumers see a fully-wired pair).
    (begin-belief @self lover ?b)
    (begin-belief ?b lover @self)
    ; A lover bond is constructed on physical attraction - BOTH sides hold at
    ; least the `fancy` band (0.4 clears the 0.24 entry threshold; ?b may have
    ; reciprocated with warmth only, but becoming lovers grows the attraction).
    ; This is what lets love_match marry the pair later: it keys on `fancy`.
    (nudge-stance @self ?b attraction 0.4)
    (nudge-stance ?b @self attraction 0.4)
    (believe-about @self ?b)
    (believe-about ?b @self)
    (log _lovers @self)))
