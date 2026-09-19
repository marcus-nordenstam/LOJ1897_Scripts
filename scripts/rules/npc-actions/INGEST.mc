; ----------------------------------------------------------------------------
; INGEST - a draught or a mouthful of ?thing goes down.
;
; PORTED from the C++ handler (action_unification_plan.md). The handler's init_func
; validated its arguments and rejected the act; that rejection is the (init ..)
; below, because a /fail there is what refuses an install - a (check ..) would not,
; since it compiles out under MX_SHIPPING. Its run_func returned success and nothing
; else: what a draught DOES to what is drunk - how much it takes, and whether that
; empties the vessel - was never the handler's, and is not here either. It arrives
; with the eating and drinking set, which needs an `amount` attr the food archetype
; does not yet carry (plan section 11).
; ----------------------------------------------------------------------------

(npc-action {@self INGEST ?thing}:?ingest
  (motor mind)
  (tar @excl)
  (duration 0)
  (presentation
    (preroll 0) (in 0) (out 0))

  (init
    (if (unsubstantial ?thing)
        (then (set-outcome ?ingest /fail))))

  (effects
    (set-outcome ?ingest /succ)))
