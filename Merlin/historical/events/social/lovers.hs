; ----------------------------------------------------------------------------
; lovers.
;
; The romance that bridges the one-sided crush and the formal betrothal. Two
; unmarried, un-betrothed adults pair off when one is attracted (`fancy`) and
; the other reciprocates (warmth or attraction of its own) - a reciprocal
; `lover` bond, the courting-couple state. It is distinct from:
;   - crush_forms: one-sided attraction (the `fancy` scalar/verb on one side);
;   - love_match / betrothal: the formal `fiancee` commitment.
; A lover pair may go on to betroth (love_match reads the same `fancy` supply)
; or may not - the bond persists underneath either outcome. `lover` is an
; inclusive_bond (Concepts.mon), so this never trips the exclusive-bond betray
; cascade and never collides with an @excl placeholder.
;
; The driver is "fancy + warmth": ?a is attracted to ?b, and ?b
; reciprocates - with warmth (like/adore) OR with attraction (fancy/desire) of
; its own. Expressed reliably:
;   - (stance-at-least ?a ?b fancy)  -> ?b is in ?a's `fancy`-target BITSET
;     (the cross-pair predicate);
;   - an (or ...) of `believes` residues on the reverse direction -> ?b is at
;     least fond of / drawn to ?a (so the pairing is not unrequited).
; Both gate correctly.
;
; Schedule: annually july - crushes (monthly crush_forms) have had time to
; accumulate on both sides, and it sits clear of the january betrothal tick.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event lovers
  (nl         "?a and ?b become lovers")
  (kind       _lovers)
  (schedule   (annually july))
  (band      evening)
  (rng-stream marriages)

  (roles
    ; ?a is the enumerated BELIEVER (role[0]) - it must be the outer role for the
    ; cross-pair fancy gate on ?b to resolve. An available adult who fancies
    ; someone and is not already attached.
    (role ?a (template any_human)
             (>= (years-old ?a) 18)
             (not (believes ?a {@self spouse ?}))
             (not (believes ?a {@self fiancee ?}))
             (not (believes ?a {@self lover ?})))
    (role ?b (template any_human)
             (not (= ?b ?a))
             (>= (years-old ?b) 18)
             (not (believes ?b {@self spouse ?}))
             (not (believes ?b {@self fiancee ?}))
             (not (believes ?b {@self lover ?}))
             ; ?a is attracted to ?b (cross-pair bitset) ...
             (stance-at-least ?a ?b fancy)
             ; ... and ?b reciprocates - at least fond of, or drawn to, ?a (the
             ; reverse direction, an (or ...) of believes residues so the
             ; pairing is never unrequited).
             (or (believes ?b {@self like  ?a})
                 (believes ?b {@self adore ?a})
                 (believes ?b {@self fancy ?a})
                 (believes ?b {@self desire ?a}))
             ; opposite-sex (fancy is opposite-sex via crush_forms; belt-and-
             ; braces, and drops any same-sex standing-pass fancy) and not kin.
             (not (= (attr ?b gender) (attr ?a gender)))
             (not (kin ?a ?b))))

  ;; Live re-check: within the july tick the un-attached role filters go stale
  ;; as earlier firings mint lover bonds; re-confirm both are still free.
  (when (and (not (believes ?a {@self lover ?}))
             (not (believes ?b {@self lover ?}))))

  (effects
    ; Reciprocal lover bond + mutual profile sync (mirrors betrothal's shape so
    ; downstream consumers see a fully-wired pair).
    (begin-belief ?a lover ?b)
    (begin-belief ?b lover ?a)
    ; A lover bond is constructed on physical attraction - BOTH sides hold at
    ; least the `fancy` band (0.4 clears the 0.24 entry threshold; ?b may have
    ; reciprocated with warmth only, but becoming lovers grows the attraction).
    ; This is what lets love_match marry the pair later: it keys on `fancy`.
    (nudge-stance ?a ?b attraction 0.4)
    (nudge-stance ?b ?a attraction 0.4)
    (believe-about ?a ?b)
    (believe-about ?b ?a)
    (log _lovers ?a)))
