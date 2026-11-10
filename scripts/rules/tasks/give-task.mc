; ----------------------------------------------------------------------------
; give ?thing ?recipient - hand a held thing to a person. While it runs it posts
; `receive-from` @self on the recipient's public bb, so he receives it (tasks/receive-task.mc),
; coming within reach and facing @self, and posting `receiving` himself on @self's public bb
; while he is. @self takes the thing if he does not hold it, AWAITs the recipient where he
; stands until the recipient is receiving, then holds it out with the hand that holds it
; (OFFER-LEFT / OFFER-RIGHT) until the recipient takes it. The ended
; {@self give ?thing ?recipient} belief IS the give memory (act/state doctrine). Conclusive
; outcome: the recipient holds it. Abandon: no live recipient to give to.
; ----------------------------------------------------------------------------

(task {@self give ?thing ?recipient}:?give
  (tar @excl [k object] @object)
  (aux [k human] @object)
  (and
    (try
      (effects (bb-public-maintain ?recipient receive-from @self)))
    (try
      (when (and (!= (spatial ?thing held-by) @self)
                 (!= (spatial ?thing held-by) ?recipient)))
      (effects (maintain-proposal {@self take ?thing})))
    (try
      (when (and (= (spatial ?thing held-by) @self)
                 (not (bb-public-any @self receiving ?recipient))))
      (effects (maintain-proposal {@self AWAIT ?recipient})))
    (try
      (when (and (= (spatial ?thing gripped-by) (spatial @self right-hand))
                 (spatial @self can-reach ?recipient)
                 (bb-public-any @self receiving ?recipient)))
      (effects (maintain-proposal {@self OFFER-RIGHT ?thing ?recipient})))
    (try
      (when (and (= (spatial ?thing gripped-by) (spatial @self left-hand))
                 (spatial @self can-reach ?recipient)
                 (bb-public-any @self receiving ?recipient)))
      (effects (maintain-proposal {@self OFFER-LEFT ?thing ?recipient})))
    (try
      (when (= (spatial ?thing held-by) ?recipient))
      (effects (set-outcome ?give /succ)))
    (try
      (when (not (alive ?recipient)))
      (effects (set-outcome ?give /fail)))))
