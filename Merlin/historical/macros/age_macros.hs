; ----------------------------------------------------------------------------
; age_macros.hs - perceptible age-band predicates, as define-macros.
;
; Age is NOT read as a number any more (the old (years-old ?o) op read the env
; birth_date attr OMNISCIENTLY). Instead every mind holds a PERCEIVED age-band
; belief about the people it has seen - {?o age_band <band>} - minted on sight
; (perceive_person_appearance), even for strangers. The exact birth_date is
; communicated only to friends-and-closer. So role filters test the band, never
; a specific age.
;
; The ladder (Concepts.mon `age_band`, C++ age_band_index is the source of truth):
;   infant 0-2 < child 3-9 < adolescent 10-15 < youth 16-17 < young_adult 18-29
;   < middle_aged 30-49 < mature 50-69 < elderly 70+
; Narrow under 30, wide at 30+ - so "same / adjacent band" (age-peers) stands in
; for the old numeric age-diff windows: tight among the young, loose among adults.
;
; THRESHOLD predicates expand to a single believes with a ground KIND-ALT target
; (`[k a|b|c]`): the believes holds iff @self perceives ?o in ANY of those bands.
; The alt-list MUST stay in lockstep with the ladder above.
; ----------------------------------------------------------------------------

; >= 18 (the boundary sits at young_adult). "A grown adult."
(define-macro adult-age (?o)
  (believes {?o age_band [k young_adult|middle_aged|mature|elderly]}))

; >= 16 (the boundary sits at youth). "Old enough to court / marry."
(define-macro marriageable-age (?o)
  (believes {?o age_band [k youth|young_adult|middle_aged|mature|elderly]}))

; 3-15: a school-age child (covers the old 8-16 childhood-friendship intent; the
; band boundaries are the perceptible granularity, so it is juvenile OR adolescent).
(define-macro schoolchild-age (?o)
  (believes {?o age_band [k juvenile|adolescent]}))

; >= 70.
(define-macro elderly-age (?o)
  (believes {?o age_band [k elderly]}))

; 16-49 (youth + young_adult + middle_aged). "Working / migration age", and also
; the childbearing window for fertile_wife. NOTE: the band granularity puts the
; upper bound at 49 (middle_aged tops out there); the old numeric roles capped at
; 42 (fertility) / 45 (migration). Births taper naturally with band, so the wider
; cap is acceptable; tighten to [k youth|young_adult] for a hard <30 cut if the
; demographics drift.
(define-macro working-age (?o)
  (believes {?o age_band [k youth|young_adult|middle_aged]}))

; (age-peers ?who ?other): are ?who and ?other in the SAME or an ADJACENT band -
; the belief-only replacement for the numeric age-diff windows. Tests whether
; ?other's age_span (its band +/- 1) covers ?who's own single band, i.e.
; |band(who) - band(other)| <= 1. Because the ladder is narrow when young and wide
; when old, that is ~a few years among children and ~a generation among adults -
; exactly the graduated peer window the diffs encoded. ?who is normally @self (the
; deliberating mind reads its own band, no telepathy).
;
; ?who's band is read INLINE via (target {?who age_band}) - NOT bound into a var.
; A (bind {?who age_band ?v}) re-binds the same invariant per candidate, and the
; engine errors + fails the match on every candidate after the first (the var is
; already bound), so age-peers must stay a pure (believes) existence test - exactly
; how the cluster reads @self's class via (target {@self class_situation}).
(define-macro age-peers (?who ?other)
  (believes {?other age_span (target {?who age_band})}))
