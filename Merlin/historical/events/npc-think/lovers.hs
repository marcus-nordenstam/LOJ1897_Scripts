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

(hsim-npc-behaviour lovers
  (long-term-think)
  (rng-stream marriages)

  (roles
    ; @self is the BELIEVER - the outer role for the cross-pair fancy gate on ?b
    ; to resolve. An available adult who fancies someone and is not already
    ; attached. (The per-NPC (chance) that paces pairing now lives in (when).)
    (role @self (any_human @self)
                (adult-age @self)
                (not (believes {@self spouse ?}))
                (not (believes {@self fiancee ?}))
                (not (believes {@self lover ?})))
    ;; SELF-POV (telepathy purge CAT-3): @self reads ?b's free/attached state from
    ;; his OWN knowledge (permissive on the unknown), and ?b's reciprocation as SHE
    ;; signalled it (confess_fancy). No cross-mind read.
    (role ?b (any_human ?b)
             (not (= ?b @self))
             (adult-age ?b)
             (not (believes {?b spouse ?}))
             (not (believes {?b fiancee ?}))
             (not (believes {?b lover ?}))
             ; @self is attracted to ?b (attraction at least the `fancy` band,
             ; the explicit band-ladder verb-state belief) ...
             (is-attracted-to @self ?b)
             ; ... and ?b reciprocates - she has TOLD HIM she fancies him
             ; (confess_fancy minted {?b fancy @self} in his mind), so the pairing
             ; is never unrequited. (The old warmth-only reciprocity is dropped: a
             ; lover bond is built on attraction, and warmth she never voiced cannot
             ; be read without a mind peek.)
             (believes {?b fancy @self})
             ; opposite-sex (fancy is opposite-sex via crush_forms; belt-and-braces):
             ; @self's belief that ?b's PERCEIVED gender differs from his own (visible-
             ; on-sight, so cacheable as a dynamic-target belief). And not kin.
             (not (believes {?b gender (target {@self gender})}))
             (not (blood-kin @self ?b))))

  ;; Live re-check: within the window the un-attached role filters go stale as
  ;; earlier firings mint lover bonds; re-confirm both are still free - from @self's
  ;; OWN beliefs (his own bond, and what he knows of ?b's). The per-NPC (chance) -
  ;; the pacing knob, rolled once per NPC per window - moved here from the @self
  ;; role (non-belief filters are not role-cacheable); it leads the (and) so it
  ;; short-circuits cheaply.
  (when (and (chance 0.2)
             (not (believes {@self lover ?}))
             (not (believes {?b   lover ?}))))

  (effects
    ; Reciprocal lover bond + mutual profile sync (mirrors betrothal's shape so
    ; downstream consumers see a fully-wired pair).
    (begin-belief {@self lover ?b})
    ; The reciprocal bond lands in ?b's own mind (so ?b knows of the pairing).
    (begin-belief ?b {?b lover @self})
    ; A lover bond is constructed on physical attraction - BOTH sides hold at
    ; least the `fancy` band (0.4 clears the 0.24 entry threshold; ?b may have
    ; reciprocated with warmth only, but becoming lovers grows the attraction).
    ; This is what lets love_match marry the pair later: it keys on `fancy`.
    (nudge-stance @self ?b attraction 0.4)
    (nudge-stance ?b @self attraction 0.4)
    (believe-about @self ?b)
    (believe-about ?b @self)
    ))
