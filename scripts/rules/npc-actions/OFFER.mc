; ----------------------------------------------------------------------------
; OFFER - ?thing is held out for someone else to take.
;
; PORTED from the C++ handler (action_unification_plan.md). It is PROCEDURAL: the handler returned no
; outcome, so the offer stands until the proposer withdraws it - which is what an
; offer is. How loosely the thing is held while it is out, and when the offer has
; been taken up, are the proposing task's to watch.
; ----------------------------------------------------------------------------

(npc-action {@self OFFER ?thing}:?offer
  (motor right-hand legs)
  (obs)
  (tar @excl)
  (construed-act provision-act)
  (duration procedural)
  (presentation
    (preroll 0.0) (in 0.3) (out 0.3)))
