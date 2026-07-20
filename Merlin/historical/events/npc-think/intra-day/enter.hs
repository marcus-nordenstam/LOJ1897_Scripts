; ----------------------------------------------------------------------------
; enter - the generic "get inside a venue" chain (§5.11). Any lane that wants the
; actor INSIDE a structure mints {@self enter ?venue}; these two GENERIC rungs
; decompose it into the concrete travel, so no errand carries routing of its own:
;
;   enter_go_to_threshold: while OUTSIDE the venue and not yet at its door, hold
;     {@self go_to_threshold ?s} (front-park at the face). CEASES the instant
;     at-threshold flips true - the actor has reached the threshold.
;   enter_step_in: once AT the threshold, the entrance {?s room ?entry} is known
;     (taught by perception at the door) and the venue is open, hold {@self go
;     ?entry} (step into the entrance room). CEASES once inside (at-threshold false).
;
; Both are MAINTENANCE events: fire ONCE on the rising edge (cont-fire, gated by the
; schedule to fire once), hold, and run their (cease-effects) on the falling edge.
; The mutually-exclusive spatial gates (OUTSIDE vs AT-THRESHOLD) make the threshold->
; interior handoff EMERGENT - no excl-goal, no per-trip arm flag. The spatial
; predicates (in-building / at-threshold) are movement-reactive (§5.10): the actor's
; own arrival re-selects the next rung at its post-completion decision point, so a
; held rung advances the moment its spatial gate turns true - even on a repeat visit
; whose entrance is already known (no fresh belief edge to lean on).
;
; Locked-door / key / break-and-enter rungs are ADDITIONAL enter rungs plugged into
; this same chain later (§5.11 deferred) - they touch zero errand events.
; ----------------------------------------------------------------------------

; Reach the OUTSIDE threshold. Held while NOT inside ?s AND not yet at its door; the
; falling edge (at-threshold flips true) ends the go_to_threshold goal.
(npc-think enter_go_to_threshold
  (short-term-think)
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self enter ?s})
  (when (and (not (in-building ?s))
             (not (at-threshold @self ?s))))
  (cont-fire-effects (begin-goal {@self go_to_threshold ?s}))
  (cease-effects     (end-goal   {@self go_to_threshold ?s})))

; Step inside. Held once AT the threshold, the entrance {?s room ?entry} is known, and
; ?s is open; the falling edge (inside, so at-threshold false) ends the go goal. ?entry
; is bound off the perceived entrance belief and stashed at fire so the cease ends the
; SAME go goal.
(npc-think enter_step_in
  (short-term-think)
  (schedule on-commit)
  (if-blocked hold)
  (goal {@self enter ?s})
  (when (and (at-threshold @self ?s)
             (believes {?s room ?entry})
             (open ?s)))
  (cont-fire-effects (begin-goal {@self go ?entry}))
  (cease-effects     (end-goal   {@self go ?entry})))
