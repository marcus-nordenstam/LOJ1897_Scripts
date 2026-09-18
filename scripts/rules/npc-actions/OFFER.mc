; ----------------------------------------------------------------------------
; OFFER - ?thing is held out for someone else to take.
;
; PORTED from the C++ handler (action_unification_plan.md). The handler's init_func
; validated its arguments and rejected the act; that rejection is the (prelude ..)
; below, because a /fail there is what refuses an install - a (check ..) would not,
; since it compiles out under MX_SHIPPING. It is PROCEDURAL: the handler returned no
; outcome, so the offer stands until the proposer withdraws it - which is what an
; offer is. How loosely the thing is held while it is out, and when the offer has
; been taken up, are the proposing task's to watch.
; ----------------------------------------------------------------------------

(npc-action {@self OFFER ?thing}:?offer
  (motor right-hand)
  (obs)
  (tar @excl)
  (construed-act provision-act)
  (duration procedural)
  (presentation
    (preroll 0.0) (in 0.3) (out 0.3))

  (prelude
    (if (unsubstantial ?thing)
        (then (set-outcome ?offer /fail)))))
