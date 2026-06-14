; ----------------------------------------------------------------------------
; love_match - affect-driven betrothal.
;
; A suitor who FANCIES someone (the one-sided attraction scalar -> the `fancy`
; verb-state belief, ignited by crush_forms) becomes betrothed to them: a love
; match. Class need NOT match (the romance that crosses class lines); the only
; hard requirement is that the suitor actually fancies the beloved. This runs
; ALONGSIDE the class-parity `betrothal` (the arranged path): fancied pairs pair
; here, everyone else there. That coexistence IS the bond/affect split - a
; marriage bond forms from love here, or from family/class fit there, and the
; warmth/attraction then evolve underneath either.
;
; The fancy gate is (stance-at-least ?suitor ?beloved fancy) - the reliable
; cross-pair BITSET predicate (section 13.1). The believer (?suitor) is the
; enumerated outer role; ?beloved is intersected with the bitset of the suitor's
; fancied targets, so the believes-in-(chance) residue bug (section 13) does not
; apply. Re-uses the _betrothal kind/log so the existing wedding event consumes
; the couple unchanged.
;
; Place-emergent (Section 4.11): no (schedule) - fired by the `love_match`
; affordance at the courtship venues (pub / restaurant / theatre /
; social_clubhouse / church) via resolve_affordances. The proposal happens where
; the mutually-fancied pair are actually co-present (the (co-present ?suitor
; ?beloved) gate below) - the boy pops the question at the place they share, not
; on a global november tick. Runs alongside the arranged `betrothal` /
; `advantageous_match` paths. The live un-betrothed re-check (when) resolves
; within-band collisions.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event love_match
  (nl         "?suitor and ?beloved marry for love")
  (kind       _betrothal)
  (band      evening)
  (rng-stream marriages)

  (roles
    ; ?suitor is enumerated (role[0]): an unmarried, un-betrothed adult who is
    ; not socially shut out. It is the BELIEVER, so it must be the outer role for
    ; the cross-pair gate on ?beloved to resolve.
    (role ?suitor (template any_human)
                  (>= (years-old ?suitor) 18)
                  (not (believes ?suitor {@self fiancee ?}))
                  (not (believes ?suitor {@self spouse ?}))
                  (not (= (situation ?suitor repute) scandalous))
                  ;; Fallen-woman gate, class-modulated (late-Victorian model):
                  ;; the respectable classes shut her out of courtship entirely,
                  ;; but working-class communities are pragmatic - a lower-class
                  ;; fall may still wed (the beloved role completes the pair
                  ;; check: BOTH sides must be lower).
                  (or (not (believes ?suitor {@self prototype fallen_woman}))
                      (= (situation ?suitor class_situation) lower)))
    (role ?beloved (template any_human)
                  (not (= ?beloved ?suitor))
                  (>= (years-old ?beloved) 18)
                  (not (believes ?beloved {@self fiancee ?}))
                  (not (believes ?beloved {@self spouse ?}))
                  (not (= (situation ?beloved repute) scandalous))
                  ;; Pair half of the fallen-woman gate: a fallen party (either
                  ;; side) weds only when BOTH sides are lower class.
                  (or (not (believes ?beloved {@self prototype fallen_woman}))
                      (and (= (situation ?beloved class_situation) lower)
                           (= (situation ?suitor  class_situation) lower)))
                  (or (not (believes ?suitor {@self prototype fallen_woman}))
                      (= (situation ?beloved class_situation) lower))
                  ; Place-emergent (Section 4.11): the proposal happens where the
                  ; pair are actually together this band (errand-magnetism brought
                  ; the suitor to her venue). Binds ?beloved from the co-present set.
                  (co-present ?suitor ?beloved)
                  ; the heart of it: the suitor fancies this person (reliable
                  ; bitset cross-pair - NOT believes-in-chance, see section 13).
                  (stance-at-least ?suitor ?beloved fancy)
                  ; MUTUAL fancy - she fancies him BACK. A love match is a meeting
                  ; of two hearts: the suitor courts (the `court` affordance builds
                  ; her fancy toward him), and only once she reciprocates do they
                  ; betroth. A one-sided crush does NOT marry here - it routes to
                  ; the arranged `betrothal` / `advantageous_match` (good-match,
                  ; no-fancy) path or simply goes nowhere. ?beloved is the inner
                  ; role, so this is the two-bound believes residue (both already
                  ; bound), the same reciprocation shape lovers.hs uses.
                  (believes ?beloved {@self fancy ?suitor})
                  ; lover fidelity: a party holding a standing `lover` bond
                  ; love-matches ONLY that lover (the widowed affair-partners
                  ; finally marrying), never a third party over them.
                  (or (not (believes ?suitor {@self lover ?}))
                      (believes ?suitor {@self lover ?beloved}))
                  (or (not (believes ?beloved {@self lover ?}))
                      (believes ?beloved {@self lover ?suitor}))
                  ; no marrying blood kin (defense-in-depth - crush_forms already
                  ; kin-gates the fancy, but a stray standing-pass fancy could
                  ; slip through; this is the consanguinity backstop).
                  (not (kin ?suitor ?beloved))
                  ; opposite-sex, so the man/woman wedding machinery applies. fancy
                  ; is already opposite-sex (crush_forms gates it); this is belt-
                  ; and-braces and drops any same-sex standing-pass fancy.
                  (not (= (attr ?beloved gender) (attr ?suitor gender)))
                  (<= (- (years-old ?suitor) (years-old ?beloved))  15)
                  (>= (- (years-old ?suitor) (years-old ?beloved)) -15)))

  ;; Live un-betrothed re-check (see betrothal.hs): the role filters are
  ;; alpha-indexed and go stale within the january tick, so re-check at firing.
  (when (and (not (believes ?suitor  {@self fiancee ?}))
             (not (believes ?beloved {@self fiancee ?}))))

  (effects
    ; Symmetric fiancee bond + mutual profile sync - identical to betrothal, so
    ; the existing wedding event consumes the couple (it recovers the groom from
    ; the bride's fiancee belief regardless of which side initiated).
    (begin-belief ?suitor  fiancee ?beloved)
    (begin-belief ?beloved fiancee ?suitor)
    (believe-about ?suitor  ?beloved)
    (believe-about ?beloved ?suitor)
    (log _betrothal ?suitor)))
