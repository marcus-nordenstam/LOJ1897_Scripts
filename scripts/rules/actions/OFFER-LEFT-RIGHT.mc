; ----------------------------------------------------------------------------
; OFFER-LEFT / OFFER-RIGHT ?thing ?recipient - hold ?thing out in the left / right hand for
; ?recipient to take. The offer places nothing: it posts `take` ?thing on the recipient's
; public bb, and the recipient, receiving (tasks/receive-task.mc), takes it with a hand of
; his own choosing and clears the entry. It stands until its proposer withdraws it.
; ----------------------------------------------------------------------------

(action {@self OFFER-LEFT ?thing ?recipient}:?OFFER-LEFT
  (motor left-hand)
  (obs)
  (tar [k object] @object) (aux [k human] @object)
  (construed-act provision-act)
  (duration procedural)
  (presentation
    (preroll 0.0) (in 0.3) (out 0.3))
  (init
    (check (= (spatial ?thing gripped-by /env) (spatial @self left-hand /env)))
    (check (spatial @self can-reach ?recipient /env))
    (bb-public-write ?recipient take ?thing)))

(action {@self OFFER-RIGHT ?thing ?recipient}:?OFFER-RIGHT
  (motor right-hand)
  (obs)
  (tar [k object] @object) (aux [k human] @object)
  (construed-act provision-act)
  (duration procedural)
  (presentation
    (preroll 0.0) (in 0.3) (out 0.3))
  (init
    (check (= (spatial ?thing gripped-by /env) (spatial @self right-hand /env)))
    (check (spatial @self can-reach ?recipient /env))
    (bb-public-write ?recipient take ?thing)))
