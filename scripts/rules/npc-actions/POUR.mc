; ----------------------------------------------------------------------------
; POUR - fluid runs from ?source into ?vessel.
;
; PORTED from the C++ handler (action_unification_plan.md). Its run_func returned success and nothing
; else: "minting the fluid, how much of it there is and which vessel holds it" was
; left to the corpus, and the corpus has no fluid model yet - it arrives with the
; eating and drinking set, whose `amount` attr this waits on (plan section 11).
; ----------------------------------------------------------------------------

(npc-action {@self POUR ?source ?vessel}:?pour
  (motor right-hand legs)
  (obs)
  (tar @excl)
  (duration 0.8)
  (presentation
    (preroll 0.0) (in 0.4) (out 0.4))

  (init
    (check (substantial ?vessel)))

  (effects
    (check (spatial ?vessel co-located @self /env))
    (set-outcome ?pour /succ)))
